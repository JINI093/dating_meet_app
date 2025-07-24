import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/like_model.dart';
import '../models/superchat_model.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

/// AWS 기반 슈퍼챗 서비스
/// 프리미엄 메시징 기능 - 포인트를 사용하여 우선순위 높은 메시지 전송
class AWSSuperchatService {
  static final AWSSuperchatService _instance = AWSSuperchatService._internal();
  factory AWSSuperchatService() => _instance;
  AWSSuperchatService._internal();

  static const int _superchatCost = 100; // 슈퍼챗 1회당 필요 포인트
  static const int _dailySuperchatLimit = 5; // 일일 슈퍼챗 제한
  static const String _superchatCountKey = 'daily_superchat_count';
  static const String _lastSuperchatDateKey = 'last_superchat_date';

  final NotificationService _notificationService = NotificationService();

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      Logger.log('✅ AWSSuperchatService 초기화 완료', name: 'AWSSuperchatService');
    } catch (e) {
      Logger.error('❌ AWSSuperchatService 초기화 실패', error: e, name: 'AWSSuperchatService');
      rethrow;
    }
  }

  /// 슈퍼챗 전송
  Future<SuperchatModel?> sendSuperchat({
    required String fromUserId,
    required String toProfileId,
    required String message,
    required int pointsUsed,
    String? templateType,
    Map<String, dynamic>? customData,
  }) async {
    try {
      // 1. 입력값 검증
      _validateSuperchatData(
        message: message,
        pointsUsed: pointsUsed,
      );

      // 2. 일일 제한 확인
      final canSendSuperchat = await _checkDailyLimit(fromUserId);
      if (!canSendSuperchat) {
        throw Exception('일일 슈퍼챗 전송 제한을 초과했습니다. ($_dailySuperchatLimit회)');
      }

      // 3. 포인트 잔액 확인
      final hasEnoughPoints = await _checkUserPoints(fromUserId, pointsUsed);
      if (!hasEnoughPoints) {
        throw Exception('포인트가 부족합니다. 필요 포인트: $pointsUsed');
      }

      // 4. 중복 확인 (동일 상대에게 최근 24시간 내 슈퍼챗 전송 여부)
      final recentSuperchat = await _getRecentSuperchat(fromUserId, toProfileId);
      if (recentSuperchat != null) {
        throw Exception('동일한 상대에게는 24시간 후에 슈퍼챗을 다시 보낼 수 있습니다.');
      }

      // 5. 슈퍼챗 데이터 생성
      final now = DateTime.now();
      final superchatData = {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'message': message,
        'pointsUsed': pointsUsed,
        'templateType': templateType ?? 'CUSTOM',
        'customData': customData,
        'status': 'SENT',
        'priority': _calculatePriority(pointsUsed),
        'expiresAt': now.add(const Duration(days: 7)).toIso8601String(), // 7일 후 만료
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // 6. GraphQL 뮤테이션 실행
      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateSuperchat(\$input: CreateSuperchatInput!) {
            createSuperchat(input: \$input) {
              id
              fromUserId
              toProfileId
              message
              pointsUsed
              templateType
              customData
              status
              priority
              expiresAt
              createdAt
              updatedAt
            }
          }
        ''',
        variables: {'input': superchatData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('슈퍼챗 전송 실패: ${response.errors.first.message}');
      }

      // 7. 포인트 차감
      await _deductUserPoints(fromUserId, pointsUsed, '슈퍼챗 전송');

      // 8. 일일 카운트 증가
      await _incrementDailySuperchatCount(fromUserId);

      // 9. 프로필 슈퍼챗 수 증가
      await _incrementProfileSuperchatCount(toProfileId);

      // 10. 슈퍼챗 알림 전송 (우선순위별)
      try {
        await _notificationService.showSuperchatNotification(
          fromUserName: 'Unknown User', // 실제로는 프로필 정보에서 가져와야 함
          fromUserId: fromUserId,
          message: message,
          priority: _calculatePriority(pointsUsed),
          pointsUsed: pointsUsed,
          templateType: SuperchatTemplateType.custom, // 템플릿 타입 파싱 필요 시 추가
        );
      } catch (e) {
        Logger.error('슈퍼챗 알림 전송 오류', error: e, name: 'AWSSuperchatService');
        // 알림 실패는 전체 프로세스를 중단시키지 않음
      }

      if (response.data != null) {
        final superchatJson = _parseGraphQLResponse(response.data!);
        final superchatData = superchatJson['createSuperchat'];
        if (superchatData != null) {
          return SuperchatModel.fromJson(superchatData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('슈퍼챗 전송 오류', error: e, name: 'AWSSuperchatService');
      rethrow;
    }
  }

  /// 받은 슈퍼챗 목록 조회
  Future<List<SuperchatModel>> getReceivedSuperchats({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetReceivedSuperchats(\$toProfileId: String!, \$limit: Int, \$nextToken: String) {
            superchatsByToProfileId(
              toProfileId: \$toProfileId, 
              limit: \$limit, 
              nextToken: \$nextToken,
              sortDirection: DESC
            ) {
              items {
                id
                fromUserId
                toProfileId
                message
                pointsUsed
                templateType
                customData
                status
                priority
                expiresAt
                createdAt
                updatedAt
              }
              nextToken
            }
          }
        ''',
        variables: {
          'toProfileId': userId,
          'limit': limit,
          'nextToken': nextToken,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('받은 슈퍼챗 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['superchatsByToProfileId']?['items'] as List?;
        if (items != null) {
          return items
              .map((item) => SuperchatModel.fromJson(item as Map<String, dynamic>))
              .where((superchat) => !superchat.isExpired) // 만료되지 않은 것만
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.error('받은 슈퍼챗 조회 오류', error: e, name: 'AWSSuperchatService');
      return [];
    }
  }

  /// 보낸 슈퍼챗 목록 조회
  Future<List<SuperchatModel>> getSentSuperchats({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetSentSuperchats(\$fromUserId: String!, \$limit: Int, \$nextToken: String) {
            superchatsByFromUserId(
              fromUserId: \$fromUserId, 
              limit: \$limit, 
              nextToken: \$nextToken,
              sortDirection: DESC
            ) {
              items {
                id
                fromUserId
                toProfileId
                message
                pointsUsed
                templateType
                customData
                status
                priority
                expiresAt
                createdAt
                updatedAt
              }
              nextToken
            }
          }
        ''',
        variables: {
          'fromUserId': userId,
          'limit': limit,
          'nextToken': nextToken,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('보낸 슈퍼챗 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['superchatsByFromUserId']?['items'] as List?;
        if (items != null) {
          return items
              .map((item) => SuperchatModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.error('보낸 슈퍼챗 조회 오류', error: e, name: 'AWSSuperchatService');
      return [];
    }
  }

  /// 슈퍼챗 상태 업데이트 (읽음, 답장 등)
  Future<bool> updateSuperchatStatus({
    required String superchatId,
    required String status,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateSuperchatStatus(\$input: UpdateSuperchatInput!) {
            updateSuperchat(input: \$input) {
              id
              status
              updatedAt
            }
          }
        ''',
        variables: {
          'input': {
            'id': superchatId,
            'status': status,
            'updatedAt': DateTime.now().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('슈퍼챗 상태 업데이트 실패: ${response.errors.first.message}');
      }

      Logger.log('슈퍼챗 상태 업데이트: $superchatId -> $status', name: 'AWSSuperchatService');
      return true;
    } catch (e) {
      Logger.error('슈퍼챗 상태 업데이트 오류', error: e, name: 'AWSSuperchatService');
      return false;
    }
  }

  /// 일일 슈퍼챗 전송 가능 횟수 확인
  Future<int> getRemainingDailySuperchats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final lastDate = prefs.getString('${_lastSuperchatDateKey}_$userId') ?? '';
      final currentCount = prefs.getInt('${_superchatCountKey}_$userId') ?? 0;
      
      // 날짜가 바뀌었으면 카운트 리셋
      if (lastDate != todayString) {
        await prefs.setString('${_lastSuperchatDateKey}_$userId', todayString);
        await prefs.setInt('${_superchatCountKey}_$userId', 0);
        return _dailySuperchatLimit;
      }
      
      return (_dailySuperchatLimit - currentCount).clamp(0, _dailySuperchatLimit);
    } catch (e) {
      Logger.error('일일 슈퍼챗 전송 횟수 확인 오류', error: e, name: 'AWSSuperchatService');
      return 0;
    }
  }

  /// 슈퍼챗 우선순위 계산
  int _calculatePriority(int pointsUsed) {
    // 포인트에 따른 우선순위 계산
    if (pointsUsed >= 1000) return 1; // 최고 우선순위
    if (pointsUsed >= 500) return 2;  // 높은 우선순위
    if (pointsUsed >= 200) return 3;  // 중간 우선순위
    return 4; // 기본 우선순위
  }

  /// 슈퍼챗 데이터 검증
  void _validateSuperchatData({
    required String message,
    required int pointsUsed,
  }) {
    // 메시지 검증
    if (message.isEmpty || message.length > 500) {
      throw Exception('메시지는 1-500자 사이여야 합니다.');
    }

    // 포인트 검증
    if (pointsUsed < _superchatCost) {
      throw Exception('슈퍼챗은 최소 $_superchatCost 포인트가 필요합니다.');
    }

    if (pointsUsed > 10000) {
      throw Exception('슈퍼챗은 최대 10,000 포인트까지 사용 가능합니다.');
    }
  }

  /// 일일 제한 확인
  Future<bool> _checkDailyLimit(String userId) async {
    final remaining = await getRemainingDailySuperchats(userId);
    return remaining > 0;
  }

  /// 사용자 포인트 잔액 확인
  Future<bool> _checkUserPoints(String userId, int requiredPoints) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetUserPoints(\$userId: String!) {
            getUserPoints(userId: \$userId) {
              totalPoints
              availablePoints
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final availablePoints = data['getUserPoints']?['availablePoints'] as int? ?? 0;
        return availablePoints >= requiredPoints;
      }

      return false;
    } catch (e) {
      Logger.error('사용자 포인트 확인 오류', error: e, name: 'AWSSuperchatService');
      return false;
    }
  }

  /// 최근 슈퍼챗 확인 (24시간 내)
  Future<SuperchatModel?> _getRecentSuperchat(String fromUserId, String toProfileId) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      
      final request = GraphQLRequest<String>(
        document: '''
          query GetRecentSuperchat(\$fromUserId: String!, \$toProfileId: String!, \$since: String!) {
            superchatsByFromUserId(
              fromUserId: \$fromUserId,
              filter: {
                and: [
                  {toProfileId: {eq: \$toProfileId}},
                  {createdAt: {gte: \$since}}
                ]
              }
            ) {
              items {
                id
                fromUserId
                toProfileId
                createdAt
              }
            }
          }
        ''',
        variables: {
          'fromUserId': fromUserId,
          'toProfileId': toProfileId,
          'since': yesterday.toIso8601String(),
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['superchatsByFromUserId']?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return SuperchatModel.fromJson(items.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      Logger.error('최근 슈퍼챗 확인 오류', error: e, name: 'AWSSuperchatService');
      return null;
    }
  }

  /// 사용자 포인트 차감
  Future<void> _deductUserPoints(String userId, int points, String reason) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation DeductUserPoints(\$input: DeductPointsInput!) {
            deductUserPoints(input: \$input) {
              success
              remainingPoints
            }
          }
        ''',
        variables: {
          'input': {
            'userId': userId,
            'points': points,
            'reason': reason,
            'transactionType': 'SUPERCHAT',
          }
        },
      );

      await Amplify.API.mutate(request: request).response;
      Logger.log('포인트 차감 완료: $userId (-$points)', name: 'AWSSuperchatService');
    } catch (e) {
      Logger.error('포인트 차감 오류', error: e, name: 'AWSSuperchatService');
      throw Exception('포인트 차감에 실패했습니다.');
    }
  }

  /// 일일 슈퍼챗 카운트 증가
  Future<void> _incrementDailySuperchatCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      await prefs.setString('${_lastSuperchatDateKey}_$userId', todayString);
      final currentCount = prefs.getInt('${_superchatCountKey}_$userId') ?? 0;
      await prefs.setInt('${_superchatCountKey}_$userId', currentCount + 1);
      
      Logger.log('일일 슈퍼챗 카운트 증가: ${currentCount + 1}/$_dailySuperchatLimit', name: 'AWSSuperchatService');
    } catch (e) {
      Logger.error('일일 슈퍼챗 카운트 증가 오류', error: e, name: 'AWSSuperchatService');
    }
  }

  /// 프로필 슈퍼챗 수 증가
  Future<void> _incrementProfileSuperchatCount(String profileId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation IncrementProfileSuperchatCount(\$id: ID!) {
            incrementProfileSuperchatCount(id: \$id) {
              id
              superChatCount
            }
          }
        ''',
        variables: {'id': profileId},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('프로필 슈퍼챗 수 증가 오류', error: e, name: 'AWSSuperchatService');
    }
  }

  /// GraphQL 응답 파싱
  Map<String, dynamic> _parseGraphQLResponse(String response) {
    try {
      if (response.startsWith('{') || response.startsWith('[')) {
        return Map<String, dynamic>.from(response as Map);
      }
      return {};
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSSuperchatService');
      return {};
    }
  }
}