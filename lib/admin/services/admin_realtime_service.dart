import 'dart:convert';
import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../utils/logger.dart';

/// 관리자 실시간 접속 현황 서비스
class AdminRealtimeService {
  Timer? _refreshTimer;
  
  /// 실시간 접속 현황 데이터 조회
  Future<Map<String, dynamic>> getRealtimeConnections({
    int page = 1,
    int pageSize = 50,
    String searchQuery = '',
    String statusFilter = '전체',
  }) async {
    Logger.log('🔍 실시간 접속 현황 조회 시작 (Amplify GraphQL)', name: 'AdminRealtimeService');
    
    try {
      // 모든 사용자의 온라인 상태와 최근 접속 정보 조회
      const graphQLDocument = '''
        query ListProfiles(\$limit: Int, \$nextToken: String) {
          listProfiles(limit: \$limit, nextToken: \$nextToken) {
            items {
              id
              userId
              name
              age
              gender
              location
              profileImages
              isOnline
              isVip
              lastSeen
              createdAt
              updatedAt
            }
            nextToken
          }
        }
      ''';
      
      final allUsers = <Map<String, dynamic>>[];
      String? nextToken;
      
      // 페이지네이션으로 모든 사용자 데이터 가져오기
      do {
        final request = GraphQLRequest<String>(
          document: graphQLDocument,
          variables: {
            'limit': 100,
            if (nextToken != null) 'nextToken': nextToken,
          },
        );
        
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null) {
          final jsonData = json.decode(response.data!);
          final listProfiles = jsonData['listProfiles'];
          
          if (listProfiles != null && listProfiles['items'] != null) {
            final items = listProfiles['items'] as List;
            allUsers.addAll(items.cast<Map<String, dynamic>>());
            nextToken = listProfiles['nextToken'];
          } else {
            break;
          }
        } else {
          break;
        }
      } while (nextToken != null);
      
      Logger.log('📊 조회된 총 사용자 수: ${allUsers.length}', name: 'AdminRealtimeService');
      
      // 사용자 데이터 처리 및 실시간 상태 계산
      final processedUsers = await _processUserConnections(allUsers);
      
      // 필터 적용
      var filteredUsers = _applyFilters(processedUsers, statusFilter, searchQuery);
      
      // 정렬: 온라인 사용자 먼저, 그 다음 최근 접속순
      filteredUsers.sort((a, b) {
        if (a['isOnline'] && !b['isOnline']) return -1;
        if (!a['isOnline'] && b['isOnline']) return 1;
        
        final aLastSeen = a['lastSeenDateTime'] as DateTime?;
        final bLastSeen = b['lastSeenDateTime'] as DateTime?;
        
        if (aLastSeen == null && bLastSeen == null) return 0;
        if (aLastSeen == null) return 1;
        if (bLastSeen == null) return -1;
        
        return bLastSeen.compareTo(aLastSeen);
      });
      
      // 페이지네이션 적용
      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize < filteredUsers.length) 
          ? startIndex + pageSize 
          : filteredUsers.length;
      
      final paginatedUsers = filteredUsers.sublist(
        startIndex < filteredUsers.length ? startIndex : filteredUsers.length,
        endIndex
      );
      
      // 통계 계산
      final stats = _calculateRealtimeStatistics(allUsers);
      
