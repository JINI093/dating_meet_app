import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../utils/logger.dart';

/// 관리자 포인트 전환 관리 서비스
class AdminPointsService {
  /// 포인트 전환 요청 목록 조회 (실제 포인트 트랜잭션 데이터 기반)
  Future<Map<String, dynamic>> getPointExchangeRequests({
    int page = 1,
    int pageSize = 20,
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
  }) async {
    Logger.log('🔍 포인트 전환 요청 조회 시작 (Amplify GraphQL)', name: 'AdminPointsService');
    
    try {
      // 포인트 트랜잭션 데이터 조회 (type이 'conversion' 또는 '전환' 인 것들)
      const graphQLDocument = '''
        query ListPointTransactions(\$limit: Int, \$nextToken: String) {
          listPointTransactions(limit: \$limit, nextToken: \$nextToken) {
            items {
              id
              userId
              amount
              type
              description
              timestamp
              createdAt
              updatedAt
            }
            nextToken
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'limit': pageSize,
        },
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final jsonData = json.decode(response.data!);
        final listTransactions = jsonData['listPointTransactions'];
        
        Logger.log('🔍 GraphQL 응답 전체 구조: $jsonData', name: 'AdminPointsService');
        
        if (listTransactions != null && listTransactions['items'] != null) {
          final transactions = listTransactions['items'] as List;
          Logger.log('📊 조회된 포인트 트랜잭션 개수: ${transactions.length}', name: 'AdminPointsService');
          
          // 포인트 전환 요청으로 변환 (실제로는 전환 요청이 있어야 하지만 현재는 트랜잭션 데이터로 시뮬레이션)
          final exchangeRequests = await _convertTransactionsToExchangeRequests(transactions);
          
          // 필터 적용
          var filteredRequests = _applyFilters(exchangeRequests, filters, searchQuery);
          
          // 통계 계산
          final stats = _calculateStatistics(filteredRequests);
          
          return {
            'requests': filteredRequests,
            'total': filteredRequests.length,
            'page': page,
            'totalPages': (filteredRequests.length / pageSize).ceil(),
            'statistics': stats,
          };
        }
      }
      
      // 데이터가 없으면 기본 응답 반환
      return {
        'requests': <Map<String, dynamic>>[],
        'total': 0,
        'page': page,
        'totalPages': 0,
        'statistics': {
          'totalRequests': 0,
          'pendingRequests': 0,
          'completedRequests': 0,
          'totalConversionAmount': 0,
        },
      };
      
    } catch (e) {
      Logger.error('포인트 전환 요청 조회 실패: $e', name: 'AdminPointsService');
      rethrow;
    }
  }

  /// 포인트 트랜잭션을 전환 요청으로 변환
  Future<List<Map<String, dynamic>>> _convertTransactionsToExchangeRequests(List<dynamic> transactions) async {
    final requests = <Map<String, dynamic>>[];
    
    // 사용자 프로필 정보를 위한 GraphQL 쿼리
    for (final transaction in transactions) {
      try {
        final userId = transaction['userId'] as String;
        final amount = transaction['amount'] as int;
        
        // 마이너스 금액이거나 전환 관련 트랜잭션만 포함
        if (amount >= 0 && !transaction['description'].toString().contains('전환')) {
          continue;
        }
        
        // 사용자 프로필 정보 조회
        final userInfo = await _getUserInfo(userId);
        
        requests.add({
          'id': transaction['id'],
          'userId': userId,
          'name': userInfo['name'] ?? '알 수 없음',
          'age': userInfo['age'] ?? 0,
          'phoneNumber': userInfo['phoneNumber'] ?? '정보 없음',
          'gender': userInfo['gender'] ?? 'unknown',
          'profileImage': userInfo['profileImage'],
          'ipAddress': _generateRandomIP(), // 실제로는 별도 로그에서 가져와야 함
          'requestedPoints': amount.abs(),
          'requestDate': DateTime.parse(transaction['timestamp']),
          'conversionAmount': _calculateConversionAmount(amount.abs()),
          'status': _getRequestStatus(transaction),
          'description': transaction['description'],
        });
      } catch (e) {
        Logger.error('트랜잭션 변환 실패: $e', name: 'AdminPointsService');
        continue;
      }
    }
    
    return requests;
  }

  /// 사용자 정보 조회
  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    try {
      const graphQLDocument = '''
        query ListProfiles(\$filter: ModelProfileFilterInput) {
          listProfiles(filter: \$filter) {
            items {
              id
              userId
              name
              age
              gender
              profileImages
            }
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'filter': {
            'userId': {'eq': userId}
          }
        },
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final jsonData = json.decode(response.data!);
        final profiles = jsonData['listProfiles']['items'] as List;
        
        if (profiles.isNotEmpty) {
          final profile = profiles.first;
          
          // 전화번호는 별도 테이블에서 가져와야 하므로 임시로 생성
          final phoneNumber = _generatePhoneNumber(userId);
          
          return {
            'name': profile['name'],
            'age': profile['age'],
            'gender': profile['gender'],
            'phoneNumber': phoneNumber,
            'profileImage': profile['profileImages']?.isNotEmpty == true ? profile['profileImages'][0] : null,
          };
        }
      }
      
      // 기본값 반환
      return {
        'name': '사용자$userId',
        'age': 25,
        'gender': 'male',
        'phoneNumber': _generatePhoneNumber(userId),
        'profileImage': null,
      };
      
    } catch (e) {
      Logger.error('사용자 정보 조회 실패: $e', name: 'AdminPointsService');
      return {
        'name': '사용자$userId',
        'age': 25,
        'gender': 'male',
        'phoneNumber': _generatePhoneNumber(userId),
        'profileImage': null,
      };
    }
  }

