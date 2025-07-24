import 'package:json_annotation/json_annotation.dart';

// part 'chat_model.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final ChatMessageStatus status;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    this.replyToMessageId,
    this.metadata,
  });

  // factory ChatMessage.fromJson(Map<String, dynamic> json) =>
  //     _$ChatMessageFromJson(json);

  // Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    ChatMessageStatus? status,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays < 7) return '${difference.inDays}일 전';
    
    return '${timestamp.month}/${timestamp.day}';
  }

  String get timeDisplay {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '$period $displayHour:$minute';
  }

  bool get isRead => status == ChatMessageStatus.read;
  bool get isDelivered => status == ChatMessageStatus.delivered || isRead;
  bool get isSent => status == ChatMessageStatus.sent || isDelivered;

  // Factory methods for different message types
  static ChatMessage createTextMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? replyToMessageId,
  }) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: ChatMessageType.text,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
      replyToMessageId: replyToMessageId,
    );
  }

  static ChatMessage createImageMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String imageUrl,
    String? caption,
  }) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: imageUrl,
      type: ChatMessageType.image,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
      metadata: caption != null ? {'caption': caption} : null,
    );
  }

  static ChatMessage createSuperChatMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: ChatMessageType.superChat,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sending,
      metadata: {'isSuperChat': true},
    );
  }

  // Mock data for testing
  static List<ChatMessage> getMockMessages(String chatId) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_1',
        chatId: chatId,
        senderId: 'user_other',
        receiverId: 'current_user',
        content: '안녕하세요! 만나서 반가워요 😊',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(hours: 2)),
        status: ChatMessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_2',
        chatId: chatId,
        senderId: 'current_user',
        receiverId: 'user_other',
        content: '안녕하세요! 저도 반가워요 😄',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        status: ChatMessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_3',
        chatId: chatId,
        senderId: 'user_other',
        receiverId: 'current_user',
        content: '오늘 날씨가 정말 좋네요!',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        status: ChatMessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_4',
        chatId: chatId,
        senderId: 'current_user',
        receiverId: 'user_other',
        content: '맞아요! 산책하기 좋은 날씨예요',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        status: ChatMessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_5',
        chatId: chatId,
        senderId: 'user_other',
        receiverId: 'current_user',
        content: 'assets/images/mountain.jpg',
        type: ChatMessageType.image,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
        status: ChatMessageStatus.read,
        metadata: {'caption': '오늘 찍은 산 사진이에요!'},
      ),
      ChatMessage(
        id: 'msg_6',
        chatId: chatId,
        senderId: 'current_user',
        receiverId: 'user_other',
        content: '와! 정말 예쁜 사진이네요 😍',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 35)),
        status: ChatMessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_7',
        chatId: chatId,
        senderId: 'user_other',
        receiverId: 'current_user',
        content: '같이 산책하실래요? 😊',
        type: ChatMessageType.superChat,
        timestamp: now.subtract(const Duration(minutes: 30)),
        status: ChatMessageStatus.read,
        metadata: {'isSuperChat': true},
      ),
      ChatMessage(
        id: 'msg_8',
        chatId: chatId,
        senderId: 'current_user',
        receiverId: 'user_other',
        content: '좋아요! 언제 만날까요?',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(minutes: 25)),
        status: ChatMessageStatus.delivered,
      ),
      ChatMessage(
        id: 'msg_9',
        chatId: chatId,
        senderId: 'user_other',
        receiverId: 'current_user',
        content: '내일 오후는 어떠세요?',
        type: ChatMessageType.text,
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: ChatMessageStatus.sent,
      ),
    ];
  }
}

@JsonSerializable()
class ChatRoom {
  final String id;
  final String matchId;
  final List<String> participantIds;
  final ChatMessage? lastMessage;
  final DateTime lastActivity;
  final Map<String, int> unreadCounts;
  final ChatRoomStatus status;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const ChatRoom({
    required this.id,
    required this.matchId,
    required this.participantIds,
    this.lastMessage,
    required this.lastActivity,
    required this.unreadCounts,
    required this.status,
    required this.createdAt,
    this.metadata,
  });

  // factory ChatRoom.fromJson(Map<String, dynamic> json) =>
  //     _$ChatRoomFromJson(json);

  // Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  ChatRoom copyWith({
    String? id,
    String? matchId,
    List<String>? participantIds,
    ChatMessage? lastMessage,
    DateTime? lastActivity,
    Map<String, int>? unreadCounts,
    ChatRoomStatus? status,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool hasUnreadMessages(String userId) {
    return (unreadCounts[userId] ?? 0) > 0;
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  bool get isActive => status == ChatRoomStatus.active;
  bool get isBlocked => status == ChatRoomStatus.blocked;
  bool get isArchived => status == ChatRoomStatus.archived;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays < 7) return '${difference.inDays}일 전';
    
    return '${lastActivity.month}/${lastActivity.day}';
  }
}

@JsonSerializable()
class TypingStatus {
  final String userId;
  final String chatId;
  final bool isTyping;
  final DateTime timestamp;

  const TypingStatus({
    required this.userId,
    required this.chatId,
    required this.isTyping,
    required this.timestamp,
  });

  // factory TypingStatus.fromJson(Map<String, dynamic> json) =>
  //     _$TypingStatusFromJson(json);

  // Map<String, dynamic> toJson() => _$TypingStatusToJson(this);

  bool get isExpired {
    return DateTime.now().difference(timestamp).inSeconds > 3;
  }
}

enum ChatMessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('file')
  file,
  @JsonValue('super_chat')
  superChat,
  @JsonValue('system')
  system,
}

enum ChatMessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

enum ChatRoomStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
  @JsonValue('blocked')
  blocked,
  @JsonValue('deleted')
  deleted,
}