import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class AWSNotificationService {
  static const String _tag = 'AWSNotificationService';
  
  final Dio _dio;
  
  AWSNotificationService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    AppLogger.d(_tag, '🔧 AWSNotificationService 초기화 - Base URL: ${ApiConfig.baseUrl}');
    
    // Request/Response interceptor for debugging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.d(_tag, '🚀 API Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.d(_tag, '✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.e(_tag, '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}', error);
        handler.next(error);
      },
    ));
  }

  /// 사용자의 모든 알림 가져오기
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      AppLogger.d(_tag, '📥 사용자 알림 조회 시작: $userId');
      
      final response = await _dio.get('/notifications/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // API Gateway Lambda 프록시 응답 구조 처리
        Map<String, dynamic> responseData;
        if (data is Map && data.containsKey('statusCode') && data.containsKey('body')) {
          final bodyData = data['body'] is String 
              ? jsonDecode(data['body']) 
              : data['body'];
          responseData = bodyData;
        } else {
          responseData = data;
        }
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final notificationsJson = responseData['data'] as List;
          final notifications = notificationsJson
              .map((json) => NotificationModel.fromDynamoDB(json))
              .toList();
          
          AppLogger.d(_tag, '✅ 알림 ${notifications.length}개 조회 완료');
          return notifications;
        } else {
          AppLogger.w(_tag, '⚠️ API 응답 실패: ${responseData['message']}');
          return [];
        }
      } else {
        AppLogger.e(_tag, '❌ HTTP 에러: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.e(_tag, '❌ 알림 조회 실패', e);
      return [];
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      AppLogger.d(_tag, '📊 읽지 않은 알림 개수 조회: $userId');
      
      final response = await _dio.get('/notifications/unread-count/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // API Gateway Lambda 프록시 응답 구조 처리
        Map<String, dynamic> responseData;
        if (data is Map && data.containsKey('statusCode') && data.containsKey('body')) {
          final bodyData = data['body'] is String 
              ? jsonDecode(data['body']) 
              : data['body'];
          responseData = bodyData;
        } else {
          responseData = data;
        }
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final count = responseData['data']['unreadCount'] ?? 0;
          AppLogger.d(_tag, '✅ 읽지 않은 알림 개수: $count');
          return count;
        } else {
          AppLogger.w(_tag, '⚠️ 개수 조회 실패: ${responseData['message']}');
          return 0;
        }
      } else {
        AppLogger.e(_tag, '❌ HTTP 에러: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      AppLogger.e(_tag, '❌ 개수 조회 실패', e);
      return 0;
    }
  }

  /// 특정 알림을 읽음 상태로 변경
  Future<bool> markNotificationAsRead(String notificationId, String userId) async {
    try {
      AppLogger.d(_tag, '✅ 알림 읽음 처리: $notificationId');
      
      final response = await _dio.put('/notifications/$notificationId/read', data: {
        'userId': userId,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // API Gateway Lambda 프록시 응답 구조 처리
        Map<String, dynamic> responseData;
        if (data is Map && data.containsKey('statusCode') && data.containsKey('body')) {
          final bodyData = data['body'] is String 
              ? jsonDecode(data['body']) 
              : data['body'];
          responseData = bodyData;
        } else {
          responseData = data;
        }
        
        if (responseData['success'] == true) {
          AppLogger.d(_tag, '✅ 알림 읽음 처리 완료');
          return true;
        } else {
          AppLogger.w(_tag, '⚠️ 읽음 처리 실패: ${responseData['message']}');
          return false;
        }
      } else {
        AppLogger.e(_tag, '❌ HTTP 에러: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.e(_tag, '❌ 읽음 처리 실패', e);
      return false;
    }
  }

  /// 모든 알림을 읽음 상태로 변경
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      AppLogger.d(_tag, '✅ 모든 알림 읽음 처리: $userId');
      
      final response = await _dio.put('/notifications/read-all', data: {
        'userId': userId,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // API Gateway Lambda 프록시 응답 구조 처리
        Map<String, dynamic> responseData;
        if (data is Map && data.containsKey('statusCode') && data.containsKey('body')) {
          final bodyData = data['body'] is String 
              ? jsonDecode(data['body']) 
              : data['body'];
          responseData = bodyData;
        } else {
          responseData = data;
        }
        
        if (responseData['success'] == true) {
          AppLogger.d(_tag, '✅ 모든 알림 읽음 처리 완료');
          return true;
        } else {
          AppLogger.w(_tag, '⚠️ 모든 알림 읽음 처리 실패: ${responseData['message']}');
          return false;
        }
      } else {
        AppLogger.e(_tag, '❌ HTTP 에러: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.e(_tag, '❌ 모든 알림 읽음 처리 실패', e);
      return false;
    }
  }

  /// 새로운 좋아요/슈퍼챗 알림 폴링 (실시간 업데이트용)
  Future<List<NotificationModel>> pollRecentNotifications(String userId, {DateTime? since}) async {
    try {
      final sinceTimestamp = since?.toIso8601String() ?? 
          DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
      
      AppLogger.d(_tag, '🔄 최근 알림 폴링: $userId (since: $sinceTimestamp)');
      
      final response = await _dio.get('/notifications/recent/$userId', queryParameters: {
        'since': sinceTimestamp,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // API Gateway Lambda 프록시 응답 구조 처리
        Map<String, dynamic> responseData;
        if (data is Map && data.containsKey('statusCode') && data.containsKey('body')) {
          final bodyData = data['body'] is String 
              ? jsonDecode(data['body']) 
              : data['body'];
          responseData = bodyData;
        } else {
          responseData = data;
        }
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final notificationsJson = responseData['data'] as List;
          final notifications = notificationsJson
              .map((json) => NotificationModel.fromDynamoDB(json))
              .toList();
          
          if (notifications.isNotEmpty) {
            AppLogger.d(_tag, '🔔 새로운 알림 ${notifications.length}개 발견');
          }
          return notifications;
        } else {
          return [];
        }
      } else {
        AppLogger.e(_tag, '❌ 폴링 HTTP 에러: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.e(_tag, '❌ 알림 폴링 실패', e);
      return [];
    }
  }
}