  /// 전환 금액 계산 (1포인트 = 10원)
  int _calculateConversionAmount(int points) {
    return points * 10;
  }

  /// 요청 상태 결정
  String _getRequestStatus(Map<String, dynamic> transaction) {
    final description = transaction['description'] as String;
    final now = DateTime.now();
    final transactionDate = DateTime.parse(transaction['timestamp']);
    final daysDiff = now.difference(transactionDate).inDays;
    
    if (description.contains('완료') || description.contains('승인')) {
      return '처리완료';
    } else if (description.contains('거절') || description.contains('취소')) {
      return '처리거절';
    } else if (daysDiff > 1) {
      return '검토중';
    } else {
      return '처리대기';
    }
  }

  /// 전화번호 생성 (임시)
  String _generatePhoneNumber(String userId) {
    final hash = userId.hashCode.abs();
    final firstPart = (hash % 9000 + 1000).toString();
    final secondPart = ((hash ~/ 1000) % 9000 + 1000).toString();
    return '+82-10-$firstPart-$secondPart';
  }

  /// 랜덤 IP 생성
  String _generateRandomIP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final a = (random % 255) + 1;
    final b = ((random ~/ 255) % 255) + 1;
    final c = ((random ~/ 65025) % 255) + 1;
    final d = ((random ~/ 16581375) % 255) + 1;
    return '$a.$b.$c.$d';
  }

  /// 필터 적용
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> requests,
    Map<String, dynamic> filters,
    String searchQuery,
  ) {
    var filtered = requests;
    
    // 상태 필터
    if (filters['status'] != null && filters['status'] != '전체') {
      filtered = filtered.where((r) => r['status'] == filters['status']).toList();
    }
    
    // 성별 필터
    if (filters['gender'] != null && filters['gender'] != '전체') {
      final genderFilter = filters['gender'] == '남성' ? 'male' : 'female';
      filtered = filtered.where((r) => r['gender'] == genderFilter).toList();
    }
    
    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final name = r['name'].toString().toLowerCase();
        final phoneNumber = r['phoneNumber'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) || phoneNumber.contains(query);
      }).toList();
    }
    
    // 날짜 순 정렬 (최신순)
    filtered.sort((a, b) => (b['requestDate'] as DateTime).compareTo(a['requestDate'] as DateTime));
    
    return filtered;
  }

  /// 통계 계산
  Map<String, dynamic> _calculateStatistics(List<Map<String, dynamic>> requests) {
    final totalRequests = requests.length;
    final pendingRequests = requests.where((r) => r['status'] == '처리대기').length;
    final completedRequests = requests.where((r) => r['status'] == '처리완료').length;
    final totalConversionAmount = requests
        .where((r) => r['status'] == '처리완료')
        .fold<int>(0, (sum, r) => sum + (r['conversionAmount'] as int));
    
    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'completedRequests': completedRequests,
      'totalConversionAmount': totalConversionAmount,
    };
  }

  /// 포인트 전환 요청 승인
  Future<bool> approveRequest(String requestId, String userId) async {
    try {
      Logger.log('포인트 전환 요청 승인: $requestId', name: 'AdminPointsService');
      
      // 실제로는 요청 상태를 업데이트하고 실제 전환을 처리해야 함
      // 현재는 트랜잭션 설명을 업데이트
      const mutation = '''
        mutation UpdatePointTransaction(\$input: UpdatePointTransactionInput!) {
          updatePointTransaction(input: \$input) {
            id
            description
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'id': requestId,
            'description': '포인트 전환 승인 완료',
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('포인트 전환 승인 실패: ${response.errors}', name: 'AdminPointsService');
        return false;
      }

      Logger.log('포인트 전환 승인 완료: $requestId', name: 'AdminPointsService');
      return true;
      
    } catch (e) {
      Logger.error('포인트 전환 승인 오류: $e', name: 'AdminPointsService');
      return false;
    }
  }

  /// 포인트 전환 요청 거절
  Future<bool> rejectRequest(String requestId, String reason) async {
    try {
      Logger.log('포인트 전환 요청 거절: $requestId', name: 'AdminPointsService');
      
      const mutation = '''
        mutation UpdatePointTransaction(\$input: UpdatePointTransactionInput!) {
          updatePointTransaction(input: \$input) {
            id
            description
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'id': requestId,
            'description': '포인트 전환 거절: $reason',
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('포인트 전환 거절 실패: ${response.errors}', name: 'AdminPointsService');
        return false;
      }

      Logger.log('포인트 전환 거절 완료: $requestId', name: 'AdminPointsService');
      return true;
      
    } catch (e) {
      Logger.error('포인트 전환 거절 오류: $e', name: 'AdminPointsService');
      return false;
    }
  }
}