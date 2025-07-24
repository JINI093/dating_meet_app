import 'package:json_annotation/json_annotation.dart';
import 'profile_model.dart';

// part 'superchat_model.g.dart';

/// 슈퍼챗 상태
enum SuperchatStatus {
  @JsonValue('SENT')
  sent,
  @JsonValue('READ')
  read,
  @JsonValue('REPLIED')
  replied,
  @JsonValue('EXPIRED')
  expired,
}

/// 슈퍼챗 템플릿 타입
enum SuperchatTemplateType {
  @JsonValue('CUSTOM')
  custom,
  @JsonValue('GREETING')
  greeting,
  @JsonValue('COMPLIMENT')
  compliment,
  @JsonValue('QUESTION')
  question,
  @JsonValue('INVITE')
  invite,
}

/// 슈퍼챗 모델
@JsonSerializable()
class SuperchatModel {
  final String id;
  final String fromUserId;
  final String toProfileId;
  final String message;
  final int pointsUsed;
  final SuperchatTemplateType templateType;
  final Map<String, dynamic>? customData;
  final SuperchatStatus status;
  final int priority;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 프로필 정보 (조인된 데이터, 옵셔널)
  final ProfileModel? fromProfile;
  final ProfileModel? toProfile;

  const SuperchatModel({
    required this.id,
    required this.fromUserId,
    required this.toProfileId,
    required this.message,
    required this.pointsUsed,
    this.templateType = SuperchatTemplateType.custom,
    this.customData,
    this.status = SuperchatStatus.sent,
    this.priority = 4,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.fromProfile,
    this.toProfile,
  });

