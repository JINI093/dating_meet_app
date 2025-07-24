import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/aws_likes_service.dart';
import '../services/aws_match_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';


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
  final AWSLikesService _likesService = AWSLikesService();
  final AWSMatchService _matchService = AWSMatchService();

  NotificationNotifier(this.ref) : super(const NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      await _likesService.initialize();
      await _matchService.initialize();
      await _loadNotifications();
    } catch (e) {
      Logger.error('알림 provider 초기화 실패', error: e, name: 'NotificationProvider');
      state = state.copyWith(error: e.toString());
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
      final notifications = <NotificationModel>[];

      // Load recent received likes to create notifications
      final receivedLikes = await _likesService.getReceivedLikes(userId: userId, limit: 20);
      for (final like in receivedLikes) {
        if (!like.isRead) {
          notifications.add(NotificationModel(
            id: 'like_${like.id}',
            userId: userId,
            title: like.isSuperChat ? '새로운 슈퍼챗!' : '새로운 좋아요!',
            message: like.displayMessage,
            type: like.isSuperChat ? NotificationType.newSuperChat : NotificationType.newLike,
            createdAt: like.createdAt,
            isImportant: like.isSuperChat,
            imageUrl: like.profile?.profileImages.first,
            actionUrl: '/likes',
            data: {
              'likeId': like.id,
              'fromUserId': like.fromUserId,
              'isSuperChat': like.isSuperChat,
            },
          ));
        }
      }

      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        lastChecked: DateTime.now(),
      );

      Logger.log('알림 ${notifications.length}개 로드 완료 (읽지 않음: $unreadCount)', name: 'NotificationProvider');
    } catch (e) {
      Logger.error('알림 로드 실패', error: e, name: 'NotificationProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
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

      // Simulate API call to mark as read
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications = state.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshNotifications() async {
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