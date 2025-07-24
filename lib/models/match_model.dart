import 'package:json_annotation/json_annotation.dart';
import 'profile_model.dart';

// part 'match_model.g.dart';

@JsonSerializable()
class MatchModel {
  final String id;
  final ProfileModel profile;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnreadMessages;
  final int unreadCount;
  final MatchStatus status;
  final MatchType type; // regular match or super chat match

  const MatchModel({
    required this.id,
    required this.profile,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
    this.status = MatchStatus.active,
    this.type = MatchType.regular,
  });

  // factory MatchModel.fromJson(Map<String, dynamic> json) =>
  //     _$MatchModelFromJson(json);

  // Map<String, dynamic> toJson() => _$MatchModelToJson(this);

  MatchModel copyWith({
    String? id,
    ProfileModel? profile,
    DateTime? matchedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? hasUnreadMessages,
    int? unreadCount,
    MatchStatus? status,
    MatchType? type,
  }) {
    return MatchModel(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      matchedAt: matchedAt ?? this.matchedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final time = lastMessageTime ?? matchedAt;
    final difference = now.difference(time);

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

  String get matchTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(matchedAt);

    if (difference.inDays == 0) {
      return '오늘 매칭';
    } else if (difference.inDays == 1) {
      return '어제 매칭';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전 매칭';
    } else {
      return '${(difference.inDays / 7).floor()}주 전 매칭';
    }
  }

  bool get isNewMatch => DateTime.now().difference(matchedAt).inHours < 24;

  bool get isSuperChatMatch => type == MatchType.superChat;

  // Backward compatibility getter
  ProfileModel? get matchedUserProfile => profile;

  String get displayLastMessage {
    if (lastMessage == null || lastMessage!.isEmpty) {
      return isSuperChatMatch ? '슈퍼챗으로 매칭되었습니다' : '매칭되었습니다! 대화를 시작해보세요';
    }
    return lastMessage!;
  }

  // Static factory methods for mock data
  static MatchModel createMockMatch({
    required String id,
    required ProfileModel profile,
    DateTime? matchedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool hasUnreadMessages = false,
    int unreadCount = 0,
    MatchStatus status = MatchStatus.active,
    MatchType type = MatchType.regular,
  }) {
    final matchTime = matchedAt ?? DateTime.now().subtract(
      Duration(
        hours: DateTime.now().millisecond % 168, // Random within a week
        minutes: DateTime.now().second,
      ),
    );

    return MatchModel(
      id: id,
      profile: profile,
      matchedAt: matchTime,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime ?? (lastMessage != null ? 
        matchTime.add(Duration(hours: DateTime.now().millisecond % 48)) : null),
      hasUnreadMessages: hasUnreadMessages,
      unreadCount: unreadCount,
      status: status,
      type: type,
    );
  }

  static List<MatchModel> getMockMatches() {
    final profiles = ProfileModel.getMockProfiles();
    final now = DateTime.now();
    
    return [
      createMockMatch(
        id: 'match_1',
        profile: profiles[0],
        matchedAt: now.subtract(const Duration(minutes: 30)),
        lastMessage: '안녕하세요! 만나서 반가워요 😊',
        lastMessageTime: now.subtract(const Duration(minutes: 15)),
        hasUnreadMessages: true,
        unreadCount: 2,
        type: MatchType.superChat,
      ),
      createMockMatch(
        id: 'match_2',
        profile: profiles[1],
        matchedAt: now.subtract(const Duration(hours: 2)),
        lastMessage: '오늘 날씨가 정말 좋네요!',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        hasUnreadMessages: false,
        unreadCount: 0,
      ),
      createMockMatch(
        id: 'match_3',
        profile: profiles[2],
        matchedAt: now.subtract(const Duration(hours: 5)),
        lastMessage: '커피 한잔 어떠세요?',
        lastMessageTime: now.subtract(const Duration(hours: 3)),
        hasUnreadMessages: true,
        unreadCount: 1,
        type: MatchType.superChat,
      ),
      createMockMatch(
        id: 'match_4',
        profile: profiles[3],
        matchedAt: now.subtract(const Duration(days: 1)),
        lastMessage: '내일 오후는 어떠세요?',
        lastMessageTime: now.subtract(const Duration(hours: 18)),
        hasUnreadMessages: false,
        unreadCount: 0,
      ),
      createMockMatch(
        id: 'match_5',
        profile: profiles[4],
        matchedAt: now.subtract(const Duration(days: 2)),
        hasUnreadMessages: false,
        unreadCount: 0,
        status: MatchStatus.active,
      ),
      createMockMatch(
        id: 'match_6',
        profile: profiles[0].copyWith(
          id: 'profile_6',
          name: '지영',
          age: 32,
        ),
        matchedAt: now.subtract(const Duration(days: 3)),
        lastMessage: '영화 보러 가실래요?',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        hasUnreadMessages: false,
        unreadCount: 0,
      ),
    ];
  }

  static List<MatchModel> getMockNewMatches() {
    final profiles = ProfileModel.getMockProfiles();
    final now = DateTime.now();
    
    return [
      createMockMatch(
        id: 'new_match_1',
        profile: profiles[1],
        matchedAt: now.subtract(const Duration(minutes: 10)),
        type: MatchType.superChat,
      ),
      createMockMatch(
        id: 'new_match_2',
        profile: profiles[2],
        matchedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MatchModel(id: $id, profile: ${profile.name}, status: $status)';
  }
}

enum MatchStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
  @JsonValue('blocked')
  blocked,
}

enum MatchType {
  @JsonValue('regular')
  regular,
  @JsonValue('super_chat')
  superChat,
}