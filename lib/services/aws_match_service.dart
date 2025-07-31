import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../models/like_model.dart';
import '../models/match_model.dart';
import '../models/profile_model.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'aws_profile_service.dart';

/// AWS 기반 매칭 서비스
/// 상호 호감 시 매칭 생성 및 관리
class AWSMatchService {
  static final AWSMatchService _instance = AWSMatchService._internal();
  factory AWSMatchService() => _instance;
  AWSMatchService._internal();

  final NotificationService _notificationService = NotificationService();
  final AWSProfileService _profileService = AWSProfileService();
  static const String _lastMatchCheckKey = 'last_match_check';

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      Logger.log('✅ AWSMatchService 초기화 완료', name: 'AWSMatchService');
    } catch (e) {
      Logger.error('❌ AWSMatchService 초기화 실패', error: e, name: 'AWSMatchService');
      rethrow;
    }
  }

  /// 호감 표시 후 매칭 확인 및 생성
  Future<MatchModel?> checkAndCreateMatch({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      // 1. 상호 호감 확인
      final isMatch = await _checkMutualLike(fromUserId, toUserId);
      if (!isMatch) {
        Logger.log('상호 호감 아님: $fromUserId -> $toUserId', name: 'AWSMatchService');
        return null;
      }

      // 2. 기존 매칭 확인
      final existingMatch = await _getExistingMatch(fromUserId, toUserId);
      if (existingMatch != null) {
        Logger.log('이미 매칭됨: ${existingMatch.id}', name: 'AWSMatchService');
        return existingMatch;
      }

      // 3. 새로운 매칭 생성
      final newMatch = await _createMatch(fromUserId, toUserId);
      if (newMatch != null) {
        // 4. 매칭 알림 전송
        await _sendMatchNotifications(newMatch, fromUserId, toUserId);
      }

      return newMatch;
    } catch (e) {
      Logger.error('매칭 확인 및 생성 오류', error: e, name: 'AWSMatchService');
      return null;
    }
  }

  /// 사용자의 매칭 목록 조회
  Future<List<MatchModel>> getUserMatches({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      Logger.log('🔍 매칭 목록 조회 시작: $userId', name: 'AWSMatchService');
      
      // REST API를 통한 매칭 목록 조회
      final matchesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            matchesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('매칭 API 토큰 추가 실패: $e', name: 'AWSMatchService');
      }
      
      final response = await matchesApiService.get('/matches/user/$userId');
      Logger.log('매칭 API 응답 상태: ${response.statusCode}', name: 'AWSMatchService');
      Logger.log('매칭 API 응답 데이터: ${response.data}', name: 'AWSMatchService');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> items = response.data['data'] ?? [];
        final matches = <MatchModel>[];
        
        for (final item in items) {
          final matchData = Map<String, dynamic>.from(item);
          
          // 상대방 프로필 정보 조회
          final otherUserId = matchData['user1Id'] == userId 
              ? matchData['user2Id'] 
              : matchData['user1Id'];
          
          ProfileModel? otherProfile;
          try {
            otherProfile = await _profileService.getProfile(otherUserId);
          } catch (e) {
            Logger.error('프로필 정보 가져오기 실패: $otherUserId', error: e, name: 'AWSMatchService');
            otherProfile = ProfileModel.empty();
          }
          
          // 매칭 모델 생성
          final match = MatchModel(
            id: matchData['id'] ?? '',
            profile: otherProfile ?? ProfileModel.empty(),
            matchedAt: DateTime.tryParse(matchData['createdAt'] ?? '') ?? DateTime.now(),
            lastMessage: matchData['lastMessage'],
            lastMessageTime: DateTime.tryParse(matchData['lastMessageTime'] ?? matchData['lastMessageAt'] ?? ''),
            hasUnreadMessages: _getUnreadCount(matchData, userId) > 0,
            unreadCount: _getUnreadCount(matchData, userId),
            status: _parseMatchStatus(matchData['status']),
            type: MatchType.regular, // 단순화
          );
          
          matches.add(match);
        }
        
        Logger.log('✅ 매칭 목록 ${matches.length}개 조회 성공', name: 'AWSMatchService');
        return matches;
      }
      
      Logger.log('⚠️  매칭 목록 데이터 없음', name: 'AWSMatchService');
      return [];
    } catch (e) {
      Logger.error('매칭 목록 조회 오류', error: e, name: 'AWSMatchService');
      return [];
    }
  }

  /// 특정 매칭 정보 조회
  Future<MatchModel?> getMatch({
    required String matchId,
    required String currentUserId,
  }) async {
    try {
      Logger.log('🔍 매칭 상세 조회 시작: $matchId', name: 'AWSMatchService');
      
      // REST API를 통한 매칭 상세 조회
      final matchesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            matchesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('매칭 상세 API 토큰 추가 실패: $e', name: 'AWSMatchService');
      }
      
      final response = await matchesApiService.get('/matches/$matchId');
      Logger.log('매칭 상세 API 응답 상태: ${response.statusCode}', name: 'AWSMatchService');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final matchData = Map<String, dynamic>.from(response.data['data']);
        
        // 상대방 프로필 정보 조회
        final otherUserId = matchData['user1Id'] == currentUserId 
            ? matchData['user2Id'] 
            : matchData['user1Id'];
        
        ProfileModel? otherProfile;
        try {
          otherProfile = await _profileService.getProfile(otherUserId);
        } catch (e) {
          Logger.error('프로필 정보 가져오기 실패: $otherUserId', error: e, name: 'AWSMatchService');
          otherProfile = ProfileModel.empty();
        }
        
        final match = MatchModel(
          id: matchData['id'] ?? '',
          profile: otherProfile ?? ProfileModel.empty(),
          matchedAt: DateTime.tryParse(matchData['createdAt'] ?? '') ?? DateTime.now(),
          lastMessage: matchData['lastMessage'],
          lastMessageTime: DateTime.tryParse(matchData['lastMessageTime'] ?? matchData['lastMessageAt'] ?? ''),
          hasUnreadMessages: _getUnreadCount(matchData, currentUserId) > 0,
          unreadCount: _getUnreadCount(matchData, currentUserId),
          status: _parseMatchStatus(matchData['status']),
          type: MatchType.regular,
        );
        
        Logger.log('✅ 매칭 상세 조회 성공: $matchId', name: 'AWSMatchService');
        return match;
      }

      return null;
    } catch (e) {
      Logger.error('매칭 조회 오류', error: e, name: 'AWSMatchService');
      return null;
    }
  }

  /// 매칭 상태 업데이트
  Future<bool> updateMatchStatus({
    required String matchId,
    required MatchStatus status,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateMatchStatus(\$input: UpdateMatchInput!) {
            updateMatch(input: \$input) {
              id
              status
              updatedAt
            }
          }
        ''',
        variables: {
          'input': {
            'id': matchId,
            'status': _matchStatusToString(status),
            'updatedAt': DateTime.now().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('매칭 상태 업데이트 실패: ${response.errors.first.message}');
      }

      Logger.log('매칭 상태 업데이트: $matchId -> $status', name: 'AWSMatchService');
      return true;
    } catch (e) {
      Logger.error('매칭 상태 업데이트 오류', error: e, name: 'AWSMatchService');
      return false;
    }
  }

  /// 매칭 차단
  Future<bool> blockMatch({
    required String matchId,
    required String blockingUserId,
  }) async {
    try {
      // 1. 매칭 상태를 차단으로 변경
      final statusUpdated = await updateMatchStatus(
        matchId: matchId,
        status: MatchStatus.blocked,
      );

      if (!statusUpdated) {
        return false;
      }

      // 2. 차단 기록 생성
      await _createBlockRecord(matchId, blockingUserId);

      Logger.log('매칭 차단 완료: $matchId by $blockingUserId', name: 'AWSMatchService');
      return true;
    } catch (e) {
      Logger.error('매칭 차단 오류', error: e, name: 'AWSMatchService');
      return false;
    }
  }

  /// 새로운 매칭 확인 (백그라운드 폴링용)
  Future<List<MatchModel>> checkForNewMatches(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTime = prefs.getString('${_lastMatchCheckKey}_$userId');
      final checkSince = lastCheckTime != null 
          ? DateTime.parse(lastCheckTime)
          : DateTime.now().subtract(const Duration(hours: 24));

      final request = GraphQLRequest<String>(
        document: '''
          query GetNewMatches(\$userId: String!, \$since: String!) {
            matchesByUserId(
              userId: \$userId,
              filter: {
                createdAt: {gte: \$since}
              }
            ) {
              items {
                id
                user1Id
                user2Id
                createdAt
                lastMessageAt
                lastMessage
                status
                unreadCount1
                unreadCount2
                metadata
              }
            }
          }
        ''',
        variables: {
          'userId': userId,
          'since': checkSince.toIso8601String(),
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('새 매칭 확인 실패: ${response.errors.first.message}');
      }

      final newMatches = <MatchModel>[];
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['matchesByUserId']?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          for (final item in items) {
            final matchData = item as Map<String, dynamic>;
            final otherUserId = matchData['user1Id'] == userId 
                ? matchData['user2Id'] 
                : matchData['user1Id'];
            final otherProfile = await _getUserProfile(otherUserId);
            
            final match = MatchModel(
              id: matchData['id'] ?? '',
              profile: otherProfile ?? ProfileModel.empty(),
              matchedAt: DateTime.tryParse(matchData['createdAt'] ?? '') ?? DateTime.now(),
              lastMessage: matchData['lastMessage'],
              lastMessageTime: DateTime.tryParse(matchData['lastMessageAt'] ?? ''),
              hasUnreadMessages: _getUnreadCount(matchData, userId) > 0,
              unreadCount: _getUnreadCount(matchData, userId),
              status: _parseMatchStatus(matchData['status']),
              type: _parseMatchType(matchData['metadata']),
            );
            
            newMatches.add(match);
          }
        }
      }

      // 마지막 확인 시간 업데이트
      await prefs.setString('${_lastMatchCheckKey}_$userId', DateTime.now().toIso8601String());

      Logger.log('새 매칭 ${newMatches.length}개 발견', name: 'AWSMatchService');
      return newMatches;
    } catch (e) {
      Logger.error('새 매칭 확인 오류', error: e, name: 'AWSMatchService');
      return [];
    }
  }

  /// 상호 호감 확인
  Future<bool> _checkMutualLike(String user1Id, String user2Id) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query CheckMutualLike(\$user1Id: String!, \$user2Id: String!) {
            likesByFromUserId(fromUserId: \$user1Id, filter: {toProfileId: {eq: \$user2Id}}) {
              items {
                id
                type
              }
            }
            likesByFromUserId(fromUserId: \$user2Id, filter: {toProfileId: {eq: \$user1Id}}) {
              items {
                id
                type
              }
            }
          }
        ''',
        variables: {
          'user1Id': user1Id,
          'user2Id': user2Id,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        Logger.error('상호 호감 확인 실패: ${response.errors.first.message}', name: 'AWSMatchService');
        return false;
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        
        // 양방향 호감 모두 확인
        final like1to2 = data['likesByFromUserId']?[0]?['items'] as List?;
        final like2to1 = data['likesByFromUserId']?[1]?['items'] as List?;
        
        final hasLike1to2 = like1to2 != null && like1to2.isNotEmpty && 
            like1to2.any((like) => like['type'] == 'LIKE');
        final hasLike2to1 = like2to1 != null && like2to1.isNotEmpty && 
            like2to1.any((like) => like['type'] == 'LIKE');
        
        return hasLike1to2 && hasLike2to1;
      }

      return false;
    } catch (e) {
      Logger.error('상호 호감 확인 오류', error: e, name: 'AWSMatchService');
      return false;
    }
  }

  /// 기존 매칭 확인
  Future<MatchModel?> _getExistingMatch(String user1Id, String user2Id) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetExistingMatch(\$user1Id: String!, \$user2Id: String!) {
            matchesByUsers(
              filter: {
                or: [
                  {and: [{user1Id: {eq: \$user1Id}}, {user2Id: {eq: \$user2Id}}]},
                  {and: [{user1Id: {eq: \$user2Id}}, {user2Id: {eq: \$user1Id}}]}
                ]
              }
            ) {
              items {
                id
                user1Id
                user2Id
                createdAt
                status
              }
            }
          }
        ''',
        variables: {
          'user1Id': user1Id,
          'user2Id': user2Id,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['matchesByUsers']?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final matchData = items.first as Map<String, dynamic>;
          final currentUserId = user1Id; // 호출자 기준
          final otherUserId = matchData['user1Id'] == currentUserId 
              ? matchData['user2Id'] 
              : matchData['user1Id'];
          final otherProfile = await _getUserProfile(otherUserId);
          
          return MatchModel(
            id: matchData['id'],
            profile: otherProfile ?? ProfileModel.empty(),
            matchedAt: DateTime.parse(matchData['createdAt']),
            status: _parseMatchStatus(matchData['status']),
          );
        }
      }

      return null;
    } catch (e) {
      Logger.error('기존 매칭 확인 오류', error: e, name: 'AWSMatchService');
      return null;
    }
  }

  /// 새로운 매칭 생성
  Future<MatchModel?> _createMatch(String user1Id, String user2Id) async {
    try {
      final now = DateTime.now();
      final matchData = {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'createdAt': now.toIso8601String(),
        'lastMessageAt': now.toIso8601String(),
        'status': 'ACTIVE',
        'unreadCount1': 0,
        'unreadCount2': 0,
        'metadata': {
          'matchType': 'REGULAR',
          'source': 'MUTUAL_LIKE',
        },
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateMatch(\$input: CreateMatchInput!) {
            createMatch(input: \$input) {
              id
              user1Id
              user2Id
              createdAt
              lastMessageAt
              status
              unreadCount1
              unreadCount2
              metadata
            }
          }
        ''',
        variables: {'input': matchData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('매칭 생성 실패: ${response.errors.first.message}');
      }

      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final createdMatch = data['createMatch'];
        if (createdMatch != null) {
          // 두 사용자의 프로필 조회
          final user1Profile = await _getUserProfile(user1Id);
          final user2Profile = await _getUserProfile(user2Id);
          
          Logger.log('새 매칭 생성: ${createdMatch['id']}', name: 'AWSMatchService');
          
          // 호출자(user1) 기준으로 매칭 모델 반환
          return MatchModel(
            id: createdMatch['id'],
            profile: user2Profile ?? ProfileModel.empty(),
            matchedAt: DateTime.parse(createdMatch['createdAt']),
            status: MatchStatus.active,
            type: MatchType.regular,
          );
        }
      }

      return null;
    } catch (e) {
      Logger.error('매칭 생성 오류', error: e, name: 'AWSMatchService');
      return null;
    }
  }

  /// 매칭 알림 전송
  Future<void> _sendMatchNotifications(MatchModel match, String user1Id, String user2Id) async {
    try {
      // 두 사용자 모두에게 매칭 알림 전송
      final user1Profile = await _getUserProfile(user1Id);
      final user2Profile = await _getUserProfile(user2Id);

      if (user1Profile != null && user2Profile != null) {
        // user1에게 알림
        await _notificationService.showMatchNotification(
          matchUserName: user2Profile.name,
          matchUserId: user2Id,
        );

        // user2에게 알림
        await _notificationService.showMatchNotification(
          matchUserName: user1Profile.name,
          matchUserId: user1Id,
        );
      }
    } catch (e) {
      Logger.error('매칭 알림 전송 오류', error: e, name: 'AWSMatchService');
    }
  }

  /// 차단 기록 생성
  Future<void> _createBlockRecord(String matchId, String blockingUserId) async {
    try {
      final blockData = {
        'matchId': matchId,
        'blockingUserId': blockingUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'reason': 'USER_BLOCKED',
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateBlockRecord(\$input: CreateBlockInput!) {
            createBlock(input: \$input) {
              id
              matchId
              blockingUserId
              createdAt
            }
          }
        ''',
        variables: {'input': blockData},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('차단 기록 생성 오류', error: e, name: 'AWSMatchService');
    }
  }

  /// 사용자 프로필 조회
  Future<ProfileModel?> _getUserProfile(String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetUserProfile(\$userId: String!) {
            getProfile(userId: \$userId) {
              id
              userId
              name
              age
              gender
              location
              bio
              photos
              interests
              occupation
              education
              height
              religion
              smoking
              drinking
              profileImageUrl
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isEmpty && response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final profileData = data['getProfile'];
        if (profileData != null) {
          return ProfileModel.fromJson(profileData);
        }
      }

      return null;
    } catch (e) {
      Logger.error('사용자 프로필 조회 오류', error: e, name: 'AWSMatchService');
      return null;
    }
  }

  /// Helper methods
  int _getUnreadCount(Map<String, dynamic> matchData, String userId) {
    if (matchData['user1Id'] == userId) {
      return matchData['unreadCount1'] ?? 0;
    } else if (matchData['user2Id'] == userId) {
      return matchData['unreadCount2'] ?? 0;
    }
    return 0;
  }

  MatchStatus _parseMatchStatus(dynamic status) {
    if (status == null) return MatchStatus.active;
    switch (status.toString().toUpperCase()) {
      case 'ACTIVE':
        return MatchStatus.active;
      case 'ARCHIVED':
        return MatchStatus.archived;
      case 'BLOCKED':
        return MatchStatus.blocked;
      default:
        return MatchStatus.active;
    }
  }

  MatchType _parseMatchType(dynamic metadata) {
    if (metadata is Map<String, dynamic>) {
      final matchType = metadata['matchType']?.toString();
      if (matchType == 'SUPER_CHAT') {
        return MatchType.superChat;
      }
    }
    return MatchType.regular;
  }

  String _matchStatusToString(MatchStatus status) {
    switch (status) {
      case MatchStatus.active:
        return 'ACTIVE';
      case MatchStatus.archived:
        return 'ARCHIVED';
      case MatchStatus.blocked:
        return 'BLOCKED';
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
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSMatchService');
      return {};
    }
  }
}