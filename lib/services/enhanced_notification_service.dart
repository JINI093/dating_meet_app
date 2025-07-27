import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';

/// 강화된 실시간 알림 서비스
/// 서버사이드 알림 관리 및 실시간 업데이트
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final ApiService _apiService = ApiService();
  final StreamController<NotificationModel> _notificationController = StreamController<NotificationModel>.broadcast();
  
  Timer? _pollTimer;
  String? _currentUserId;
  DateTime? _lastPollTime;

  /// 알림 스트림 (실시간 알림 수신용)
  Stream<NotificationModel> get notificationStream => _notificationController.stream;

  /// 서비스 초기화
  Future<void> initialize(String userId) async {
    try {
      _currentUserId = userId;
      _lastPollTime = DateTime.now().subtract(const Duration(days: 1)); // 초기값
      
      // 주기적 폴링 시작 (실시간 알림용)
      _startPolling();
      
      Logger.log('✅ EnhancedNotificationService 초기화 완료', name: 'EnhancedNotificationService');
    } catch (e) {
      Logger.error('❌ EnhancedNotificationService 초기화 실패', error: e, name: 'EnhancedNotificationService');
      rethrow;
    }
  }

  /// 서비스 정리
  void dispose() {
    _pollTimer?.cancel();
    _notificationController.close();
  }

  /// 사용자 알림 목록 조회
  Future<List<NotificationModel>> getUserNotifications({
    String? type,
    bool? isRead,
    int limit = 50,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('사용자 ID가 설정되지 않았습니다');
      }

      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['isRead'] = isRead.toString();

      final response = await _apiService.get(
        '/notifications/$_currentUserId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final notificationsData = response.data['data']['notifications'] as List;
        return notificationsData.map((json) => _parseNotificationFromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? '알림 조회 실패');
      }
    } catch (e) {
      Logger.error('❌ 알림 조회 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return [];
    }
  }

  /// 알림 읽음 처리
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _apiService.put('/notifications/$notificationId/read');

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 알림 읽음 처리 성공: $notificationId', name: 'EnhancedNotificationService');
        return true;
      } else {
        throw Exception(response.data['message'] ?? '알림 읽음 처리 실패');
      }
    } catch (e) {
      Logger.error('❌ 알림 읽음 처리 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return false;
    }
  }

  /// 모든 알림 읽음 처리
  Future<bool> markAllNotificationsAsRead() async {
    try {
      if (_currentUserId == null) {
        throw Exception('사용자 ID가 설정되지 않았습니다');
      }

      final response = await _apiService.put('/notifications/$_currentUserId/read-all');

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 모든 알림 읽음 처리 성공', name: 'EnhancedNotificationService');
        return true;
      } else {
        throw Exception(response.data['message'] ?? '모든 알림 읽음 처리 실패');
      }
    } catch (e) {
      Logger.error('❌ 모든 알림 읽음 처리 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return false;
    }
  }

  /// 읽지 않은 알림 수 조회
  Future<int> getUnreadNotificationCount() async {
    try {
      if (_currentUserId == null) {
        return 0;
      }

      final response = await _apiService.get('/notifications/$_currentUserId/unread-count');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['count'] as int? ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      Logger.error('❌ 읽지 않은 알림 수 조회 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return 0;
    }
  }

  /// 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 알림 삭제 성공: $notificationId', name: 'EnhancedNotificationService');
        return true;
      } else {
        throw Exception(response.data['message'] ?? '알림 삭제 실패');
      }
    } catch (e) {
      Logger.error('❌ 알림 삭제 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return false;
    }
  }

  /// 주기적 폴링 시작 (새 알림 체크)
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForNewNotifications();
    });
  }

  /// 새 알림 체크
  Future<void> _checkForNewNotifications() async {
    if (_currentUserId == null || _lastPollTime == null) return;

    try {
      final response = await _apiService.get(
        '/notifications/$_currentUserId/since',
        queryParameters: {
          'since': _lastPollTime!.toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newNotifications = response.data['data']['notifications'] as List;
        
        for (final notificationJson in newNotifications) {
          final notification = _parseNotificationFromJson(notificationJson);
          _notificationController.add(notification);
        }

        if (newNotifications.isNotEmpty) {
          _lastPollTime = DateTime.now();
          Logger.log('📱 새 알림 ${newNotifications.length}개 수신', name: 'EnhancedNotificationService');
        }
      }
    } catch (e) {
      // 폴링 오류는 조용히 처리 (연결 불안정 등)
      if (kDebugMode) {
        Logger.error('알림 폴링 오류', error: e, name: 'EnhancedNotificationService');
      }
    }
  }

  /// 로컬 알림 생성 (즉시 표시용)
  void addLocalNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId ?? '',
      title: title,
      message: message,
      type: type,
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _notificationController.add(notification);
  }

  /// 푸시 알림 토큰 등록 (향후 구현)
  Future<void> registerPushToken(String token) async {
    try {
      if (_currentUserId == null) {
        throw Exception('사용자 ID가 설정되지 않았습니다');
      }

      final response = await _apiService.post('/notifications/register-token', data: {
        'userId': _currentUserId,
        'token': token,
        'platform': defaultTargetPlatform.name,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 푸시 토큰 등록 성공', name: 'EnhancedNotificationService');
      }
    } catch (e) {
      Logger.error('❌ 푸시 토큰 등록 실패', error: e, name: 'EnhancedNotificationService');
    }
  }

  /// 알림 설정 업데이트
  Future<bool> updateNotificationSettings({
    bool? likesEnabled,
    bool? superchatsEnabled,
    bool? matchesEnabled,
    bool? messagesEnabled,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('사용자 ID가 설정되지 않았습니다');
      }

      final response = await _apiService.put('/notifications/$_currentUserId/settings', data: {
        'likesEnabled': likesEnabled,
        'superchatsEnabled': superchatsEnabled,
        'matchesEnabled': matchesEnabled,
        'messagesEnabled': messagesEnabled,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ 알림 설정 업데이트 성공', name: 'EnhancedNotificationService');
        return true;
      } else {
        throw Exception(response.data['message'] ?? '알림 설정 업데이트 실패');
      }
    } catch (e) {
      Logger.error('❌ 알림 설정 업데이트 중 오류 발생', error: e, name: 'EnhancedNotificationService');
      return false;
    }
  }

  /// JSON에서 NotificationModel 파싱
  NotificationModel _parseNotificationFromJson(Map<String, dynamic> json) {
    // NotificationType 파싱
    NotificationType type;
    final typeString = json['type'] as String?;
    switch (typeString) {
      case 'MATCH':
      case 'new_match':
        type = NotificationType.newMatch;
        break;
      case 'LIKE':
      case 'new_like':
        type = NotificationType.newLike;
        break;
      case 'MESSAGE':
      case 'new_message':
        type = NotificationType.newMessage;
        break;
      case 'SUPERCHAT':
      case 'new_super_chat':
        type = NotificationType.newSuperChat;
        break;
      case 'PROFILE_VISIT':
      case 'profile_visit':
        type = NotificationType.profileVisit;
        break;
      case 'VIP_UPDATE':
      case 'vip_update':
        type = NotificationType.vipUpdate;
        break;
      case 'SYSTEM':
      case 'system':
        type = NotificationType.system;
        break;
      case 'PROMOTION':
      case 'promotion':
        type = NotificationType.promotion;
        break;
      default:
        type = NotificationType.system;
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? _getDefaultTitle(type),
      message: json['message'] as String,
      type: type,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  /// 알림 유형별 기본 제목
  String _getDefaultTitle(NotificationType type) {
    switch (type) {
      case NotificationType.newMatch:
        return '새 매칭!';
      case NotificationType.newLike:
        return '새 좋아요';
      case NotificationType.newMessage:
        return '새 메시지';
      case NotificationType.newSuperChat:
        return '슈퍼챗';
      case NotificationType.profileVisit:
        return '프로필 방문';
      case NotificationType.vipUpdate:
        return 'VIP 알림';
      case NotificationType.system:
        return '시스템';
      case NotificationType.promotion:
        return '프로모션';
    }
  }
}