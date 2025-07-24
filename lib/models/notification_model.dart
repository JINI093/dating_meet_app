import 'package:json_annotation/json_annotation.dart';

// part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final bool isImportant;
  final String? imageUrl;
  final String? actionUrl;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.isImportant = false,
    this.imageUrl,
    this.actionUrl,
  });

  // factory NotificationModel.fromJson(Map<String, dynamic> json) =>
  //     _$NotificationModelFromJson(json);

  // Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    bool? isImportant,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isImportant: isImportant ?? this.isImportant,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}|  ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}�  ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}�  ';
    } else {
      return ')  ';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.newMatch:
        return '새 매칭';
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

  static List<NotificationModel> getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_1',
        userId: 'user_123',
        title: '새 매칭!',
        message: '홍길동님과 매칭되었습니다. 첫 메시지를 보내보세요!',
        type: NotificationType.newMatch,
        createdAt: now.subtract(const Duration(minutes: 5)),
        isImportant: true,
        imageUrl: 'https://picsum.photos/200/200?random=1',
        actionUrl: '/chat/match_123',
        data: {
          'matchId': 'match_123',
          'profileId': 'profile_456',
          'profileName': '홍길동',
        },
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'user_123',
        title: '새 좋아요',
        message: '홍길동님이 좋아요를 보냈습니다.',
        type: NotificationType.newLike,
        createdAt: now.subtract(const Duration(hours: 1)),
        imageUrl: 'https://picsum.photos/200/200?random=2',
        actionUrl: '/likes/received',
        data: {
          'profileId': 'profile_789',
          'profileName': '홍길동',
        },
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'user_123',
        title: '슈퍼챗',
        message: '홍길동님이 슈퍼챗을 보냈습니다.',
        type: NotificationType.newSuperChat,
        createdAt: now.subtract(const Duration(hours: 2)),
        isImportant: true,
        imageUrl: 'https://picsum.photos/200/200?random=3',
        actionUrl: '/chat/superchat_456',
        data: {
          'chatId': 'superchat_456',
          'profileId': 'profile_101',
          'profileName': '홍길동',
          'message': '홍길동님이 슈퍼챗을 보냈습니다.',
        },
      ),
      NotificationModel(
        id: 'notif_4',
        userId: 'user_123',
        title: '새 메시지',
        message: '홍길동님이 메시지를 보냈습니다.',
        type: NotificationType.newMessage,
        createdAt: now.subtract(const Duration(hours: 3)),
        imageUrl: 'https://picsum.photos/200/200?random=1',
        actionUrl: '/chat/match_123',
        data: {
          'chatId': 'match_123',
          'profileId': 'profile_456',
          'profileName': '홍길동',
        },
      ),
      NotificationModel(
        id: 'notif_5',
        userId: 'user_123',
        title: '프로필 방문',
        message: '홍길동님이 프로필을 방문했습니다.',
        type: NotificationType.profileVisit,
        createdAt: now.subtract(const Duration(hours: 5)),
        imageUrl: 'https://picsum.photos/200/200?random=4',
        data: {
          'profileId': 'profile_202',
          'profileName': '홍길동',
        },
      ),
      NotificationModel(
        id: 'notif_6',
        userId: 'user_123',
        title: 'VIP 알림',
        message: 'VIP 알림 기간이 만료됩니다.',
        type: NotificationType.vipUpdate,
        createdAt: now.subtract(const Duration(days: 1)),
        isImportant: true,
        actionUrl: '/vip',
        data: {
          'vipType': 'expiring',
          'daysLeft': 3,
        },
      ),
      NotificationModel(
        id: 'notif_7',
        userId: 'user_123',
        title: '시스템',
        message: '추천 수가 5개 증가했습니다.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 1)),
        actionUrl: '/home',
        data: {
          'recommendCount': 5,
        },
      ),
      NotificationModel(
        id: 'notif_8',
        userId: 'user_123',
        title: '프로모션',
        message: 'VIP 할인 50% 이벤트가 진행 중입니다.',
        type: NotificationType.promotion,
        createdAt: now.subtract(const Duration(days: 2)),
        actionUrl: '/vip',
        data: {
          'discountPercent': 50,
          'eventType': 'vip_discount',
        },
      ),
    ];
  }
}

enum NotificationType {
  @JsonValue('new_match')
  newMatch,
  @JsonValue('new_like')
  newLike,
  @JsonValue('new_message')
  newMessage,
  @JsonValue('new_super_chat')
  newSuperChat,
  @JsonValue('profile_visit')
  profileVisit,
  @JsonValue('vip_update')
  vipUpdate,
  @JsonValue('system')
  system,
  @JsonValue('promotion')
  promotion,
}