import 'package:json_annotation/json_annotation.dart';
import 'profile_model.dart';

// part 'like_model.g.dart';

/// 호감 표시 타입
enum LikeType {
  @JsonValue('LIKE')
  like,
  @JsonValue('PASS')
  pass,
  @JsonValue('SUPER_LIKE')
  superLike,
  @JsonValue('super_chat')
  superChat,
}

/// 호감 표시 모델 (AWS 기반)
@JsonSerializable()
class LikeModel {
  final String id;
  final String fromUserId;
  final String toProfileId;
  final LikeType likeType;
  final String? message;
  final bool isMatched;
  final String? matchId; // Match ID when isMatched is true
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 프로필 정보 (조인된 데이터, 옵셔널)
  final ProfileModel? profile;
  final bool isRead;

  const LikeModel({
    required this.id,
    required this.fromUserId,
    required this.toProfileId,
    required this.likeType,
    this.message,
    this.isMatched = false,
    this.matchId,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.isRead = false,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
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

    // LikeType 파싱 처리
    LikeType parseLikeType(dynamic value) {
      if (value == null) return LikeType.like;
      if (value is LikeType) return value;
      if (value is String) {
        switch (value.toUpperCase()) {
          case 'LIKE':
            return LikeType.like;
          case 'PASS':
            return LikeType.pass;
          case 'SUPER_LIKE':
            return LikeType.superLike;
          case 'SUPERCHAT':
          case 'super_chat':
            return LikeType.superChat;
          default:
            return LikeType.like;
        }
      }
      return LikeType.like;
    }

    return LikeModel(
      id: json['id'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      toProfileId: json['toProfileId'] as String? ?? '',
      likeType: parseLikeType(json['likeType'] ?? json['actionType']),
      message: json['message'] as String?,
      isMatched: json['isMatched'] as bool? ?? false,
      matchId: json['matchId'] as String?,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      profile: json['profile'] != null ? ProfileModel.fromJson(json['profile']) : null,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toProfileId': toProfileId,
      'likeType': likeType.name,
      'message': message,
      'isMatched': isMatched,
      'matchId': matchId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
      'isRead': isRead,
    };
  }

  LikeModel copyWith({
    String? id,
    String? fromUserId,
    String? toProfileId,
    LikeType? likeType,
    String? message,
    bool? isMatched,
    String? matchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileModel? profile,
    bool? isRead,
  }) {
    return LikeModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toProfileId: toProfileId ?? this.toProfileId,
      likeType: likeType ?? this.likeType,
      message: message ?? this.message,
      isMatched: isMatched ?? this.isMatched,
      matchId: matchId ?? this.matchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      isRead: isRead ?? this.isRead,
    );
  }

  // 이전 버전과의 호환성을 위한 getter
  LikeType get type => likeType;

  // Helper methods
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

  bool get isSuperChat => likeType == LikeType.superChat;

  String get displayMessage {
    if (isSuperChat && message != null) {
      return message!;
    }
    return '${profile?.name ?? "누군가"}님이 회원님을 좋아합니다.';
  }

  // Static factory methods for mock data
  static LikeModel createMockLike({
    required String id,
    required ProfileModel profile,
    DateTime? createdAt,
    bool isRead = false,
    String? message,
    LikeType type = LikeType.like,
  }) {
    final now = DateTime.now();
    final createTime = createdAt ?? now.subtract(
      Duration(
        hours: now.millisecond % 72,
        minutes: now.second,
      ),
    );
    
    return LikeModel(
      id: id,
      fromUserId: 'mock_user_$id',
      toProfileId: 'current_user',
      likeType: type,
      message: message,
      isMatched: false,
      matchId: null,
      createdAt: createTime,
      updatedAt: createTime,
      profile: profile,
      isRead: isRead,
    );
  }

  static List<LikeModel> getMockReceivedLikes() {
    final profiles = ProfileModel.getMockProfiles();
    return [
      createMockLike(
        id: 'like_1',
        profile: profiles[0],
        type: LikeType.superChat,
        message: '안녕하세요! 프로필을 보고 연락드려요 😊',
        isRead: false,
      ),
      createMockLike(
        id: 'like_2',
        profile: profiles[1],
        type: LikeType.like,
        isRead: false,
      ),
      createMockLike(
        id: 'like_3',
        profile: profiles[2],
        type: LikeType.superChat,
        message: '우리 취미가 비슷해 보이네요! 같이 운동하실래요?',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      createMockLike(
        id: 'like_4',
        profile: profiles[3],
        type: LikeType.like,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      createMockLike(
        id: 'like_5',
        profile: profiles[4],
        type: LikeType.superChat,
        message: '커피 한잔 어떠세요?',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      createMockLike(
        id: 'like_6',
        profile: profiles[5],
        type: LikeType.like,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      createMockLike(
        id: 'like_7',
        profile: profiles[6],
        type: LikeType.superChat,
        message: '프로필 사진이 정말 멋지시네요! 어디서 찍으신 건가요?',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      createMockLike(
        id: 'like_8',
        profile: profiles[7],
        type: LikeType.like,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<LikeModel> getMockSentLikes() {
    final profiles = ProfileModel.getMockProfiles();
    return [
      createMockLike(
        id: 'sent_1',
        profile: profiles[1],
        type: LikeType.like,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      createMockLike(
        id: 'sent_2',
        profile: profiles[2],
        type: LikeType.superChat,
        message: '안녕하세요! 취미가 비슷해서 연락드려요!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      createMockLike(
        id: 'sent_3',
        profile: profiles[3],
        type: LikeType.like,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      createMockLike(
        id: 'sent_4',
        profile: profiles[4],
        type: LikeType.superChat,
        message: '프로필을 보고 매력적이라고 생각해서 연락드려요 😊',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      createMockLike(
        id: 'sent_5',
        profile: profiles[5],
        type: LikeType.like,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      createMockLike(
        id: 'sent_6',
        profile: profiles[6],
        type: LikeType.like,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      createMockLike(
        id: 'sent_7',
        profile: profiles[7],
        type: LikeType.superChat,
        message: '같은 지역에 살고 계시는군요! 커피 한잔 어떠세요?',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LikeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LikeModel(id: $id, profile: ${profile?.name ?? "unknown"}, type: $type)';
  }
}