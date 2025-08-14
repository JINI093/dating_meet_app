import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/aws_notification_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';
import 'likes_provider.dart';


// Notification State
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final bool hasNewNotifications;
  final DateTime? lastChecked;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.hasNewNotifications = false,
    this.lastChecked,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    bool? hasNewNotifications,
    DateTime? lastChecked,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasNewNotifications: hasNewNotifications ?? this.hasNewNotifications,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get importantNotifications =>
      notifications.where((n) => n.isImportant && !n.isRead).toList();

  List<NotificationModel> get matchNotifications =>
      notifications.where((n) => n.type == NotificationType.newMatch).toList();

  List<NotificationModel> get messageNotifications =>
      notifications
          .where((n) =>
              n.type == NotificationType.newMessage ||
              n.type == NotificationType.newSuperChat)
          .toList();

  List<NotificationModel> get likeNotifications =>
      notifications.where((n) => n.type == NotificationType.newLike).toList();
}

// Notification Provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref ref;
  final NotificationService _notificationService = NotificationService();
  late final AWSNotificationService _awsNotificationService;
  
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 30);

  NotificationNotifier(this.ref) : super(const NotificationState()) {
    _awsNotificationService = AWSNotificationService();
    _initialize();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      await _loadNotifications();
      _startPolling(); // 실시간 알림 폴링 시작
    } catch (e) {
      AppLogger.e('NotificationProvider', '알림 provider 초기화 실패', e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// 실시간 알림 폴링 시작
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _pollRecentNotifications();
    });
    AppLogger.d('NotificationProvider', '📡 알림 폴링 시작 (${_pollingInterval.inSeconds}초 간격)');
  }

  /// 좋아요 데이터 새로고침 (좋아요 알림 수신 시)
  void _refreshLikesData() {
    try {
      // LikesProvider의 loadAllLikes 호출 (백그라운드에서 실행)
      Future.microtask(() async {
        try {
          final likesNotifier = ref.read(likesProvider.notifier);
          await likesNotifier.loadAllLikes();
          AppLogger.d('NotificationProvider', '✅ 좋아요 데이터 새로고침 완료');
        } catch (e) {
          AppLogger.e('NotificationProvider', '좋아요 데이터 새로고침 실패', e);
        }
      });
    } catch (e) {
      AppLogger.e('NotificationProvider', '좋아요 데이터 새로고침 시작 실패', e);
    }
  }

  /// 최근 알림 폴링
  Future<void> _pollRecentNotifications() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      final since = state.lastChecked ?? DateTime.now().subtract(const Duration(minutes: 5));
      
      final newNotifications = await _awsNotificationService.pollRecentNotifications(userId, since: since);
      
      if (newNotifications.isNotEmpty) {
        // 새 알림을 기존 알림 목록에 추가
        final updatedNotifications = [...newNotifications, ...state.notifications];
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
          hasNewNotifications: true,
          lastChecked: DateTime.now(),
        );
        
        AppLogger.d('NotificationProvider', '🔔 새 알림 ${newNotifications.length}개 수신');
        
        // 좋아요 관련 알림이 있으면 좋아요 데이터 새로고침
        final likeNotifications = newNotifications.where(
          (n) => n.type == NotificationType.newLike || n.type == NotificationType.newSuperChat
        ).toList();
        
        if (likeNotifications.isNotEmpty) {
          AppLogger.d('NotificationProvider', '💕 좋아요 알림 ${likeNotifications.length}개 감지 - 좋아요 데이터 새로고침');
          _refreshLikesData();
        }
        
        // 로컬 알림 표시
        for (final notification in newNotifications) {
          await _showLocalNotification(notification);
        }
      }
    } catch (e) {
      AppLogger.e('NotificationProvider', '알림 폴링 실패', e);
    }
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current user
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        // If not logged in, use empty list
        state = state.copyWith(
          notifications: [],
          unreadCount: 0,
          isLoading: false,
          lastChecked: DateTime.now(),
        );
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      
      // DynamoDB에서 알림 데이터 가져오기
      final notifications = await _awsNotificationService.getUserNotifications(userId);
      final unreadCount = await _awsNotificationService.getUnreadNotificationCount(userId);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        lastChecked: DateTime.now(),
      );

      AppLogger.d('NotificationProvider', '✅ 알림 ${notifications.length}개 로드 완료 (읽지 않음: $unreadCount)');
    } catch (e) {
      AppLogger.e('NotificationProvider', '알림 로드 실패', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      
      // DynamoDB에서 읽음 상태 업데이트
      final success = await _awsNotificationService.markNotificationAsRead(notificationId, userId);
      
      if (success) {
        // 로컬 상태 업데이트
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
        
        AppLogger.d('NotificationProvider', '✅ 알림 읽음 처리 완료: $notificationId');
      }
    } catch (e) {
      AppLogger.e('NotificationProvider', '알림 읽음 처리 실패', e);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      
      // DynamoDB에서 모든 알림 읽음 처리
      final success = await _awsNotificationService.markAllNotificationsAsRead(userId);
      
      if (success) {
        // 로컬 상태 업데이트
        final updatedNotifications = state.notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
          hasNewNotifications: false,
        );
        
        AppLogger.d('NotificationProvider', '✅ 모든 알림 읽음 처리 완료');
      }
    } catch (e) {
      AppLogger.e('NotificationProvider', '모든 알림 읽음 처리 실패', e);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // 로컬에서만 제거 (DynamoDB에서는 실제 삭제하지 않음)
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
      
      AppLogger.d('NotificationProvider', '🗑️ 알림 삭제: $notificationId');
    } catch (e) {
      AppLogger.e('NotificationProvider', '알림 삭제 실패', e);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
        hasNewNotifications: false,
      );
      
      AppLogger.d('NotificationProvider', '🗑️ 모든 알림 삭제');
    } catch (e) {
      AppLogger.e('NotificationProvider', '모든 알림 삭제 실패', e);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshNotifications() async {
    AppLogger.d('NotificationProvider', '🔄 알림 새로고침');
    await _loadNotifications();
  }

  void addNotification(NotificationModel notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
      hasNewNotifications: true,
    );
    
    AppLogger.d('NotificationProvider', '➕ 새 알림 추가: ${notification.type.name}');
  }

  /// 새 알림이 도착했을 때 상태 업데이트
  void clearNewNotificationFlag() {
    state = state.copyWith(hasNewNotifications: false);
  }

  /// 로컬 푸시 알림 표시
  Future<void> _showLocalNotification(NotificationModel notification) async {
    try {
      final fromUserId = notification.data?['fromUserId']?.toString() ?? '';
      final fromUserName = '익명의 사용자'; // 프로필 이름은 별도로 조회 필요
      
      if (notification.type == NotificationType.newLike) {
        await _notificationService.showLikeReceivedNotification(
          fromUserName: fromUserName,
          fromUserId: fromUserId,
          message: null,
          isSuperChat: false,
        );
      } else if (notification.type == NotificationType.newSuperChat) {
        final pointsUsed = notification.data?['pointsUsed'] ?? 100;
        final superChatPriority = pointsUsed >= 500 ? 4 : 
                                 pointsUsed >= 300 ? 3 : 
                                 pointsUsed >= 200 ? 2 : 1;
        
        await _notificationService.showSuperchatNotification(
          fromUserName: fromUserName,
          fromUserId: fromUserId,
          message: notification.message,
          priority: superChatPriority,
          pointsUsed: pointsUsed,
        );
      } else if (notification.type == NotificationType.newMatch) {
        await _notificationService.showMatchNotification(
          matchUserName: fromUserName,
          matchUserId: fromUserId,
        );
      }
      
      AppLogger.d('NotificationProvider', '📱 로컬 알림 표시: ${notification.title}');
    } catch (e) {
      AppLogger.e('NotificationProvider', '로컬 알림 표시 실패', e);
    }
  }

  // 매칭 성공 알림 생성
  void addMatchNotification({
    required String matchId,
    required String profileId,
    required String profileName,
    required String profileImageUrl,
  }) {
    final notification = NotificationModel(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_123',
      title: '새로운 매칭!',
      message: '$profileName님과 매칭되었습니다. 첫 메시지를 보내보세요!',
      type: NotificationType.newMatch,
      createdAt: DateTime.now(),
      isImportant: true,
      imageUrl: profileImageUrl,
      actionUrl: '/chat/$matchId',
      data: {
        'matchId': matchId,
        'profileId': profileId,
        'profileName': profileName,
      },
    );

    addNotification(notification);
  }

  // 좋아요 알림 생성
  void addLikeNotification({
    required String profileId,
    required String profileName,
    required String profileImageUrl,
  }) {
    final notification = NotificationModel(
      id: 'like_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_123',
      title: '새로운 좋아요',
      message: '$profileName님이 회원님을 좋아합니다',
      type: NotificationType.newLike,
      createdAt: DateTime.now(),
      imageUrl: profileImageUrl,
      actionUrl: '/likes/received',
      data: {
        'profileId': profileId,
        'profileName': profileName,
      },
    );

    addNotification(notification);
  }

  // 메시지 알림 생성
  void addMessageNotification({
    required String chatId,
    required String profileId,
    required String profileName,
    required String profileImageUrl,
    required String messagePreview,
  }) {
    final notification = NotificationModel(
      id: 'message_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_123',
      title: '새로운 메시지',
      message: '$profileName님: $messagePreview',
      type: NotificationType.newMessage,
      createdAt: DateTime.now(),
      imageUrl: profileImageUrl,
      actionUrl: '/chat/$chatId',
      data: {
        'chatId': chatId,
        'profileId': profileId,
        'profileName': profileName,
        'messagePreview': messagePreview,
      },
    );

    addNotification(notification);
  }

  // 슈퍼챗 알림 생성
  void addSuperChatNotification({
    required String chatId,
    required String profileId,
    required String profileName,
    required String profileImageUrl,
    required String message,
  }) {
    final notification = NotificationModel(
      id: 'superchat_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_123',
      title: '슈퍼챗이 도착했어요!',
      message: '$profileName님: "$message"',
      type: NotificationType.newSuperChat,
      createdAt: DateTime.now(),
      isImportant: true,
      imageUrl: profileImageUrl,
      actionUrl: '/chat/$chatId',
      data: {
        'chatId': chatId,
        'profileId': profileId,
        'profileName': profileName,
        'message': message,
      },
    );

    addNotification(notification);
  }

  // VIP 만료 알림 생성
  void addVipExpirationNotification({required int daysLeft}) {
    final notification = NotificationModel(
      id: 'vip_expiry_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_123',
      title: 'VIP 멤버십 만료 안내',
      message: 'VIP 멤버십이 $daysLeft일 후 만료됩니다. 지금 연장하세요!',
      type: NotificationType.vipUpdate,
      createdAt: DateTime.now(),
      isImportant: true,
      actionUrl: '/vip',
      data: {
        'vipType': 'expiring',
        'daysLeft': daysLeft,
      },
    );

    addNotification(notification);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetNewNotificationFlag() {
    state = state.copyWith(hasNewNotifications: false);
  }

  // 알림 타입별 필터링
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  // 오늘의 알림만 가져오기
  List<NotificationModel> getTodayNotifications() {
    final today = DateTime.now();
    return state.notifications.where((notification) {
      final notificationDate = notification.createdAt;
      return notificationDate.year == today.year &&
          notificationDate.month == today.month &&
          notificationDate.day == today.day;
    }).toList();
  }

  // 중요한 알림이 있는지 확인
  bool hasImportantUnreadNotifications() {
    return state.notifications
        .any((n) => n.isImportant && !n.isRead);
  }

  // 특정 타입의 읽지 않은 알림 개수
  int getUnreadCountByType(NotificationType type) {
    return state.notifications
        .where((n) => n.type == type && !n.isRead)
        .length;
  }
}

// Provider 정의
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

// 편의성을 위한 추가 Provider들
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.unreadCount;
});

final hasNewNotificationsProvider = Provider<bool>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.hasNewNotifications;
});

final importantNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.importantNotifications;
});

final matchNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.matchNotifications;
});

final messageNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.messageNotifications;
});

// 특정 타입의 읽지 않은 알림 개수 Provider
final unreadCountByTypeProvider =
    Provider.family<int, NotificationType>((ref, type) {
  final notifier = ref.read(notificationProvider.notifier);
  return notifier.getUnreadCountByType(type);
});