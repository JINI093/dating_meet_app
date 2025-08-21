/// 신고 유형 열거형
enum ReportType {
  profileAbuse('프로필 악용'),
  inappropriateContent('부적절한 내용'),
  harassment('괴롭힘'),
  spam('스팸'),
  scam('사기'),
  fakeProfile('가짜 프로필'),
  underage('미성년자'),
  violence('폭력적 내용'),
  sexualContent('성적 내용'),
  other('기타');

  const ReportType(this.displayName);
  final String displayName;
}

/// 신고 상태 열거형
enum ReportStatus {
  pending('접수'),
  inProgress('처리중'),
  resolved('처리완료'),
  rejected('반려'),
  closed('종료');

  const ReportStatus(this.displayName);
  final String displayName;
}

/// 신고 우선순위 열거형
enum ReportPriority {
  low('낮음'),
  normal('보통'),
  high('높음'),
  urgent('긴급');

  const ReportPriority(this.displayName);
  final String displayName;
}

/// 신고 처리 결과 열거형
enum ReportAction {
  suspended3Days('3일 이용정지'),
  suspended5Days('5일 이용정지'),
  suspended30Days('30일 이용정지'),
  suspendedPermanent('영구 이용정지'),
  rejected('반려'),
  warning('경고');

  const ReportAction(this.displayName);
  final String displayName;
}

/// 신고 모델
class ReportModel {
  final String id;
  final String reporterUserId;
  final String reporterName;
  final String reportedUserId;
  final String reportedName;
  final ReportType reportType;
  final String reportReason;
  final String reportContent;
  final List<String> evidence;
  final ReportStatus status;
  final ReportPriority priority;
  final ReportAction? action;
  final String? adminNotes;
  final String? processedBy;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.id,
    required this.reporterUserId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedName,
    required this.reportType,
    required this.reportReason,
    required this.reportContent,
    this.evidence = const [],
    required this.status,
    required this.priority,
    this.action,
    this.adminNotes,
    this.processedBy,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 신고 생성/수정을 위한 DTO 클래스
  static ReportCreateUpdateDto createDto({
    required String reporterUserId,
    required String reporterName,
    required String reportedUserId,
    required String reportedName,
    required ReportType reportType,
    required String reportReason,
    required String reportContent,
    List<String> evidence = const [],
    ReportPriority priority = ReportPriority.normal,
  }) {
    return ReportCreateUpdateDto(
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      reportedUserId: reportedUserId,
      reportedName: reportedName,
      reportType: reportType,
      reportReason: reportReason,
      reportContent: reportContent,
      evidence: evidence,
      priority: priority,
    );
  }

  /// copyWith 메서드
  ReportModel copyWith({
    String? id,
    String? reporterUserId,
    String? reporterName,
    String? reportedUserId,
    String? reportedName,
    ReportType? reportType,
    String? reportReason,
    String? reportContent,
    List<String>? evidence,
    ReportStatus? status,
    ReportPriority? priority,
    ReportAction? action,
    String? adminNotes,
    String? processedBy,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterUserId: reporterUserId ?? this.reporterUserId,
      reporterName: reporterName ?? this.reporterName,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedName: reportedName ?? this.reportedName,
      reportType: reportType ?? this.reportType,
      reportReason: reportReason ?? this.reportReason,
      reportContent: reportContent ?? this.reportContent,
      evidence: evidence ?? this.evidence,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      action: action ?? this.action,
      adminNotes: adminNotes ?? this.adminNotes,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 신고 미리보기 텍스트
  String get contentPreview {
    if (reportContent.length <= 50) return reportContent;
    return '${reportContent.substring(0, 50)}...';
  }

  /// 신고 처리 여부
  bool get isProcessed => status == ReportStatus.resolved || status == ReportStatus.rejected || status == ReportStatus.closed;

  /// 신고 표시 우선순위 (정렬용)
  int get displayPriority {
    switch (priority) {
      case ReportPriority.urgent:
        return 4;
      case ReportPriority.high:
        return 3;
      case ReportPriority.normal:
        return 2;
      case ReportPriority.low:
        return 1;
    }
  }

  /// 처리까지 걸린 시간 계산
  Duration? get processingTime {
    if (processedAt == null) return null;
    return processedAt!.difference(createdAt);
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterUserId': reporterUserId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedName': reportedName,
      'reportType': reportType.name,
      'reportReason': reportReason,
      'reportContent': reportContent,
      'evidence': evidence,
      'status': status.name,
      'priority': priority.name,
      'action': action?.name,
      'adminNotes': adminNotes,
      'processedBy': processedBy,
      'processedAt': processedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reporterUserId: json['reporterUserId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      reportedUserId: json['reportedUserId'] ?? '',
      reportedName: json['reportedName'] ?? '',
      reportType: ReportType.values.firstWhere(
        (type) => type.name == json['reportType'],
        orElse: () => ReportType.other,
      ),
      reportReason: json['reportReason'] ?? '',
      reportContent: json['reportContent'] ?? '',
      evidence: List<String>.from(json['evidence'] ?? []),
      status: ReportStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      priority: ReportPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => ReportPriority.normal,
      ),
      action: json['action'] != null 
          ? ReportAction.values.firstWhere(
              (action) => action.name == json['action'],
              orElse: () => ReportAction.warning,
            )
          : null,
      adminNotes: json['adminNotes'],
      processedBy: json['processedBy'],
      processedAt: json['processedAt'] != null 
          ? DateTime.tryParse(json['processedAt'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// 신고 생성/수정을 위한 DTO
class ReportCreateUpdateDto {
  final String reporterUserId;
  final String reporterName;
  final String reportedUserId;
  final String reportedName;
  final ReportType reportType;
  final String reportReason;
  final String reportContent;
  final List<String> evidence;
  final ReportPriority priority;
  final String? adminNotes;

  ReportCreateUpdateDto({
    required this.reporterUserId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedName,
    required this.reportType,
    required this.reportReason,
    required this.reportContent,
    this.evidence = const [],
    this.priority = ReportPriority.normal,
    this.adminNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reporterUserId': reporterUserId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedName': reportedName,
      'reportType': reportType.name,
      'reportReason': reportReason,
      'reportContent': reportContent,
      'evidence': evidence,
      'priority': priority.name,
      'adminNotes': adminNotes,
    };
  }
}

/// 신고 처리를 위한 DTO
class ReportProcessDto {
  final ReportStatus status;
  final ReportAction? action;
  final String? adminNotes;
  final String processedBy;

  ReportProcessDto({
    required this.status,
    this.action,
    this.adminNotes,
    required this.processedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'action': action?.name,
      'adminNotes': adminNotes,
      'processedBy': processedBy,
    };
  }
}