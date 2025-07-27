import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/like_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';

/// 강화된 AWS 기반 호감 표시 서비스
/// 서버사이드 검증 및 처리를 통한 안전한 좋아요/매칭 시스템
class EnhancedLikesService {
  static final EnhancedLikesService _instance = EnhancedLikesService._internal();
  factory EnhancedLikesService() => _instance;
  EnhancedLikesService._internal();

  static const int _dailyLikeLimit = 20;
  static const String _likesCountKey = 'daily_likes_count';
  static const String _lastLikeDateKey = 'last_like_date';
  
  final ApiService _apiService = ApiService();

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      Logger.log('✅ EnhancedLikesService 초기화 완료', name: 'EnhancedLikesService');
    } catch (e) {
      Logger.error('❌ EnhancedLikesService 초기화 실패', error: e, name: 'EnhancedLikesService');
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
      Logger.log('🚀 서버사이드 좋아요 전송 시작', name: 'EnhancedLikesService');
      Logger.log('   전송자: $fromUserId', name: 'EnhancedLikesService');
      Logger.log('   수신자: $toProfileId', name: 'EnhancedLikesService');

      // REST API를 통한 서버사이드 처리
      final response = await _apiService.post('/likes', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'LIKE',
        'message': message,
      });

      Logger.log('API 응답 상태: ${response.statusCode}', name: 'EnhancedLikesService');
      Logger.log('API 응답 데이터: ${response.data}', name: 'EnhancedLikesService');

      // API Gateway가 Lambda 응답을 중첩시키는 경우 처리
      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('statusCode') && responseData.containsKey('body')) {
        // Lambda 프록시 통합 응답 형식
        final lambdaStatusCode = responseData['statusCode'];
        final lambdaBody = responseData['body'] is String 
            ? jsonDecode(responseData['body']) 
            : responseData['body'];
        
        Logger.log('Lambda 응답 상태: $lambdaStatusCode', name: 'EnhancedLikesService');
        Logger.log('Lambda 응답 본문: $lambdaBody', name: 'EnhancedLikesService');
        
        if (lambdaStatusCode == 200 && lambdaBody['success'] == true) {
          responseData = lambdaBody;
        } else {
          final errorMessage = lambdaBody['message'] ?? '좋아요 전송에 실패했습니다.';
          Logger.error('❌ Lambda 응답 실패: $errorMessage', name: 'EnhancedLikesService');
          throw Exception(errorMessage);
        }
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final likeData = responseData['data']['like'];
        final isMatch = responseData['data']['isMatch'] ?? false;

        Logger.log('✅ 좋아요 전송 성공', name: 'EnhancedLikesService');
        Logger.log('   매칭 여부: $isMatch', name: 'EnhancedLikesService');
        Logger.log('   남은 일일 제한: ${responseData['data']['remaining']}', name: 'EnhancedLikesService');

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
          'createdAt': likeData['createdAt'],
          'updatedAt': likeData['updatedAt'],
          'isRead': false,
        });

        return like;
      } else {
        final errorMessage = response.data['message'] ?? '좋아요 전송에 실패했습니다.';
        Logger.error('❌ 좋아요 전송 실패: $errorMessage', name: 'EnhancedLikesService');
        Logger.error('실패 응답 전체: ${response.data}', name: 'EnhancedLikesService');
        
        // Lambda 함수가 배포되지 않았거나 런타임 오류가 있는 경우 fallback 처리
        if (response.statusCode == 200 && (
            response.data['message']?.contains('찾을 수 없습니다') == true || 
            response.data['message']?.contains('경로를 찾을 수 없습니다') == true ||
            response.data['errorType'] == 'Error' ||
            response.data['errorType'] == 'Runtime.ImportModuleError' ||
            response.data['errorMessage']?.contains('Cannot find package') == true ||
            response.data['errorMessage']?.contains('Cannot find module') == true ||
            response.data['errorMessage']?.contains('uuid') == true)) {
          Logger.log('⚠️  Lambda 함수 오류 (모듈/의존성 미설치), 로컬 처리로 fallback', name: 'EnhancedLikesService');
          
          // SharedPreferences 업데이트 (로컬 캐시용)
          await _incrementDailyCount(fromUserId);
          
          // 로컬에서 임시 좋아요 객체 생성
          final now = DateTime.now();
          final tempLike = LikeModel(
            id: 'temp_like_${now.millisecondsSinceEpoch}',
            fromUserId: fromUserId,
            toProfileId: toProfileId,
            likeType: LikeType.like,
            message: message,
            isMatched: false,
            createdAt: now,
            updatedAt: now,
            isRead: false,
          );
          
          return tempLike;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 좋아요 전송 중 오류 발생', error: e, name: 'EnhancedLikesService');
      
      // 502 에러나 네트워크 오류 시 로컬 fallback 처리
      if (e.toString().contains('502') || e.toString().contains('network')) {
        Logger.log('⚠️  서버 연결 실패, 로컬 처리로 fallback', name: 'EnhancedLikesService');
        
        // SharedPreferences 업데이트 (로컬 캐시용)
        await _incrementDailyCount(fromUserId);
        
        // 로컬에서 임시 좋아요 객체 생성
        final now = DateTime.now();
        final tempLike = LikeModel(
          id: 'temp_like_${now.millisecondsSinceEpoch}',
          fromUserId: fromUserId,
          toProfileId: toProfileId,
          likeType: LikeType.like,
          message: message,
          isMatched: false,
          createdAt: now,
          updatedAt: now,
          isRead: false,
        );
        
        return tempLike;
      }
      
      rethrow;
    }
  }

  /// 패스 처리 - 서버사이드
  Future<LikeModel?> sendPass({
    required String fromUserId,
    required String toProfileId,
  }) async {
    try {
      Logger.log('🚀 패스 전송 시작', name: 'EnhancedLikesService');

      final response = await _apiService.post('/likes', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'likeType': 'PASS',
      });

      Logger.log('PASS API 응답 상태: ${response.statusCode}', name: 'EnhancedLikesService');
      Logger.log('PASS API 응답 데이터: ${response.data}', name: 'EnhancedLikesService');

      // API Gateway가 Lambda 응답을 중첩시키는 경우 처리
      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('statusCode') && responseData.containsKey('body')) {
        // Lambda 프록시 통합 응답 형식
        final lambdaStatusCode = responseData['statusCode'];
        final lambdaBody = responseData['body'] is String 
            ? jsonDecode(responseData['body']) 
            : responseData['body'];
        
        Logger.log('Lambda 응답 상태: $lambdaStatusCode', name: 'EnhancedLikesService');
        Logger.log('Lambda 응답 본문: $lambdaBody', name: 'EnhancedLikesService');
        
        if (lambdaStatusCode == 200 && lambdaBody['success'] == true) {
          responseData = lambdaBody;
        } else {
          final errorMessage = lambdaBody['message'] ?? '패스 전송에 실패했습니다.';
          Logger.error('❌ Lambda 응답 실패: $errorMessage', name: 'EnhancedLikesService');
          throw Exception(errorMessage);
        }
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final likeData = responseData['data']['like'];

        Logger.log('✅ 패스 전송 성공', name: 'EnhancedLikesService');

        final like = LikeModel.fromJson({
          'id': likeData['id'],
          'fromUserId': likeData['fromUserId'],
          'toProfileId': likeData['toProfileId'],
          'likeType': likeData['actionType'],
          'message': null,
          'isMatched': false,
          'createdAt': likeData['createdAt'],
          'updatedAt': likeData['updatedAt'],
          'isRead': false,
        });

        return like;
      } else {
        final errorMessage = response.data['message'] ?? '패스 전송에 실패했습니다.';
        Logger.error('❌ 패스 전송 실패: $errorMessage', name: 'EnhancedLikesService');
        Logger.error('PASS 실패 응답 전체: ${response.data}', name: 'EnhancedLikesService');
        
        // Lambda 함수가 배포되지 않았거나 런타임 오류가 있는 경우 fallback 처리
        if (response.statusCode == 200 && (
            response.data['message']?.contains('찾을 수 없습니다') == true || 
            response.data['message']?.contains('경로를 찾을 수 없습니다') == true ||
            response.data['errorType'] == 'Error' ||
            response.data['errorType'] == 'Runtime.ImportModuleError' ||
            response.data['errorMessage']?.contains('Cannot find package') == true ||
            response.data['errorMessage']?.contains('Cannot find module') == true ||
            response.data['errorMessage']?.contains('uuid') == true)) {
          Logger.log('⚠️  Lambda 함수 오류 (모듈/의존성 미설치), 로컬 처리로 fallback', name: 'EnhancedLikesService');
          
          // 로컬에서 임시 패스 객체 생성
          final now = DateTime.now();
          final tempLike = LikeModel(
            id: 'temp_pass_${now.millisecondsSinceEpoch}',
            fromUserId: fromUserId,
            toProfileId: toProfileId,
            likeType: LikeType.pass,
            message: null,
            isMatched: false,
            createdAt: now,
            updatedAt: now,
            isRead: false,
          );
          
          return tempLike;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 패스 전송 중 오류 발생', error: e, name: 'EnhancedLikesService');
      
      // 502 에러나 네트워크 오류 시 로컬 fallback 처리
      if (e.toString().contains('502') || e.toString().contains('network')) {
        Logger.log('⚠️  서버 연결 실패, 로컬 처리로 fallback', name: 'EnhancedLikesService');
        
        // 로컬에서 임시 패스 객체 생성
        final now = DateTime.now();
        final tempLike = LikeModel(
          id: 'temp_pass_${now.millisecondsSinceEpoch}',
          fromUserId: fromUserId,
          toProfileId: toProfileId,
          likeType: LikeType.pass,
          message: null,
          isMatched: false,
          createdAt: now,
          updatedAt: now,
          isRead: false,
        );
        
        return tempLike;
      }
      
      rethrow;
    }
  }

  /// 일일 제한 조회 - 서버사이드
  Future<Map<String, dynamic>> getDailyLimitStatus(String userId) async {
    try {
      final response = await _apiService.get('/likes/$userId/daily-limit');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '일일 제한 조회 실패');
      }
    } catch (e) {
      Logger.error('❌ 일일 제한 조회 중 오류 발생', error: e, name: 'EnhancedLikesService');
      rethrow;
    }
  }

  /// 받은 좋아요 조회 - 서버사이드
  Future<List<LikeModel>> getReceivedLikes(String userId) async {
    try {
      final response = await _apiService.get('/likes/$userId/received');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final likesData = response.data['data']['likes'] as List;
        return likesData.map((likeJson) => LikeModel.fromJson(likeJson)).toList();
      } else {
        throw Exception(response.data['message'] ?? '받은 좋아요 조회 실패');
      }
    } catch (e) {
      Logger.error('❌ 받은 좋아요 조회 중 오류 발생', error: e, name: 'EnhancedLikesService');
      return [];
    }
  }

  /// 로컬 일일 카운트 증가 (캐시용)
  Future<void> _incrementDailyCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastLikeDateKey$userId') ?? '';
      
      if (lastDate == today) {
        final currentCount = prefs.getInt('$_likesCountKey$userId') ?? 0;
        await prefs.setInt('$_likesCountKey$userId', currentCount + 1);
      } else {
        await prefs.setString('$_lastLikeDateKey$userId', today);
        await prefs.setInt('$_likesCountKey$userId', 1);
      }
    } catch (e) {
      Logger.error('로컬 일일 카운트 업데이트 실패', error: e, name: 'EnhancedLikesService');
    }
  }

  /// 로컬 일일 제한 확인 (캐시용, 서버사이드 검증 전 빠른 체크)
  Future<bool> checkLocalDailyLimit(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastLikeDateKey$userId') ?? '';
      
      if (lastDate != today) {
        return true; // 새로운 날이므로 제한 없음
      }
      
      final currentCount = prefs.getInt('$_likesCountKey$userId') ?? 0;
      return currentCount < _dailyLikeLimit;
    } catch (e) {
      Logger.error('로컬 일일 제한 확인 실패', error: e, name: 'EnhancedLikesService');
      return true; // 오류 시 허용
    }
  }

  /// 남은 일일 좋아요 수 확인 (로컬)
  Future<int> getRemainingDailyLikes(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastLikeDateKey$userId') ?? '';
      
      if (lastDate != today) {
        return _dailyLikeLimit; // 새로운 날이므로 전체 제한 수
      }
      
      final currentCount = prefs.getInt('$_likesCountKey$userId') ?? 0;
      return (_dailyLikeLimit - currentCount).clamp(0, _dailyLikeLimit);
    } catch (e) {
      Logger.error('남은 일일 좋아요 수 확인 실패', error: e, name: 'EnhancedLikesService');
      return _dailyLikeLimit;
    }
  }
}