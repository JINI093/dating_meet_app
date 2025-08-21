import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../models/like_model.dart';
import '../models/profile_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';
import 'aws_profile_service.dart';

/// AWS 기반 호감 표시 서비스
/// DynamoDB를 통한 좋아요/패스 데이터 관리
class AWSLikesService {
  static final AWSLikesService _instance = AWSLikesService._internal();
  factory AWSLikesService() => _instance;
  AWSLikesService._internal();

  static const int _dailyLikeLimit = 20;
  static const String _likesCountKey = 'daily_likes_count';
  static const String _lastLikeDateKey = 'last_like_date';
  
  final ApiService _apiService = ApiService();
  final AWSProfileService _profileService = AWSProfileService();

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

  /// 호감 표시 (좋아요) - 서버사이드 처리
  Future<LikeModel?> sendLike({
    required String fromUserId,
    required String toProfileId,
    String? message,
  }) async {
    try {
      Logger.log('🚀 서버사이드 좋아요 전송 시작', name: 'AWSLikesService');
      Logger.log('   전송자: $fromUserId', name: 'AWSLikesService');
      Logger.log('   수신자: $toProfileId', name: 'AWSLikesService');

      // REST API를 통한 서버사이드 처리 (올바른 API Gateway 사용)
      final likesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            likesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('좋아요 API 토큰 추가 실패: $e', name: 'AWSLikesService');
      }
      
      final response = await likesApiService.post('/likes', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'LIKE',
        'message': message,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final likeData = response.data['data']['like'];
        final isMatch = response.data['data']['isMatch'] ?? false;
        final matchId = response.data['data']['matchId'];

        Logger.log('✅ 좋아요 전송 성공', name: 'AWSLikesService');
        Logger.log('   매칭 여부: $isMatch', name: 'AWSLikesService');
        Logger.log('   매치 ID: $matchId', name: 'AWSLikesService');
        Logger.log('   남은 일일 제한: ${response.data['data']['remaining']}', name: 'AWSLikesService');

        // SharedPreferences 업데이트 (로컬 캐시용)
        await _incrementDailyCount(fromUserId);

        // LikeModel 객체 생성
        final like = LikeModel.fromJson({
          'id': likeData['id'],
          'fromUserId': likeData['fromUserId'],
          'toProfileId': likeData['toProfileId'],
          'likeType': likeData['actionType'],
          'message': likeData['message'],
          'isMatched': isMatch,
          'matchId': matchId,
          'createdAt': likeData['createdAt'],
          'updatedAt': likeData['updatedAt'],
          'isRead': false,
        });

        return like;
      } else {
        final errorMessage = response.data['message'] ?? '좋아요 전송에 실패했습니다.';
        Logger.error('❌ 좋아요 전송 실패: $errorMessage', name: 'AWSLikesService');
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 좋아요 전송 중 오류 발생', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }


  /// 슈퍼챗 전송 (REST API)
  Future<LikeModel?> sendSuperchat({
    required String fromUserId,
    required String toProfileId,
    required String message,
    required int pointsUsed,
    String? templateType,
    Map<String, dynamic>? customData,
  }) async {
    try {
      Logger.log('🚀 REST API 슈퍼챗 전송 시작', name: 'AWSLikesService');
      Logger.log('   전송자: $fromUserId', name: 'AWSLikesService');
      Logger.log('   수신자: $toProfileId', name: 'AWSLikesService');
      Logger.log('   메시지: $message', name: 'AWSLikesService');
      Logger.log('   포인트: $pointsUsed', name: 'AWSLikesService');

      // REST API를 통한 슈퍼챗 전송
      final likesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            likesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('슈퍼챗 API 토큰 추가 실패: $e', name: 'AWSLikesService');
      }
      
      final response = await likesApiService.post('/superchats', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'message': message,
        'pointsUsed': pointsUsed,
        'templateType': templateType ?? 'CUSTOM',
        'customData': customData,
        'likeType': 'SUPERCHAT',
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final superchatData = response.data['data']['superchat'];
        final isMatch = response.data['data']['isMatch'] ?? false;
        final matchId = response.data['data']['matchId'];

        Logger.log('✅ 슈퍼챗 전송 성공', name: 'AWSLikesService');
        Logger.log('   매칭 여부: $isMatch', name: 'AWSLikesService');
        Logger.log('   매치 ID: $matchId', name: 'AWSLikesService');

        // LikeModel 객체 생성 (슈퍼챗을 Like 형태로 변환)
        final like = LikeModel.fromJson({
          'id': superchatData['id'],
          'fromUserId': superchatData['fromUserId'],
          'toProfileId': superchatData['toProfileId'],
          'likeType': 'SUPERCHAT',
          'message': superchatData['message'],
          'isMatched': isMatch,
          'matchId': matchId,
          'createdAt': superchatData['createdAt'],
          'updatedAt': superchatData['updatedAt'],
          'isRead': false,
          'pointsUsed': superchatData['pointsUsed'],
          'priority': superchatData['priority'],
          'templateType': superchatData['templateType'],
        });

        return like;
      } else {
        final errorMessage = response.data['message'] ?? '슈퍼챗 전송에 실패했습니다.';
        Logger.error('❌ 슈퍼챗 전송 실패: $errorMessage', name: 'AWSLikesService');
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 슈퍼챗 전송 중 오류 발생', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }

  /// 패스하기
  Future<LikeModel?> sendPass({
    required String fromUserId,
    required String toProfileId,
  }) async {
    try {
      Logger.log('🚀 REST API 패스 전송 시작', name: 'AWSLikesService');
      Logger.log('   전송자: $fromUserId', name: 'AWSLikesService');
      Logger.log('   수신자: $toProfileId', name: 'AWSLikesService');

      // REST API를 통한 패스 전송 (좋아요 API와 동일한 엔드포인트 사용)
      final likesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            likesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('패스 API 토큰 추가 실패: $e', name: 'AWSLikesService');
      }
      
      final response = await likesApiService.post('/likes', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'PASS', // 패스 타입으로 설정
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final passData = response.data['data']['like'];

        Logger.log('✅ 패스 전송 성공', name: 'AWSLikesService');

        // LikeModel 객체 생성
        final pass = LikeModel.fromJson({
          'id': passData['id'],
          'fromUserId': passData['fromUserId'],
          'toProfileId': passData['toProfileId'],
          'likeType': passData['actionType'] ?? 'PASS',
          'message': passData['message'],
          'isMatched': false, // 패스는 항상 매칭되지 않음
          'matchId': null,
          'createdAt': passData['createdAt'],
          'updatedAt': passData['updatedAt'],
          'isRead': false,
        });

        return pass;
      } else {
        final errorMessage = response.data['message'] ?? '패스 전송에 실패했습니다.';
        Logger.error('❌ 패스 전송 실패: $errorMessage', name: 'AWSLikesService');
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 패스 전송 중 오류 발생', error: e, name: 'AWSLikesService');
      rethrow;
    }
  }

  /// 받은 호감 목록 조회 - 단순화
  Future<List<LikeModel>> getReceivedLikes({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      Logger.log('🔍 받은 호감 조회 시작: $userId', name: 'AWSLikesService');
      Logger.log('📊 [디버깅] API 엔드포인트: /likes/$userId/received', name: 'AWSLikesService');
      
      // 올바른 API Gateway 사용
      final baseUrl = 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev';
      Logger.log('📊 [디버깅] API Base URL: $baseUrl', name: 'AWSLikesService');
      
      final likesApiService = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            likesApiService.options.headers['Authorization'] = 'Bearer $idToken';
            Logger.log('📊 [디버깅] JWT 토큰 추가됨 (길이: ${idToken.length})', name: 'AWSLikesService');
          } else {
            Logger.log('⚠️ JWT 토큰이 비어있음', name: 'AWSLikesService');
          }
        } else {
          Logger.log('⚠️ 세션 정보 없음 또는 로그인되지 않음', name: 'AWSLikesService');
        }
      } catch (e) {
        Logger.error('받은 좋아요 API 토큰 추가 실패: $e', name: 'AWSLikesService');
      }
      
      final response = await likesApiService.get('/likes/$userId/received');
      Logger.log('API 응답 상태: ${response.statusCode}', name: 'AWSLikesService');
      Logger.log('API 응답 데이터 타입: ${response.data.runtimeType}', name: 'AWSLikesService');
      Logger.log('API 응답 데이터: ${response.data}', name: 'AWSLikesService');
      
      // API Gateway가 Lambda 응답을 중첩시키는 경우 처리
      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('statusCode') && responseData.containsKey('body')) {
        final lambdaStatusCode = responseData['statusCode'];
        final lambdaBody = responseData['body'] is String 
            ? jsonDecode(responseData['body']) 
            : responseData['body'];
        
        Logger.log('Lambda 응답 상태: $lambdaStatusCode', name: 'AWSLikesService');
        Logger.log('Lambda 응답 본문: $lambdaBody', name: 'AWSLikesService');
        
        if (lambdaStatusCode == 200 && lambdaBody['success'] == true) {
          responseData = lambdaBody;
        } else {
          Logger.error('❌ Lambda 응답 실패', name: 'AWSLikesService');
          return [];
        }
      }
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> items = responseData['data'] ?? [];
        final likes = <LikeModel>[];
        
        for (final item in items) {
          // actionType을 likeType으로 매핑
          final mappedItem = Map<String, dynamic>.from(item);
          if (mappedItem['actionType'] != null && mappedItem['likeType'] == null) {
            mappedItem['likeType'] = mappedItem['actionType'];
          }
          
          // 프로필 정보 가져오기 (모든 좋아요에 대해)
          if (mappedItem['fromUserId'] != null) {
            try {
              final profile = await _profileService.getProfile(mappedItem['fromUserId']);
              if (profile != null) {
                mappedItem['profile'] = profile.toJson();
              }
            } catch (e) {
              Logger.error('프로필 정보 가져오기 실패: ${mappedItem['fromUserId']}', error: e, name: 'AWSLikesService');
            }
          }
          
          likes.add(LikeModel.fromJson(mappedItem));
        }
        
        Logger.log('✅ 받은 좋아요 ${likes.length}개 조회 성공', name: 'AWSLikesService');
        
        // 각 좋아요의 세부 정보 로그
        for (int i = 0; i < likes.length && i < 3; i++) {
          final like = likes[i];
          Logger.log('  - 좋아요 ${i+1}: ${like.profile?.name ?? "unknown"} (${like.likeType.name})', name: 'AWSLikesService');
        }
        if (likes.length > 3) {
          Logger.log('  - ... 및 ${likes.length - 3}개 더', name: 'AWSLikesService');
        }
        
        return likes;
      }
      
      Logger.log('⚠️  받은 좋아요 데이터 없음 - 응답 코드: ${response.statusCode}', name: 'AWSLikesService');
      Logger.log('⚠️  응답 내용: $responseData', name: 'AWSLikesService');
      return [];
    } catch (e) {
      Logger.error('❌ 받은 호감 조회 중 오류 발생', error: e, name: 'AWSLikesService');
      Logger.error('❌ 사용자 ID: $userId', name: 'AWSLikesService');
      if (e is DioException) {
        Logger.error('❌ HTTP 상태 코드: ${e.response?.statusCode}', name: 'AWSLikesService');
        Logger.error('❌ HTTP 응답 데이터: ${e.response?.data}', name: 'AWSLikesService');
      }
      return [];
    }
  }

  /// 보낸 호감 목록 조회 - 단순화
  Future<List<LikeModel>> getSentLikes({
    required String userId,
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      Logger.log('🔍 보낸 호감 조회 시작: $userId', name: 'AWSLikesService');
      
      // 올바른 API Gateway 사용
      final likesApiService = Dio(BaseOptions(
        baseUrl: 'https://wkj6fdmoyf.execute-api.ap-northeast-2.amazonaws.com/dev',
        headers: {'Content-Type': 'application/json'},
      ));
      
      // JWT 토큰 추가
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn && session.userPoolTokensResult.value != null) {
          final idToken = session.userPoolTokensResult.value!.idToken.raw;
          if (idToken.isNotEmpty) {
            likesApiService.options.headers['Authorization'] = 'Bearer $idToken';
          }
        }
      } catch (e) {
        Logger.error('보낸 좋아요 API 토큰 추가 실패: $e', name: 'AWSLikesService');
      }
      
      final response = await likesApiService.get('/likes/$userId');
      Logger.log('API 응답 상태: ${response.statusCode}', name: 'AWSLikesService');
      Logger.log('API 응답 데이터: ${response.data}', name: 'AWSLikesService');
      
      // API Gateway가 Lambda 응답을 중첩시키는 경우 처리
      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('statusCode') && responseData.containsKey('body')) {
        final lambdaStatusCode = responseData['statusCode'];
        final lambdaBody = responseData['body'] is String 
            ? jsonDecode(responseData['body']) 
            : responseData['body'];
        
        Logger.log('Lambda 응답 상태: $lambdaStatusCode', name: 'AWSLikesService');
        Logger.log('Lambda 응답 본문: $lambdaBody', name: 'AWSLikesService');
        
        if (lambdaStatusCode == 200 && lambdaBody['success'] == true) {
          responseData = lambdaBody;
        } else {
          Logger.error('❌ Lambda 응답 실패', name: 'AWSLikesService');
          return [];
        }
      }
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> items = responseData['data'] ?? [];
        final likes = <LikeModel>[];
        
        for (final item in items) {
          // actionType을 likeType으로 매핑
          final mappedItem = Map<String, dynamic>.from(item);
          if (mappedItem['actionType'] != null && mappedItem['likeType'] == null) {
            mappedItem['likeType'] = mappedItem['actionType'];
          }
          
          // 프로필 정보 가져오기 (모든 좋아요에 대해, toProfileId 기준)
          if (mappedItem['toProfileId'] != null) {
            try {
              var id12 = mappedItem['toProfileId'];
              print("--fafasfs ${id12}");
              final profile = await _profileService.getProfile(mappedItem['toProfileId']);
              if (profile != null) {
                mappedItem['profile'] = profile.toJson();
              }
            } catch (e) {
              Logger.error('프로필 정보 가져오기 실패: ${mappedItem['toProfileId']}', error: e, name: 'AWSLikesService');
            }
          }
          
          likes.add(LikeModel.fromJson(mappedItem));
        }
        
        Logger.log('✅ 보낸 좋아요 ${likes.length}개 조회 성공', name: 'AWSLikesService');
        return likes;
      }
      
      Logger.log('⚠️  보낸 좋아요 데이터 없음', name: 'AWSLikesService');
      return [];
      
    } catch (e) {
      Logger.error('❌ 보낸 호감 조회 중 오류 발생', error: e, name: 'AWSLikesService');
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


  /// 로컬 일일 카운트 증가 (캐시용)
  Future<void> _incrementDailyCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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



  /// GraphQL 응답 파싱
  Map<String, dynamic> _parseGraphQLResponse(String response) {
    try {
      if (response.startsWith('{') || response.startsWith('[')) {
        // String을 JSON으로 파싱
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          return {};
        }
      }
      return {};
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSLikesService');
      return {};
    }
  }
}