  factory SuperchatModel.fromJson(Map<String, dynamic> json) {
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

    // SuperchatStatus 파싱 처리
    SuperchatStatus parseStatus(dynamic value) {
      if (value == null) return SuperchatStatus.sent;
      if (value is SuperchatStatus) return value;
      if (value is String) {
        switch (value.toUpperCase()) {
          case 'SENT':
            return SuperchatStatus.sent;
          case 'READ':
            return SuperchatStatus.read;
          case 'REPLIED':
            return SuperchatStatus.replied;
          case 'EXPIRED':
            return SuperchatStatus.expired;
          default:
            return SuperchatStatus.sent;
        }
      }
      return SuperchatStatus.sent;
    }

    // SuperchatTemplateType 파싱 처리
    SuperchatTemplateType parseTemplateType(dynamic value) {
      if (value == null) return SuperchatTemplateType.custom;
      if (value is SuperchatTemplateType) return value;
      if (value is String) {
        switch (value.toUpperCase()) {
          case 'CUSTOM':
            return SuperchatTemplateType.custom;
          case 'GREETING':
            return SuperchatTemplateType.greeting;
          case 'COMPLIMENT':
            return SuperchatTemplateType.compliment;
          case 'QUESTION':
            return SuperchatTemplateType.question;
          case 'INVITE':
            return SuperchatTemplateType.invite;
          default:
            return SuperchatTemplateType.custom;
        }
      }
      return SuperchatTemplateType.custom;
    }

    return SuperchatModel(
      id: json['id'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      toProfileId: json['toProfileId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      pointsUsed: json['pointsUsed'] as int? ?? 0,
      templateType: parseTemplateType(json['templateType']),
      customData: json['customData'] as Map<String, dynamic>?,
      status: parseStatus(json['status']),
      priority: json['priority'] as int? ?? 4,
      expiresAt: parseDateTime(json['expiresAt']),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      fromProfile: json['fromProfile'] != null ? ProfileModel.fromJson(json['fromProfile']) : null,
      toProfile: json['toProfile'] != null ? ProfileModel.fromJson(json['toProfile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toProfileId': toProfileId,
      'message': message,
      'pointsUsed': pointsUsed,
      'templateType': templateType.name,
      'customData': customData,
      'status': status.name,
      'priority': priority,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fromProfile': fromProfile?.toJson(),
      'toProfile': toProfile?.toJson(),
    };
  }

  SuperchatModel copyWith({
    String? id,
    String? fromUserId,
    String? toProfileId,
    String? message,
    int? pointsUsed,
    SuperchatTemplateType? templateType,
    Map<String, dynamic>? customData,
    SuperchatStatus? status,
    int? priority,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileModel? fromProfile,
    ProfileModel? toProfile,
  }) {
    return SuperchatModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toProfileId: toProfileId ?? this.toProfileId,
      message: message ?? this.message,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      templateType: templateType ?? this.templateType,
      customData: customData ?? this.customData,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromProfile: fromProfile ?? this.fromProfile,
      toProfile: toProfile ?? this.toProfile,
    );
  }

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

  String get timeUntilExpiry {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return '만료됨';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 남음';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 남음';
    } else {
      return '${difference.inDays}일 남음';
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isRead => status == SuperchatStatus.read || status == SuperchatStatus.replied;
  bool get isReplied => status == SuperchatStatus.replied;
  bool get isHighPriority => priority <= 2;

  String get priorityLabel {
    switch (priority) {
      case 1:
        return '💎 최고 우선순위';
      case 2:
        return '🌟 높은 우선순위';
      case 3:
        return '⭐ 중간 우선순위';
      default:
        return '✨ 기본 우선순위';
    }
  }

  String get templateTypeLabel {
    switch (templateType) {
      case SuperchatTemplateType.greeting:
        return '인사';
      case SuperchatTemplateType.compliment:
        return '칭찬';
      case SuperchatTemplateType.question:
        return '질문';
      case SuperchatTemplateType.invite:
        return '초대';
      case SuperchatTemplateType.custom:
      default:
        return '커스텀';
    }
  }

  String get statusLabel {
    switch (status) {
      case SuperchatStatus.sent:
        return '전송됨';
      case SuperchatStatus.read:
        return '읽음';
      case SuperchatStatus.replied:
        return '답장함';
      case SuperchatStatus.expired:
        return '만료됨';
    }
  }

  // Static factory methods for mock data
  static SuperchatModel createMockSuperchat({
    required String id,
    required String fromUserId,
    required String toProfileId,
    required String message,
    int pointsUsed = 100,
    SuperchatTemplateType templateType = SuperchatTemplateType.custom,
    SuperchatStatus status = SuperchatStatus.sent,
    int priority = 4,
    DateTime? createdAt,
    ProfileModel? fromProfile,
    ProfileModel? toProfile,
  }) {
    final now = DateTime.now();
    final createTime = createdAt ?? now.subtract(
      Duration(
        hours: now.millisecond % 72,
        minutes: now.second,
      ),
    );

    return SuperchatModel(
      id: id,
      fromUserId: fromUserId,
      toProfileId: toProfileId,
      message: message,
      pointsUsed: pointsUsed,
      templateType: templateType,
      status: status,
      priority: priority,
      expiresAt: createTime.add(const Duration(days: 7)),
      createdAt: createTime,
      updatedAt: createTime,
      fromProfile: fromProfile,
      toProfile: toProfile,
    );
  }

  static List<SuperchatModel> getMockReceivedSuperchats() {
    final profiles = ProfileModel.getMockProfiles();
    return [
      createMockSuperchat(
        id: 'superchat_1',
        fromUserId: 'user_1',
        toProfileId: 'current_user',
        message: '안녕하세요! 프로필을 보고 정말 매력적이라고 생각해서 연락드려요 😊',
        pointsUsed: 500,
        templateType: SuperchatTemplateType.greeting,
        priority: 2,
        status: SuperchatStatus.sent,
        fromProfile: profiles[0],
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      createMockSuperchat(
        id: 'superchat_2',
        fromUserId: 'user_2',
        toProfileId: 'current_user',
        message: '우리 취미가 비슷해 보이네요! 같이 운동하실래요?',
        pointsUsed: 200,
        templateType: SuperchatTemplateType.invite,
        priority: 3,
        status: SuperchatStatus.read,
        fromProfile: profiles[1],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      createMockSuperchat(
        id: 'superchat_3',
        fromUserId: 'user_3',
        toProfileId: 'current_user',
        message: '프로필 사진이 정말 멋지시네요! 어디서 찍으신 건가요?',
        pointsUsed: 300,
        templateType: SuperchatTemplateType.compliment,
        priority: 3,
        status: SuperchatStatus.replied,
        fromProfile: profiles[2],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  static List<SuperchatModel> getMockSentSuperchats() {
    final profiles = ProfileModel.getMockProfiles();
    return [
      createMockSuperchat(
        id: 'sent_superchat_1',
        fromUserId: 'current_user',
        toProfileId: 'user_4',
        message: '커피 한잔 어떠세요? 좋은 카페 알고 있어요!',
        pointsUsed: 250,
        templateType: SuperchatTemplateType.invite,
        priority: 3,
        status: SuperchatStatus.read,
        toProfile: profiles[3],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      createMockSuperchat(
        id: 'sent_superchat_2',
        fromUserId: 'current_user',
        toProfileId: 'user_5',
        message: '안녕하세요! 프로필을 보고 매력적이라고 생각해서 연락드려요!',
        pointsUsed: 400,
        templateType: SuperchatTemplateType.greeting,
        priority: 2,
        status: SuperchatStatus.sent,
        toProfile: profiles[4],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperchatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SuperchatModel(id: $id, fromUserId: $fromUserId, toProfileId: $toProfileId, pointsUsed: $pointsUsed, status: $status)';
  }
}