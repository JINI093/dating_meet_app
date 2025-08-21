
/// 공지사항 대상 타입
enum NoticeTargetType {
  all('전체'),
  male('남성회원'),
  female('여성회원'),
  vip('VIP회원');

  const NoticeTargetType(this.displayName);
  final String displayName;
}

/// 공지사항 상태
enum NoticeStatus {
  draft('임시저장'),
  published('게시중'),
  scheduled('예약게시'),
  archived('보관됨');

  const NoticeStatus(this.displayName);
  final String displayName;
}

/// 공지사항 모델
class NoticeModel {
  final String id;
  final String title;
  final String content;
  final NoticeTargetType targetType;
  final NoticeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? scheduledAt;
  final String authorId;
  final String authorName;
  final int viewCount;
  final bool isPinned;
  final bool isImportant;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.targetType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.scheduledAt,
    required this.authorId,
    required this.authorName,
    this.viewCount = 0,
    this.isPinned = false,
    this.isImportant = false,
    this.tags = const [],
    this.metadata,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      targetType: NoticeTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => NoticeTargetType.all,
      ),
      status: NoticeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NoticeStatus.draft,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      isImportant: json['isImportant'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'targetType': targetType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'viewCount': viewCount,
      'isPinned': isPinned,
      'isImportant': isImportant,
      'tags': tags,
      'metadata': metadata,
    };
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? content,
    NoticeTargetType? targetType,
    NoticeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    String? authorId,
    String? authorName,
    int? viewCount,
    bool? isPinned,
    bool? isImportant,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      targetType: targetType ?? this.targetType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
      isImportant: isImportant ?? this.isImportant,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 공지사항이 현재 게시 중인지 확인
  bool get isPublished => status == NoticeStatus.published;

  /// 공지사항이 예약 게시인지 확인
  bool get isScheduled => status == NoticeStatus.scheduled;

  /// 공지사항의 표시 우선순위 (고정 > 중요 > 일반)
  int get displayPriority {
    if (isPinned) return 3;
    if (isImportant) return 2;
    return 1;
  }

  /// 공지사항 내용 미리보기 (최대 100자)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }
}

/// 공지사항 생성/수정을 위한 DTO
class NoticeCreateUpdateDto {
  final String title;
  final String content;
  final NoticeTargetType targetType;
  final NoticeStatus status;
  final DateTime? scheduledAt;
  final bool isPinned;
  final bool isImportant;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const NoticeCreateUpdateDto({
    required this.title,
    required this.content,
    required this.targetType,
    this.status = NoticeStatus.draft,
    this.scheduledAt,
    this.isPinned = false,
    this.isImportant = false,
    this.tags = const [],
    this.metadata,
  });

  factory NoticeCreateUpdateDto.fromJson(Map<String, dynamic> json) {
    return NoticeCreateUpdateDto(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      targetType: NoticeTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => NoticeTargetType.all,
      ),
      status: NoticeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NoticeStatus.draft,
      ),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      isPinned: json['isPinned'] ?? false,
      isImportant: json['isImportant'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'targetType': targetType.name,
      'status': status.name,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isPinned': isPinned,
      'isImportant': isImportant,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory NoticeCreateUpdateDto.fromNotice(NoticeModel notice) {
    return NoticeCreateUpdateDto(
      title: notice.title,
      content: notice.content,
      targetType: notice.targetType,
      status: notice.status,
      scheduledAt: notice.scheduledAt,
      isPinned: notice.isPinned,
      isImportant: notice.isImportant,
      tags: notice.tags,
      metadata: notice.metadata,
    );
  }
}