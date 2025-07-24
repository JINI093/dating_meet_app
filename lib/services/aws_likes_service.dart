import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/like_model.dart';
import '../models/match_model.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'aws_match_service.dart';

/// AWS 기반 호감 표시 서비스
/// DynamoDB를 통한 좋아요/패스 데이터 관리
class AWSLikesService {
  static final AWSLikesService _instance = AWSLikesService._internal();
  factory AWSLikesService() => _instance;
  AWSLikesService._internal();

  static const int _dailyLikeLimit = 10;
  static const String _likesCountKey = 'daily_likes_count';
  static const String _lastLikeDateKey = 'last_like_date';
  
  final NotificationService _notificationService = NotificationService();
  final AWSMatchService _matchService = AWSMatchService();

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      Logger.log('✅ AWSLikesService 초기화 완료', name: 'AWSLikesService');
    } catch (e) {
      Logger.error('❌ AWSLikesService 초기화 실패', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }

  /// 호감 표시 (좋아요)
  Future<LikeModel?> sendLike({
    required String fromUserId,
    required String toProfileId,
    String? message,
  }) async {
    try {
      // 1. 일일 제한 확인
      final canSendLike = await _checkDailyLimit(fromUserId);
      if (!canSendLike) {
        throw Exception('일일 호감 표시 제한을 초과했습니다. (${_dailyLikeLimit}회)');
      }

      // 2. 중복 확인
      final existingLike = await _getLikeBetweenUsers(fromUserId, toProfileId);
      if (existingLike != null) {
        throw Exception('이미 호감을 표시한 사용자입니다.');
      }

      // 3. 호감 데이터 생성
      final now = DateTime.now();
      final likeData = {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'LIKE',
        'message': message,
        'isMatched': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // 4. GraphQL 뮤테이션 실행
      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateLike(\$input: CreateLikeInput!) {
            createLike(input: \$input) {
              id
              fromUserId
              toProfileId
              likeType
              message
              isMatched
              createdAt
              updatedAt
            }
          }
        ''',
        variables: {'input': likeData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('호감 표시 실패: ${response.errors.first.message}');
      }

      // 5. 일일 카운트 증가
      await _incrementDailyLikeCount();

      // 6. 매칭 확인 및 생성 (AWS 매칭 서비스 사용)
      MatchModel? newMatch;
      bool isMatched = false;
      
      try {
        newMatch = await _matchService.checkAndCreateMatch(
          fromUserId: fromUserId,
          toUserId: toProfileId,
        );
        
        if (newMatch != null) {
          isMatched = true;
          
          // 호감 데이터를 매칭 상태로 업데이트
          if (response.data != null) {
            final likeJson = _parseGraphQLResponse(response.data!);
            final likeId = likeJson['createLike']?['id'];
            if (likeId != null) {
              await _updateMatchStatus(likeId, true);
            }
          }
          
          Logger.log('새 매칭 생성됨: ${newMatch.id}', name: 'AWSLikesService');
        }
      } catch (e) {
        Logger.error('매칭 확인 오류', error: e, name: 'AWSLikesService');
        // 매칭 실패해도 호감 표시는 유지
      }

      // 7. 프로필 호감 수 증가
      await _incrementProfileLikeCount(toProfileId);

      // 8. 알림 전송
      try {
        if (!isMatched) {
          // 호감 받음 알림 전송 (상대방에게) - 매칭 알림은 매칭 서비스에서 처리됨
          await _notificationService.showLikeReceivedNotification(
            fromUserName: 'Unknown User', // 실제로는 프로필 정보에서 가져와야 함
            fromUserId: fromUserId,
            message: message,
            isSuperChat: message != null,
          );
        }
      } catch (e) {
        Logger.error('알림 전송 오류', error: e, name: 'AWSLikesService');
        // 알림 실패는 전체 프로세스를 중단시키지 않음
      }

      if (response.data != null) {
        final likeJson = _parseGraphQLResponse(response.data!);
        final likeData = likeJson['createLike'];
        if (likeData != null) {
          final like = LikeModel.fromJson(likeData);
          return like.copyWith(isMatched: isMatched);
        }
      }

      return null;
    } catch (e) {
      Logger.error('호감 표시 오류', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }

  /// 패스하기
  Future<LikeModel?> sendPass({
    required String fromUserId,
    required String toProfileId,
  }) async {
    try {
      // 1. 중복 확인
      final existingLike = await _getLikeBetweenUsers(fromUserId, toProfileId);
      if (existingLike != null) {
        throw Exception('이미 반응을 표시한 사용자입니다.');
      }

      // 2. 패스 데이터 생성
      final now = DateTime.now();
      final passData = {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'PASS',
        'isMatched': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // 3. GraphQL 뮤테이션 실행
      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateLike(\$input: CreateLikeInput!) {
            createLike(input: \$input) {
              id
              fromUserId
              toProfileId
              likeType
              message
              isMatched
              createdAt
              updatedAt
            }
          }
        ''',
        variables: {'input': passData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('패스 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final likeJson = _parseGraphQLResponse(response.data!);
        final likeData = likeJson['createLike'];
        if (likeData != null) {
          return LikeModel.fromJson(likeData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('패스 오류', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }

  /// 받은 호감 목록 조회
  Future<List<LikeModel>> getReceivedLikes({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetReceivedLikes(\$toProfileId: String!, \$limit: Int, \$nextToken: String) {
            likesByToProfileId(toProfileId: \$toProfileId, limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                fromUserId
                toProfileId
                likeType
                message
                isMatched
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
        throw Exception('받은 호감 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['likesByToProfileId']?['items'] as List?;
        if (items != null) {
          return items
              .where((item) => item['likeType'] == 'LIKE')
              .map((item) => LikeModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.error('받은 호감 조회 오류', error: e, name: 'AWSLikesService');
      return [];
    }
  }

  /// 보낸 호감 목록 조회
  Future<List<LikeModel>> getSentLikes({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetSentLikes(\$fromUserId: String!, \$limit: Int, \$nextToken: String) {
            likesByFromUserId(fromUserId: \$fromUserId, limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                fromUserId
                toProfileId
                likeType
                message
                isMatched
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
        throw Exception('보낸 호감 조회 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['likesByFromUserId']?['items'] as List?;
        if (items != null) {
          return items
              .map((item) => LikeModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.error('보낸 호감 조회 오류', error: e, name: 'AWSLikesService');
      return [];
    }
  }

  /// 매칭된 사용자 목록 조회
  Future<List<LikeModel>> getMatches({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      // 내가 보낸 호감 중 매칭된 것들
      final sentMatches = await getSentLikes(userId: userId, limit: limit, nextToken: nextToken);
      final receivedMatches = await getReceivedLikes(userId: userId, limit: limit, nextToken: nextToken);
      
      // 매칭된 것들만 필터링
      final allMatches = <LikeModel>[];
      allMatches.addAll(sentMatches.where((like) => like.isMatched));
      allMatches.addAll(receivedMatches.where((like) => like.isMatched));
      
      // 중복 제거 (같은 매칭이 양방향으로 존재할 수 있음)
      final uniqueMatches = <String, LikeModel>{};
      for (final match in allMatches) {
        final key = '${match.fromUserId}_${match.toProfileId}';
        final reverseKey = '${match.toProfileId}_${match.fromUserId}';
        
        if (!uniqueMatches.containsKey(key) && !uniqueMatches.containsKey(reverseKey)) {
          uniqueMatches[key] = match;
        }
      }
      
      return uniqueMatches.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      Logger.error('매칭 목록 조회 오류', error: e, name: 'AWSLikesService');
      return [];
    }
  }

  /// 일일 호감 표시 가능 횟수 확인
  Future<int> getRemainingDailyLikes(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      final lastDate = prefs.getString('${_lastLikeDateKey}_$userId') ?? '';
      final currentCount = prefs.getInt('${_likesCountKey}_$userId') ?? 0;
      
      // 날짜가 바뀌었으면 카운트 리셋
      if (lastDate != todayString) {
        await prefs.setString('${_lastLikeDateKey}_$userId', todayString);
        await prefs.setInt('${_likesCountKey}_$userId', 0);
        return _dailyLikeLimit;
      }
      
      return (_dailyLikeLimit - currentCount).clamp(0, _dailyLikeLimit);
    } catch (e) {
      Logger.error('일일 호감 표시 횟수 확인 오류', error: e, name: 'AWSLikesService');
      return 0;
    }
  }

  /// 사용자 간 호감 기록 조회 (중복 방지용)
  Future<LikeModel?> _getLikeBetweenUsers(String fromUserId, String toProfileId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetLikeBetweenUsers(\$fromUserId: String!, \$toProfileId: String!) {
            likesByFromUserId(fromUserId: \$fromUserId, filter: {toProfileId: {eq: \$toProfileId}}) {
              items {
                id
                fromUserId
                toProfileId
                likeType
                message
                isMatched
                createdAt
                updatedAt
              }
            }
          }
        ''',
        variables: {
          'fromUserId': fromUserId,
          'toProfileId': toProfileId,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        return null;
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['likesByFromUserId']?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return LikeModel.fromJson(items.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      Logger.error('사용자 간 호감 기록 조회 오류', error: e, name: 'AWSLikesService');
      return null;
    }
  }

  /// 일일 제한 확인
  Future<bool> _checkDailyLimit(String userId) async {
    final remaining = await getRemainingDailyLikes(userId);
    return remaining > 0;
  }

  /// 일일 호감 표시 카운트 증가
  Future<void> _incrementDailyLikeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = 'current_user'; // 실제로는 현재 사용자 ID 사용
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      await prefs.setString('${_lastLikeDateKey}_$userId', todayString);
      final currentCount = prefs.getInt('${_likesCountKey}_$userId') ?? 0;
      await prefs.setInt('${_likesCountKey}_$userId', currentCount + 1);
      
      Logger.log('일일 호감 표시 카운트 증가: ${currentCount + 1}/$_dailyLikeLimit', name: 'AWSLikesService');
    } catch (e) {
      Logger.error('일일 카운트 증가 오류', error: e, name: 'AWSLikesService');
    }
  }

  /// 매칭 상태 업데이트
  Future<void> _updateMatchStatus(String likeId, bool isMatched) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateLikeMatchStatus(\$input: UpdateLikeInput!) {
            updateLike(input: \$input) {
              id
              isMatched
              updatedAt
            }
          }
        ''',
        variables: {
          'input': {
            'id': likeId,
            'isMatched': isMatched,
            'updatedAt': DateTime.now().toIso8601String(),
          }
        },
      );

      await Amplify.API.mutate(request: request).response;
      Logger.log('매칭 상태 업데이트: $likeId -> $isMatched', name: 'AWSLikesService');
    } catch (e) {
      Logger.error('매칭 상태 업데이트 오류', error: e, name: 'AWSLikesService');
    }
  }

  /// 프로필 호감 수 증가
  Future<void> _incrementProfileLikeCount(String profileId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation IncrementProfileLikeCount(\$id: ID!) {
            incrementProfileLikeCount(id: \$id) {
              id
              likeCount
            }
          }
        ''',
        variables: {'id': profileId},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('프로필 호감 수 증가 오류', error: e, name: 'AWSLikesService');
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
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSLikesService');
      return {};
    }
  }
}