      return {
        'users': paginatedUsers,
        'total': filteredUsers.length,
        'page': page,
        'totalPages': (filteredUsers.length / pageSize).ceil(),
        'statistics': stats,
      };
      
    } catch (e) {
      Logger.error('실시간 접속 현황 조회 실패: $e', name: 'AdminRealtimeService');
      rethrow;
    }
  }

  /// 사용자 연결 데이터 처리
  Future<List<Map<String, dynamic>>> _processUserConnections(List<Map<String, dynamic>> users) async {
    final processedUsers = <Map<String, dynamic>>[];
    
    for (final user in users) {
      try {
        final userId = user['userId'] as String;
        final isOnline = user['isOnline'] as bool? ?? false;
        final lastSeenStr = user['lastSeen'] as String?;
        
        DateTime? lastSeenDateTime;
        if (lastSeenStr != null) {
          try {
            lastSeenDateTime = DateTime.parse(lastSeenStr);
          } catch (e) {
            Logger.error('날짜 파싱 실패: $lastSeenStr', name: 'AdminRealtimeService');
          }
        }
        
        // 온라인 상태 재계산 (lastSeen이 5분 이내면 온라인으로 간주)
        final now = DateTime.now();
        bool actuallyOnline = isOnline;
        if (lastSeenDateTime != null) {
          final timeDiff = now.difference(lastSeenDateTime);
          actuallyOnline = timeDiff.inMinutes <= 5;
        }
        
        // 접속 기간 계산
        String connectionDuration = '';
        String lastSeenDisplay = '';
        
        if (lastSeenDateTime != null) {
          final timeDiff = now.difference(lastSeenDateTime);
          
          if (actuallyOnline) {
            if (timeDiff.inMinutes < 1) {
              connectionDuration = '방금 전';
            } else {
              connectionDuration = '${timeDiff.inMinutes}분 전 접속';
            }
          } else {
            if (timeDiff.inDays > 0) {
              lastSeenDisplay = '${timeDiff.inDays}일 전';
            } else if (timeDiff.inHours > 0) {
              lastSeenDisplay = '${timeDiff.inHours}시간 전';
            } else {
              lastSeenDisplay = '${timeDiff.inMinutes}분 전';
            }
          }
        }
        
        // 전화번호 생성 (임시)
        final phoneNumber = _generatePhoneNumber(userId);
        
        // 접속 위치 생성 (임시)
        final location = _generateLocation(user['location'] as String?);
        
        processedUsers.add({
          'id': user['id'],
          'userId': userId,
          'name': user['name'] ?? '알 수 없음',
          'age': user['age'] ?? 0,
          'gender': user['gender'] ?? 'unknown',
          'phoneNumber': phoneNumber,
          'profileImage': user['profileImages']?.isNotEmpty == true ? user['profileImages'][0] : null,
          'isOnline': actuallyOnline,
          'isVip': user['isVip'] ?? false,
          'lastSeenDateTime': lastSeenDateTime,
          'lastSeenDisplay': lastSeenDisplay,
          'connectionDuration': connectionDuration,
          'location': location,
          'deviceType': _generateDeviceType(),
          'ipAddress': _generateRandomIP(),
          'createdAt': DateTime.parse(user['createdAt']),
        });
      } catch (e) {
        Logger.error('사용자 데이터 처리 실패: $e', name: 'AdminRealtimeService');
        continue;
      }
    }
    
    return processedUsers;
  }

  /// 필터 적용
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> users,
    String statusFilter,
    String searchQuery,
  ) {
    var filtered = users;
    
    // 상태 필터
    switch (statusFilter) {
      case '온라인':
        filtered = filtered.where((u) => u['isOnline'] == true).toList();
        break;
      case '오프라인':
        filtered = filtered.where((u) => u['isOnline'] == false).toList();
        break;
      case 'VIP':
        filtered = filtered.where((u) => u['isVip'] == true).toList();
        break;
      case '일반':
        filtered = filtered.where((u) => u['isVip'] == false).toList();
        break;
    }
    
    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        final name = u['name'].toString().toLowerCase();
        final phoneNumber = u['phoneNumber'].toString().toLowerCase();
        final userId = u['userId'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) || phoneNumber.contains(query) || userId.contains(query);
      }).toList();
    }
    
    return filtered;
  }

  /// 실시간 통계 계산
  Map<String, dynamic> _calculateRealtimeStatistics(List<Map<String, dynamic>> allUsers) {
    final now = DateTime.now();
    
    int totalUsers = allUsers.length;
    int onlineUsers = 0;
    int vipOnlineUsers = 0;
    int todayNewUsers = 0;
    int activeInLast24h = 0;
    
    for (final user in allUsers) {
      final isOnline = user['isOnline'] as bool? ?? false;
      final isVip = user['isVip'] as bool? ?? false;
      final createdAt = DateTime.parse(user['createdAt']);
      final lastSeenStr = user['lastSeen'] as String?;
      
      // 실제 온라인 상태 계산
      bool actuallyOnline = isOnline;
      if (lastSeenStr != null) {
        try {
          final lastSeen = DateTime.parse(lastSeenStr);
          final timeDiff = now.difference(lastSeen);
          actuallyOnline = timeDiff.inMinutes <= 5;
          
          if (timeDiff.inHours <= 24) {
            activeInLast24h++;
          }
        } catch (e) {
          // 날짜 파싱 실패시 isOnline 값 사용
        }
      }
      
      if (actuallyOnline) {
        onlineUsers++;
        if (isVip) {
          vipOnlineUsers++;
        }
      }
      
      // 오늘 가입한 사용자
      if (createdAt.year == now.year && 
          createdAt.month == now.month && 
          createdAt.day == now.day) {
        todayNewUsers++;
      }
    }
    
    return {
      'totalUsers': totalUsers,
      'onlineUsers': onlineUsers,
      'offlineUsers': totalUsers - onlineUsers,
      'vipOnlineUsers': vipOnlineUsers,
      'todayNewUsers': todayNewUsers,
      'activeInLast24h': activeInLast24h,
      'onlineRate': totalUsers > 0 ? (onlineUsers / totalUsers * 100).toStringAsFixed(1) : '0.0',
    };
  }

  /// 전화번호 생성 (임시)
  String _generatePhoneNumber(String userId) {
    final hash = userId.hashCode.abs();
    final firstPart = (hash % 9000 + 1000).toString();
    final secondPart = ((hash ~/ 1000) % 9000 + 1000).toString();
    return '+82-10-$firstPart-$secondPart';
  }

  /// 위치 생성
  String _generateLocation(String? originalLocation) {
    if (originalLocation != null && originalLocation.isNotEmpty) {
      return originalLocation;
    }
    
    final locations = ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기', '강원'];
    final random = DateTime.now().millisecondsSinceEpoch;
    return locations[random % locations.length];
  }

  /// 디바이스 타입 생성 (임시)
  String _generateDeviceType() {
    final devices = ['iOS', 'Android', 'Web'];
    final random = DateTime.now().millisecondsSinceEpoch;
    return devices[random % devices.length];
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

  /// 실시간 데이터 자동 새로고침 시작
  void startAutoRefresh(Function() onRefresh, {Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      onRefresh();
    });
  }

  /// 자동 새로고침 중지
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 사용자 강제 로그아웃
  Future<bool> forceLogout(String userId) async {
    try {
      Logger.log('사용자 강제 로그아웃: $userId', name: 'AdminRealtimeService');
      
      // Profile의 isOnline을 false로 업데이트
      const mutation = '''
        mutation UpdateProfile(\$input: UpdateProfileInput!) {
          updateProfile(input: \$input) {
            id
            isOnline
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {
            'id': userId,
            'isOnline': false,
            'lastSeen': DateTime.now().toUtc().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.hasErrors) {
        Logger.error('강제 로그아웃 실패: ${response.errors}', name: 'AdminRealtimeService');
        return false;
      }

      Logger.log('강제 로그아웃 완료: $userId', name: 'AdminRealtimeService');
      return true;
      
    } catch (e) {
      Logger.error('강제 로그아웃 오류: $e', name: 'AdminRealtimeService');
      return false;
    }
  }

  void dispose() {
    stopAutoRefresh();
  }
}