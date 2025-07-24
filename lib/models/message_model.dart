import 'package:json_annotation/json_annotation.dart';

// part 'message_model.g.dart';

/// 메시지 타입
enum MessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('IMAGE')
  image,
  @JsonValue('SUPERCHAT')
  superchat,
  @JsonValue('SYSTEM')
  system,
  @JsonValue('STICKER')
  sticker,
}

/// 메시지 상태
enum MessageStatus {
  @JsonValue('SENDING')
  sending,
  @JsonValue('SENT')
  sent,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('READ')
  read,
  @JsonValue('FAILED')
  failed,
}

/// 채팅 메시지 모델
@JsonSerializable()
class MessageModel {
  final String messageId;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? metadata;
  
  // 추가 정보
  final String? imageUrl;
  final String? thumbnailUrl;
  final int? superchatPoints;
  final String? stickerPackId;
  final String? stickerId;
  
  // 로컬 상태
  final bool isFromCurrentUser;
  final String? localId; // 전송 중인 메시지의 임시 ID

  const MessageModel({
    required this.messageId,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sending,
    required this.createdAt,
    this.readAt,
    this.deliveredAt,
    this.metadata,
    this.imageUrl,
    this.thumbnailUrl,
    this.superchatPoints,
    this.stickerPackId,
    this.stickerId,
    this.isFromCurrentUser = false,
    this.localId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // DateTime 파싱 처리
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    DateTime? parseOptionalDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // MessageType 파싱 처리
    MessageType parseMessageType(dynamic value) {
      if (value == null) return MessageType.text;
      if (value is MessageType) return value;
      if (value is String) {
        switch (value.toUpperCase()) {
          case 'TEXT':
            return MessageType.text;
          case 'IMAGE':
            return MessageType.image;
          case 'SUPERCHAT':
            return MessageType.superchat;
          case 'SYSTEM':
            return MessageType.system;
          case 'STICKER':
            return MessageType.sticker;
          default:
            return MessageType.text;
        }
      }
      return MessageType.text;
    }

    // MessageStatus 파싱 처리
    MessageStatus parseMessageStatus(dynamic value) {
      if (value == null) return MessageStatus.sent;
      if (value is MessageStatus) return value;
      if (value is String) {
        switch (value.toUpperCase()) {
          case 'SENDING':
            return MessageStatus.sending;
          case 'SENT':
            return MessageStatus.sent;
          case 'DELIVERED':
            return MessageStatus.delivered;
          case 'READ':
            return MessageStatus.read;
          case 'FAILED':
            return MessageStatus.failed;
          default:
            return MessageStatus.sent;
        }
      }
      return MessageStatus.sent;
    }

    return MessageModel(
      messageId: json['messageId'] as String? ?? '',
      matchId: json['matchId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      messageType: parseMessageType(json['messageType']),
      status: parseMessageStatus(json['status']),
      createdAt: parseDateTime(json['createdAt']),
      readAt: parseOptionalDateTime(json['readAt']),
      deliveredAt: parseOptionalDateTime(json['deliveredAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      superchatPoints: json['superchatPoints'] as int?,
      stickerPackId: json['stickerPackId'] as String?,
      stickerId: json['stickerId'] as String?,
      isFromCurrentUser: json['isFromCurrentUser'] as bool? ?? false,
      localId: json['localId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'matchId': matchId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'metadata': metadata,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'superchatPoints': superchatPoints,
      'stickerPackId': stickerPackId,
      'stickerId': stickerId,
      'isFromCurrentUser': isFromCurrentUser,
      'localId': localId,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? matchId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? messageType,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? deliveredAt,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    String? thumbnailUrl,
    int? superchatPoints,
    String? stickerPackId,
    String? stickerId,
    bool? isFromCurrentUser,
    String? localId,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      superchatPoints: superchatPoints ?? this.superchatPoints,
      stickerPackId: stickerPackId ?? this.stickerPackId,
      stickerId: stickerId ?? this.stickerId,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      localId: localId ?? this.localId,
    );
  }

  // Helper methods
  String get timeString {
    final now = DateTime.now();
    final messageTime = createdAt;
    
    // 오늘 메시지인지 확인
    final isToday = now.year == messageTime.year &&
        now.month == messageTime.month &&
        now.day == messageTime.day;
    
    if (isToday) {
      // 오늘이면 시간만 표시 (오후 2:30)
      final hour = messageTime.hour;
      final minute = messageTime.minute;
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
    } else {
      // 오늘이 아니면 날짜와 시간 모두 표시
      final month = messageTime.month;
      final day = messageTime.day;
      final hour = messageTime.hour;
      final minute = messageTime.minute;
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$month월 $day일 $period $displayHour:${minute.toString().padLeft(2, '0')}';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${(difference.inDays / 7).floor()}주 전';
    }
  }

  bool get isRead => status == MessageStatus.read;
  bool get isDelivered => status == MessageStatus.delivered || isRead;
  bool get isSent => status == MessageStatus.sent || isDelivered;
  bool get isSending => status == MessageStatus.sending;
  bool get isFailed => status == MessageStatus.failed;

  bool get isText => messageType == MessageType.text;
  bool get isImage => messageType == MessageType.image;
  bool get isSuperchat => messageType == MessageType.superchat;
  bool get isSystem => messageType == MessageType.system;
  bool get isSticker => messageType == MessageType.sticker;

  String get statusLabel {
    switch (status) {
      case MessageStatus.sending:
        return '전송 중';
      case MessageStatus.sent:
        return '전송됨';
      case MessageStatus.delivered:
        return '전달됨';
      case MessageStatus.read:
        return '읽음';
      case MessageStatus.failed:
        return '전송 실패';
    }
  }

  String get typeLabel {
    switch (messageType) {
      case MessageType.text:
        return '텍스트';
      case MessageType.image:
        return '이미지';
      case MessageType.superchat:
        return '슈퍼챗';
      case MessageType.system:
        return '시스템';
      case MessageType.sticker:
        return '스티커';
    }
  }

  /// 메시지가 같은 날인지 확인
  bool isSameDay(MessageModel other) {
    return createdAt.year == other.createdAt.year &&
        createdAt.month == other.createdAt.month &&
        createdAt.day == other.createdAt.day;
  }

  /// 날짜 구분선 표시용 날짜 문자열
  String get dateString {
    final now = DateTime.now();
    final messageDate = createdAt;
    
    // 오늘인지 확인
    final isToday = now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day;
    
    if (isToday) {
      return '오늘';
    }
    
    // 어제인지 확인
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == messageDate.year &&
        yesterday.month == messageDate.month &&
        yesterday.day == messageDate.day;
    
    if (isYesterday) {
      return '어제';
    }
    
    // 올해인지 확인
    if (now.year == messageDate.year) {
      return '${messageDate.month}월 ${messageDate.day}일';
    }
    
    // 다른 해
    return '${messageDate.year}년 ${messageDate.month}월 ${messageDate.day}일';
  }

  // Static factory methods for creating different types of messages
  static MessageModel createTextMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    bool isFromCurrentUser = false,
    String? localId,
  }) {
    return MessageModel(
      messageId: localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      messageType: MessageType.text,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      isFromCurrentUser: isFromCurrentUser,
      localId: localId,
    );
  }

  static MessageModel createImageMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String imageUrl,
    String? thumbnailUrl,
    String content = '',
    bool isFromCurrentUser = false,
    String? localId,
  }) {
    return MessageModel(
      messageId: localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      messageType: MessageType.image,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      isFromCurrentUser: isFromCurrentUser,
      localId: localId,
    );
  }

  static MessageModel createSuperchatMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    required int superchatPoints,
    bool isFromCurrentUser = false,
    String? localId,
  }) {
    return MessageModel(
      messageId: localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      messageType: MessageType.superchat,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      superchatPoints: superchatPoints,
      isFromCurrentUser: isFromCurrentUser,
      localId: localId,
    );
  }

  static MessageModel createSystemMessage({
    required String matchId,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: matchId,
      senderId: 'system',
      receiverId: '',
      content: content,
      messageType: MessageType.system,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  // Mock data for testing
  static List<MessageModel> getMockMessages(String matchId, String currentUserId, String otherUserId) {
    final now = DateTime.now();
    return [
      MessageModel(
        messageId: 'msg_1',
        matchId: matchId,
        senderId: otherUserId,
        receiverId: currentUserId,
        content: '안녕하세요! 만나서 반가워요 😊',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(hours: 2)),
        readAt: now.subtract(const Duration(hours: 1, minutes: 50)),
        isFromCurrentUser: false,
      ),
      MessageModel(
        messageId: 'msg_2',
        matchId: matchId,
        senderId: currentUserId,
        receiverId: otherUserId,
        content: '안녕하세요! 저도 반가워요',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 55)),
        readAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        isFromCurrentUser: true,
      ),
      MessageModel(
        messageId: 'msg_3',
        matchId: matchId,
        senderId: otherUserId,
        receiverId: currentUserId,
        content: '프로필을 보니 취미가 비슷하네요!',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        readAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        isFromCurrentUser: false,
      ),
      MessageModel(
        messageId: 'msg_4',
        matchId: matchId,
        senderId: currentUserId,
        receiverId: otherUserId,
        content: '맞아요! 등산 자주 가시나요?',
        status: MessageStatus.delivered,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        deliveredAt: now.subtract(const Duration(hours: 1, minutes: 25)),
        isFromCurrentUser: true,
      ),
      MessageModel(
        messageId: 'msg_5',
        matchId: matchId,
        senderId: otherUserId,
        receiverId: currentUserId,
        content: '네! 주말마다 가려고 해요. 다음 주말에 같이 가시겠어요?',
        status: MessageStatus.sent,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isFromCurrentUser: false,
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && 
        (other.messageId == messageId || 
         (other.localId != null && other.localId == localId));
  }

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, matchId: $matchId, senderId: $senderId, content: $content, type: $messageType, status: $status)';
  }
}