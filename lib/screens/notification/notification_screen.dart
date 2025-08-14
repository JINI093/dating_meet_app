import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../routes/route_names.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {

  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 알림 새로고침 및 새 알림 플래그 클리어
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refreshNotifications();
      ref.read(notificationProvider.notifier).clearNewNotificationFlag();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final isLoading = notificationState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text(
                '모두 읽음',
                style: TextStyle(
                  color: Color(0xFFFF357B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationProvider.notifier).refreshNotifications();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification, index);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.bell,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
        }
        _handleNotificationTap(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? const Color(0xFFE5E5E5) 
                : const Color(0xFFFF357B).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getNotificationIconColor(notification.type),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // 알림 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.isImportant) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF357B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '중요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF357B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 시간 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF357B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newLike:
        return CupertinoIcons.heart_fill;
      case NotificationType.newSuperChat:
        return CupertinoIcons.star_fill;
      case NotificationType.newMatch:
        return CupertinoIcons.heart_circle_fill;
      case NotificationType.newMessage:
        return CupertinoIcons.chat_bubble_fill;
      default:
        return CupertinoIcons.bell_fill;
    }
  }

  Color _getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.newLike:
        return Colors.pink;
      case NotificationType.newSuperChat:
        return Colors.amber;
      case NotificationType.newMatch:
        return Colors.red;
      case NotificationType.newMessage:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // 알림 타입에 따른 화면 이동 처리
    switch (notification.type) {
      case NotificationType.newLike:
      case NotificationType.newSuperChat:
        context.go(RouteNames.likes);
        break;
      case NotificationType.newMatch:
        context.go(RouteNames.chat);
        break;
      case NotificationType.newMessage:
        context.go(RouteNames.chat);
        break;
      default:
        break;
    }
  }

  void _createTestNotification() {
    final testNotifications = [
      NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        title: '새 좋아요 💕',
        message: '누군가 회원님을 좋아합니다',
        type: NotificationType.newLike,
        createdAt: DateTime.now(),
        data: {'fromUserId': 'test_user_1', 'type': 'like'},
      ),
      NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch + 1}',
        userId: 'current_user',
        title: '슈퍼챗 ⭐',
        message: '슈퍼챗을 받았습니다',
        type: NotificationType.newSuperChat,
        createdAt: DateTime.now(),
        isImportant: true,
        data: {'fromUserId': 'test_user_2', 'type': 'superchat', 'pointsUsed': 300},
      ),
      NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch + 2}',
        userId: 'current_user',
        title: '새 매칭! 🎉',
        message: '새로운 매칭이 생겼습니다',
        type: NotificationType.newMatch,
        createdAt: DateTime.now(),
        isImportant: true,
        data: {'fromUserId': 'test_user_3', 'type': 'match'},
      ),
    ];

    // 랜덤으로 하나 선택해서 추가
    final randomNotification = testNotifications[DateTime.now().millisecond % 3];
    ref.read(notificationProvider.notifier).addNotification(randomNotification);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('테스트 알림이 추가되었습니다: ${randomNotification.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}