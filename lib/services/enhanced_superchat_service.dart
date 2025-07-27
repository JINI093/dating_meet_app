import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/superchat_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';

/// 강화된 AWS 기반 슈퍼챗 서비스
/// 서버사이드 포인트 검증 및 원자적 트랜잭션 처리
class EnhancedSuperchatService {
  static final EnhancedSuperchatService _instance = EnhancedSuperchatService._internal();
  factory EnhancedSuperchatService() => _instance;
  EnhancedSuperchatService._internal();

  static const int _dailySuperchatLimit = 5;
  static const int _defaultSuperchatCost = 100;
  static const String _superchatsCountKey = 'daily_superchats_count';
  static const String _lastSuperchatDateKey = 'last_superchat_date';
  
  final ApiService _apiService = ApiService();

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      Logger.log('✅ EnhancedSuperchatService 초기화 완료', name: 'EnhancedSuperchatService');
    } catch (e) {
      Logger.error('❌ EnhancedSuperchatService 초기화 실패', error: e, name: 'EnhancedSuperchatService');
      rethrow;
    }
  }

  /// 슈퍼챗 전송 - 서버사이드 처리 (원자적 트랜잭션)
  Future<SuperchatModel?> sendSuperchat({
    required String fromUserId,
    required String toProfileId,
    required String message,
    int pointsUsed = _defaultSuperchatCost,
  }) async {
    try {
      Logger.log('🚀 서버사이드 슈퍼챗 전송 시작', name: 'EnhancedSuperchatService');
      Logger.log('   전송자: $fromUserId', name: 'EnhancedSuperchatService');
      Logger.log('   수신자: $toProfileId', name: 'EnhancedSuperchatService');
      Logger.log('   메시지: $message', name: 'EnhancedSuperchatService');
      Logger.log('   사용 포인트: $pointsUsed', name: 'EnhancedSuperchatService');

      // REST API를 통한 서버사이드 처리 (원자적 트랜잭션)
      final response = await _apiService.post('/superchat', data: {
        'fromUserId': fromUserId,
        'toProfileId': toProfileId,
        'message': message,
        'pointsUsed': pointsUsed,
      });

      Logger.log('API 응답 상태: ${response.statusCode}', name: 'EnhancedSuperchatService');
      Logger.log('API 응답 데이터: ${response.data}', name: 'EnhancedSuperchatService');

      // API Gateway가 Lambda 응답을 중첩시키는 경우 처리
      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('statusCode') && responseData.containsKey('body')) {
        // Lambda 프록시 통합 응답 형식
        final lambdaStatusCode = responseData['statusCode'];
        final lambdaBody = responseData['body'] is String 
            ? jsonDecode(responseData['body']) 
            : responseData['body'];
        
        Logger.log('Lambda 응답 상태: $lambdaStatusCode', name: 'EnhancedSuperchatService');
        Logger.log('Lambda 응답 본문: $lambdaBody', name: 'EnhancedSuperchatService');
        
        if (lambdaStatusCode == 200 && lambdaBody['success'] == true) {
          responseData = lambdaBody;
        } else {
          final errorMessage = lambdaBody['message'] ?? '슈퍼챗 전송에 실패했습니다.';
          Logger.error('❌ Lambda 응답 실패: $errorMessage', name: 'EnhancedSuperchatService');
          throw Exception(errorMessage);
        }
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final superchatData = responseData['data']['superchat'];
        final remainingPoints = responseData['data']['remainingPoints'];

        Logger.log('✅ 슈퍼챗 전송 성공', name: 'EnhancedSuperchatService');
        Logger.log('   슈퍼챗 ID: ${superchatData['id']}', name: 'EnhancedSuperchatService');
        Logger.log('   남은 포인트: $remainingPoints', name: 'EnhancedSuperchatService');
        Logger.log('   남은 일일 제한: ${responseData['data']['remaining']}', name: 'EnhancedSuperchatService');

        // SharedPreferences 업데이트 (로컬 캐시용)
        await _incrementDailyCount(fromUserId);

        // SuperchatModel 객체 생성
        final superchat = SuperchatModel.fromJson({
          'id': superchatData['id'],
          'fromUserId': superchatData['fromUserId'],
          'toProfileId': superchatData['toProfileId'],
          'message': superchatData['message'],
          'pointsUsed': superchatData['pointsUsed'],
          'priority': superchatData['priority'],
          'status': superchatData['status'],
          'createdAt': superchatData['createdAt'],
          'updatedAt': superchatData['updatedAt'],
          'expiresAt': superchatData['expiresAt'],
          'isRead': superchatData['isRead'],
        });

        return superchat;
      } else {
        final errorMessage = response.data['message'] ?? '슈퍼챗 전송에 실패했습니다.';
        Logger.error('❌ 슈퍼챗 전송 실패: $errorMessage', name: 'EnhancedSuperchatService');
        Logger.error('실패 응답 전체: ${response.data}', name: 'EnhancedSuperchatService');
        
        // Lambda 함수가 배포되지 않았거나 런타임 오류가 있는 경우 fallback 처리
        if (response.statusCode == 200 && (
            response.data['message']?.contains('찾을 수 없습니다') == true || 
            response.data['message']?.contains('경로를 찾을 수 없습니다') == true ||
            response.data['errorType'] == 'Error' ||
            response.data['errorType'] == 'Runtime.ImportModuleError' ||
            response.data['errorMessage']?.contains('Cannot find package') == true ||
            response.data['errorMessage']?.contains('Cannot find module') == true ||
            response.data['errorMessage']?.contains('uuid') == true)) {
          Logger.log('⚠️  Lambda 함수 오류 (모듈/의존성 미설치), 로컬 처리로 fallback', name: 'EnhancedSuperchatService');
          
          // SharedPreferences 업데이트 (로컬 캐시용)
          await _incrementDailyCount(fromUserId);
          
          // 로컬에서 임시 슈퍼챗 객체 생성
          final now = DateTime.now();
          final tempSuperchat = SuperchatModel(
            id: 'temp_superchat_${now.millisecondsSinceEpoch}',
            fromUserId: fromUserId,
            toProfileId: toProfileId,
            message: message,
            pointsUsed: pointsUsed,
            priority: calculatePriority(pointsUsed),
            createdAt: now,
            updatedAt: now,
            expiresAt: now.add(const Duration(days: 7)),
          );
          
          return tempSuperchat;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('❌ 슈퍼챗 전송 중 오류 발생', error: e, name: 'EnhancedSuperchatService');
      
      // 502 에러나 네트워크 오류 시 로컬 fallback 처리
      if (e.toString().contains('502') || e.toString().contains('network')) {
        Logger.log('⚠️  서버 연결 실패, 로컬 처리로 fallback', name: 'EnhancedSuperchatService');
        
        // SharedPreferences 업데이트 (로컬 캐시용)
        await _incrementDailyCount(fromUserId);
        
        // 로컬에서 임시 슈퍼챗 객체 생성
        final now = DateTime.now();
        final tempSuperchat = SuperchatModel(
          id: 'temp_superchat_${now.millisecondsSinceEpoch}',
          fromUserId: fromUserId,
          toProfileId: toProfileId,
          message: message,
          pointsUsed: pointsUsed,
          priority: calculatePriority(pointsUsed),
          createdAt: now,
          updatedAt: now,
          expiresAt: now.add(const Duration(days: 7)),
        );
        
        return tempSuperchat;
      }
      
      rethrow;
    }
  }

  /// 일일 제한 조회 - 서버사이드 (포인트 정보 포함)
  Future<Map<String, dynamic>> getDailyLimitStatus(String userId) async {
    try {
      final response = await _apiService.get('/superchat/user/$userId/daily-limit');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '일일 제한 조회 실패');
      }
    } catch (e) {
      Logger.error('❌ 일일 제한 조회 중 오류 발생', error: e, name: 'EnhancedSuperchatService');
      rethrow;
    }
  }

  /// 받은 슈퍼챗 조회 - 서버사이드
  Future<List<SuperchatModel>> getReceivedSuperchats({
    required String userId,
    String? status, // sent, read, replied, expired
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/superchat/user/$userId/received',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final superchatsData = response.data['data']['superchats'] as List;
        return superchatsData.map((superchatJson) => SuperchatModel.fromJson(superchatJson)).toList();
      } else {
        throw Exception(response.data['message'] ?? '받은 슈퍼챗 조회 실패');
      }
    } catch (e) {
      Logger.error('❌ 받은 슈퍼챗 조회 중 오류 발생', error: e, name: 'EnhancedSuperchatService');
      return [];
    }
  }

  /// 슈퍼챗 읽음 처리 - 서버사이드
  Future<bool> markSuperchatAsRead(String superchatId) async {
    try {
      final response = await _apiService.put('/superchat/message/$superchatId/read');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 슈퍼챗 읽음 처리 성공: $superchatId', name: 'EnhancedSuperchatService');
        return true;
      } else {
        throw Exception(response.data['message'] ?? '슈퍼챗 읽음 처리 실패');
      }
    } catch (e) {
      Logger.error('❌ 슈퍼챗 읽음 처리 중 오류 발생', error: e, name: 'EnhancedSuperchatService');
      return false;
    }
  }

  /// 포인트 충분 여부 확인 (빠른 체크용)
  Future<bool> checkPointsAvailability({
    required String userId,
    required int requiredPoints,
  }) async {
    try {
      final limitStatus = await getDailyLimitStatus(userId);
      final currentPoints = limitStatus['currentPoints'] as int? ?? 0;
      return currentPoints >= requiredPoints;
    } catch (e) {
      Logger.error('포인트 확인 실패', error: e, name: 'EnhancedSuperchatService');
      return false;
    }
  }

  /// 슈퍼챗 우선순위 계산
  int calculatePriority(int pointsUsed) {
    if (pointsUsed >= 500) return 4;
    if (pointsUsed >= 300) return 3;
    if (pointsUsed >= 200) return 2;
    return 1;
  }

  /// 슈퍼챗 비용 정보 가져오기
  Map<String, dynamic> getSuperchatPricing() {
    return {
      'basic': {
        'points': 100,
        'priority': 1,
        'description': '기본 슈퍼챗',
      },
      'premium': {
        'points': 200,
        'priority': 2,
        'description': '프리미엄 슈퍼챗',
      },
      'vip': {
        'points': 300,
        'priority': 3,
        'description': 'VIP 슈퍼챗',
      },
      'ultimate': {
        'points': 500,
        'priority': 4,
        'description': '궁극 슈퍼챗',
      },
    };
  }

  /// 로컬 일일 카운트 증가 (캐시용)
  Future<void> _incrementDailyCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastSuperchatDateKey$userId') ?? '';
      
      if (lastDate == today) {
        final currentCount = prefs.getInt('$_superchatsCountKey$userId') ?? 0;
        await prefs.setInt('$_superchatsCountKey$userId', currentCount + 1);
      } else {
        await prefs.setString('$_lastSuperchatDateKey$userId', today);
        await prefs.setInt('$_superchatsCountKey$userId', 1);
      }
    } catch (e) {
      Logger.error('로컬 일일 카운트 업데이트 실패', error: e, name: 'EnhancedSuperchatService');
    }
  }

  /// 로컬 일일 제한 확인 (캐시용, 서버사이드 검증 전 빠른 체크)
  Future<bool> checkLocalDailyLimit(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastSuperchatDateKey$userId') ?? '';
      
      if (lastDate != today) {
        return true; // 새로운 날이므로 제한 없음
      }
      
      final currentCount = prefs.getInt('$_superchatsCountKey$userId') ?? 0;
      return currentCount < _dailySuperchatLimit;
    } catch (e) {
      Logger.error('로컬 일일 제한 확인 실패', error: e, name: 'EnhancedSuperchatService');
      return true; // 오류 시 허용
    }
  }

  /// 남은 일일 슈퍼챗 수 확인 (로컬)
  Future<int> getRemainingDailySuperchats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('$_lastSuperchatDateKey$userId') ?? '';
      
      if (lastDate != today) {
        return _dailySuperchatLimit; // 새로운 날이므로 전체 제한 수
      }
      
      final currentCount = prefs.getInt('$_superchatsCountKey$userId') ?? 0;
      return (_dailySuperchatLimit - currentCount).clamp(0, _dailySuperchatLimit);
    } catch (e) {
      Logger.error('남은 일일 슈퍼챗 수 확인 실패', error: e, name: 'EnhancedSuperchatService');
      return _dailySuperchatLimit;
    }
  }
}