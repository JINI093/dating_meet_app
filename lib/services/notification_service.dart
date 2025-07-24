import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';

import '../models/like_model.dart';
import '../models/profile_model.dart';
import '../models/superchat_model.dart';
import '../utils/logger.dart';

/// 알림 서비스
/// 호감 표시, 매칭, 슈퍼챗 등의 알림을 처리
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android 초기화 설정
      const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 초기화 설정
      const iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 권한 요청
      await _requestPermissions();

      _isInitialized = true;
      Logger.log('✅ NotificationService 초기화 완료', name: 'NotificationService');
    } catch (e) {
      Logger.error('❌ NotificationService 초기화 실패', error: e, name: 'NotificationService');
      rethrow;
    }
  }

  /// 권한 요청
  Future<void> _requestPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 알림 클릭 시 처리
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        // 페이로드 파싱하여 적절한 화면으로 이동
        final data = payload.split('|');
        final type = data[0];
        final id = data.length > 1 ? data[1] : '';

        switch (type) {
          case 'like':
            // 호감 목록 화면으로 이동
            _navigateToLikes();
            break;
          case 'match':
            // 매칭 화면으로 이동
            _navigateToMatches();
            break;
          case 'superchat':
            // 슈퍼챗 화면으로 이동
            _navigateToSuperchat(id);
            break;
          default:
            // 기본 홈 화면으로 이동
            _navigateToHome();
            break;
        }
      } catch (e) {
        Logger.error('알림 클릭 처리 오류', error: e, name: 'NotificationService');
      }
    }
  }

  /// 호감 수신 알림
  Future<void> showLikeReceivedNotification({
    required String fromUserName,
    required String fromUserId,
    String? message,
    bool isSuperChat = false,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'likes',
        '호감 표시',
        channelDescription: '다른 사용자가 호감을 표시했을 때 수신하는 알림입니다.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFE91E63),
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = isSuperChat ? '💝 슈퍼챗을 받았어요!' : '💖 새로운 호감을 받았어요!';
      final body = isSuperChat && message != null
          ? '$fromUserName님: $message'
          : '$fromUserName님이 호감을 표시했어요!';

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: isSuperChat ? 'superchat|$fromUserId' : 'like|$fromUserId',
      );

      // 서버 알림 기록 저장
      await _saveNotificationToServer(
        type: isSuperChat ? 'superchat' : 'like',
        title: title,
        body: body,
        fromUserId: fromUserId,
        data: {'message': message},
      );

      Logger.log('호감 수신 알림 전송: $fromUserName', name: 'NotificationService');
    } catch (e) {
      Logger.error('호감 수신 알림 오류', error: e, name: 'NotificationService');
    }
  }

  /// 슈퍼챗 우선순위별 알림 (강화된 알림)
  Future<void> showSuperchatNotification({
    required String fromUserName,
    required String fromUserId,
    required String message,
    required int priority,
    required int pointsUsed,
    SuperchatTemplateType? templateType,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // 우선순위에 따른 알림 설정
      final (importance, androidPriority, vibrationPattern, sound) = _getNotificationSettingsForPriority(priority);
      final channelId = 'superchat_priority_$priority';
      final channelName = _getChannelNameForPriority(priority);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: '우선순위 $priority 슈퍼챗 알림',
        importance: importance,
        priority: androidPriority,
        icon: '@mipmap/ic_launcher',
        color: _getColorForPriority(priority),
        playSound: true,
        sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        ongoing: priority <= 2, // 높은 우선순위는 지속 알림
        autoCancel: priority > 2,
        styleInformation: BigTextStyleInformation(
          message,
          contentTitle: _getTitleForPriority(priority, fromUserName),
          summaryText: '${pointsUsed}포인트 슈퍼챗',
        ),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: sound != null ? '$sound.aiff' : 'default',
        threadIdentifier: 'superchat_$priority',
        categoryIdentifier: 'SUPERCHAT_CATEGORY',
        interruptionLevel: priority <= 2 ? InterruptionLevel.critical : InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = _getTitleForPriority(priority, fromUserName);
      final body = _truncateMessage(message, 100);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: 'superchat|$fromUserId|$priority',
      );

      // 서버 알림 기록 저장
      await _saveNotificationToServer(
        type: 'superchat',
        title: title,
        body: body,
        fromUserId: fromUserId,
        data: {
          'message': message,
          'priority': priority,
          'pointsUsed': pointsUsed,
          'templateType': templateType?.name,
        },
      );

      Logger.log('슈퍼챗 알림 전송 (우선순위 $priority): $fromUserName', name: 'NotificationService');
    } catch (e) {
      Logger.error('슈퍼챗 알림 오류', error: e, name: 'NotificationService');
    }
  }

  /// 매칭 성공 알림
  Future<void> showMatchNotification({
    required String matchUserName,
    required String matchUserId,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        'matches',
        '매칭',
        channelDescription: '상호 호감이 성사되었을 때 수신하는 알림입니다.',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4CAF50),
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 100, 500, 100, 500]),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      const title = '🎉 상호 호감이 성사됐어요!';
      final body = '$matchUserName님과 매칭됐어요. 대화를 시작해보세요!';

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: 'match|$matchUserId',
      );

      // 서버 알림 기록 저장
      await _saveNotificationToServer(
        type: 'match',
        title: title,
        body: body,
        fromUserId: matchUserId,
      );

      Logger.log('매칭 성공 알림 전송: $matchUserName', name: 'NotificationService');
    } catch (e) {
      Logger.error('매칭 성공 알림 오류', error: e, name: 'NotificationService');
    }
  }

  /// 우선순위별 알림 설정 반환
  (Importance, Priority, Int64List, String?) _getNotificationSettingsForPriority(int priority) {
    switch (priority) {
      case 1: // 최고 우선순위 (1000+ 포인트)
        return (
          Importance.max,
          Priority.max,
          Int64List.fromList([0, 300, 100, 300, 100, 300, 100, 300]), // 긴 진동
          'superchat_diamond', // 다이아몬드 사운드
        );
      case 2: // 높은 우선순위 (500+ 포인트)
        return (
          Importance.high,
          Priority.high,
          Int64List.fromList([0, 250, 100, 250]), // 중간 진동
          'superchat_gold', // 골드 사운드
        );
      case 3: // 중간 우선순위 (200+ 포인트)
        return (
          Importance.defaultImportance,
          Priority.defaultPriority,
          Int64List.fromList([0, 200]), // 짧은 진동
          'superchat_silver', // 실버 사운드
        );
      default: // 기본 우선순위
        return (
          Importance.low,
          Priority.low,
          Int64List.fromList([0, 100]), // 매우 짧은 진동
          null, // 기본 사운드
        );
    }
  }

  /// 우선순위별 채널명 반환
  String _getChannelNameForPriority(int priority) {
    switch (priority) {
      case 1:
        return '💎 다이아몬드 슈퍼챗';
      case 2:
        return '🌟 골드 슈퍼챗';
      case 3:
        return '⭐ 실버 슈퍼챗';
      default:
        return '✨ 기본 슈퍼챗';
    }
  }

  /// 우선순위별 색상 반환
  Color _getColorForPriority(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF9C27B0); // 보라색 (다이아몬드)
      case 2:
        return const Color(0xFFFF9800); // 주황색 (골드)
      case 3:
        return const Color(0xFF607D8B); // 회색 (실버)
      default:
        return const Color(0xFF2196F3); // 파란색 (기본)
    }
  }

  /// 우선순위별 제목 반환
  String _getTitleForPriority(int priority, String fromUserName) {
    switch (priority) {
      case 1:
        return '💎 다이아몬드 슈퍼챗을 받았어요!';
      case 2:
        return '🌟 골드 슈퍼챗을 받았어요!';
      case 3:
        return '⭐ 실버 슈퍼챗을 받았어요!';
      default:
        return '✨ 슈퍼챗을 받았어요!';
    }
  }

  /// 메시지 길이 제한
  String _truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength - 3)}...';
  }

  /// 서버 알림 기록 저장
  Future<void> _saveNotificationToServer({
    required String type,
    required String title,
    required String body,
    String? fromUserId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationData = {
        'type': type,
        'title': title,
        'body': body,
        'fromUserId': fromUserId,
        'data': data,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateNotification(\$input: CreateNotificationInput!) {
            createNotification(input: \$input) {
              id
              type
              title
              body
              createdAt
            }
          }
        ''',
        variables: {'input': notificationData},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('알림 기록 저장 오류', error: e, name: 'NotificationService');
    }
  }

  /// 화면 네비게이션 메서드들
  void _navigateToLikes() {
    Logger.log('호감 목록 화면으로 이동', name: 'NotificationService');
  }

  void _navigateToMatches() {
    Logger.log('매칭 화면으로 이동', name: 'NotificationService');
  }

  void _navigateToSuperchat(String superchatId) {
    Logger.log('슈퍼챗 화면으로 이동: $superchatId', name: 'NotificationService');
  }

  void _navigateToHome() {
    Logger.log('홈 화면으로 이동', name: 'NotificationService');
  }

  /// 알림 채널 생성 (Android)
  Future<void> createNotificationChannels() async {
    if (!_isInitialized) await initialize();

    final androidPlugin = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // 슈퍼챗 우선순위별 채널 생성
      for (int priority = 1; priority <= 4; priority++) {
        final channelId = 'superchat_priority_$priority';
        final channelName = _getChannelNameForPriority(priority);
        final (importance, _, vibrationPattern, _) = _getNotificationSettingsForPriority(priority);

        final channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: '우선순위 $priority 슈퍼챗 알림 채널',
          importance: importance,
          enableVibration: true,
          vibrationPattern: Int64List.fromList(vibrationPattern),
          playSound: true,
        );

        await androidPlugin.createNotificationChannel(channel);
      }

      Logger.log('안드로이드 알림 채널 생성 완료', name: 'NotificationService');
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initialize();
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}