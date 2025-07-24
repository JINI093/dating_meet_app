import 'package:json_annotation/json_annotation.dart';

// part 'point_model.g.dart';

@JsonSerializable()
class PointItem {
  final String id;
  final String name;
  final String description;
  final String category; // 'boost', 'super_chat', 'view', 'special'
  final int points;
  final int? bonusPoints;
  final String iconUrl;
  final bool isPopular;
  final bool isLimited;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  const PointItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.points,
    this.bonusPoints,
    required this.iconUrl,
    this.isPopular = false,
    this.isLimited = false,
    this.expiresAt,
    this.metadata,
  });

  // factory PointItem.fromJson(Map<String, dynamic> json) =>
  //     _$PointItemFromJson(json);

  // Map<String, dynamic> toJson() => _$PointItemToJson(this);

  PointItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? points,
    int? bonusPoints,
    String? iconUrl,
    bool? isPopular,
    bool? isLimited,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return PointItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      iconUrl: iconUrl ?? this.iconUrl,
      isPopular: isPopular ?? this.isPopular,
      isLimited: isLimited ?? this.isLimited,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  int get totalPoints => points + (bonusPoints ?? 0);

  String get categoryDisplayName {
    switch (category) {
      case 'boost':
        return '부스터';
      case 'super_chat':
        return '슈퍼챗';
      case 'view':
        return '프로필 보기';
      case 'special':
        return '스페셜';
      default:
        return '기타';
    }
  }

  bool get hasBonus => bonusPoints != null && bonusPoints! > 0;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  // Mock data generators
  static List<PointItem> getMockBoostItems() {
    return [
      PointItem(
        id: 'boost_1',
        name: '프로필 부스트 1시간',
        description: '내 프로필이 1시간 동안 상위에 노출됩니다',
        category: 'boost',
        points: 50,
        iconUrl: 'assets/icons/boost.png',
        isPopular: true,
      ),
      PointItem(
        id: 'boost_2',
        name: '프로필 부스트 3시간',
        description: '내 프로필이 3시간 동안 상위에 노출됩니다',
        category: 'boost',
        points: 120,
        bonusPoints: 30,
        iconUrl: 'assets/icons/boost.png',
        isPopular: true,
      ),
      PointItem(
        id: 'boost_3',
        name: '프로필 부스트 24시간',
        description: '내 프로필이 하루 종일 상위에 노출됩니다',
        category: 'boost',
        points: 400,
        bonusPoints: 100,
        iconUrl: 'assets/icons/boost.png',
      ),
    ];
  }

  static List<PointItem> getMockSuperChatItems() {
    return [
      PointItem(
        id: 'superchat_1',
        name: '슈퍼챗 3개',
        description: '특별한 메시지로 어필해보세요',
        category: 'super_chat',
        points: 90,
        iconUrl: 'assets/icons/super_chat.png',
        isPopular: true,
      ),
      PointItem(
        id: 'superchat_2',
        name: '슈퍼챗 10개',
        description: '더 많은 기회로 매칭률을 높여보세요',
        category: 'super_chat',
        points: 250,
        bonusPoints: 50,
        iconUrl: 'assets/icons/super_chat.png',
        isPopular: true,
      ),
      PointItem(
        id: 'superchat_3',
        name: '슈퍼챗 30개',
        description: '한 달 동안 충분히 사용할 수 있어요',
        category: 'super_chat',
        points: 600,
        bonusPoints: 200,
        iconUrl: 'assets/icons/super_chat.png',
      ),
    ];
  }

  static List<PointItem> getMockViewItems() {
    return [
      PointItem(
        id: 'view_1',
        name: '좋아요 한 사람 보기',
        description: '나에게 좋아요를 보낸 사람을 확인해보세요',
        category: 'view',
        points: 30,
        iconUrl: 'assets/icons/view.png',
        isPopular: true,
      ),
      PointItem(
        id: 'view_2',
        name: '프로필 방문자 보기',
        description: '내 프로필을 본 사람들을 확인해보세요',
        category: 'view',
        points: 20,
        iconUrl: 'assets/icons/view.png',
      ),
      PointItem(
        id: 'view_3',
        name: '읽음 확인',
        description: '메시지를 읽었는지 확인할 수 있어요',
        category: 'view',
        points: 15,
        iconUrl: 'assets/icons/read.png',
      ),
    ];
  }

  static List<PointItem> getMockSpecialItems() {
    return [
      PointItem(
        id: 'special_1',
        name: '되돌리기',
        description: '실수로 패스한 프로필을 되돌릴 수 있어요',
        category: 'special',
        points: 25,
        iconUrl: 'assets/icons/rewind.png',
        isPopular: true,
      ),
      PointItem(
        id: 'special_2',
        name: '무제한 좋아요',
        description: '하루 동안 좋아요 제한이 없어져요',
        category: 'special',
        points: 80,
        iconUrl: 'assets/icons/unlimited.png',
        isLimited: true,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
      PointItem(
        id: 'special_3',
        name: '프리미엄 필터',
        description: '더 정확한 조건으로 상대를 찾아보세요',
        category: 'special',
        points: 150,
        bonusPoints: 50,
        iconUrl: 'assets/icons/filter.png',
      ),
    ];
  }

  static List<PointItem> getAllMockItems() {
    return [
      ...getMockBoostItems(),
      ...getMockSuperChatItems(),
      ...getMockViewItems(),
      ...getMockSpecialItems(),
    ];
  }
}

@JsonSerializable()
class PointPurchase {
  final String id;
  final String itemId;
  final String itemName;
  final int pointsSpent;
  final DateTime purchasedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final PurchaseStatus status;

  const PointPurchase({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.pointsSpent,
    required this.purchasedAt,
    this.usedAt,
    this.expiresAt,
    required this.status,
  });

  // factory PointPurchase.fromJson(Map<String, dynamic> json) =>
  //     _$PointPurchaseFromJson(json);

  // Map<String, dynamic> toJson() => _$PointPurchaseToJson(this);

  bool get isUsed => usedAt != null;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => status == PurchaseStatus.active && !isExpired;

  String get statusDisplayName {
    switch (status) {
      case PurchaseStatus.active:
        return isExpired ? '만료됨' : '사용 가능';
      case PurchaseStatus.used:
        return '사용 완료';
      case PurchaseStatus.expired:
        return '만료됨';
      case PurchaseStatus.refunded:
        return '환불됨';
    }
  }
}

enum PurchaseStatus {
  @JsonValue('active')
  active,
  @JsonValue('used')
  used,
  @JsonValue('expired')
  expired,
  @JsonValue('refunded')
  refunded,
}

@JsonSerializable()
class PointTransaction {
  final String id;
  final int amount;
  final PointTransactionType type;
  final String description;
  final DateTime createdAt;
  final String? relatedItemId;
  final Map<String, dynamic>? metadata;

  const PointTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.relatedItemId,
    this.metadata,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      type: PointTransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'earned').toLowerCase(),
        orElse: () => PointTransactionType.earned,
      ),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedItemId: json['relatedItemId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.name.toUpperCase(),
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'relatedItemId': relatedItemId,
    'metadata': metadata,
  };

  bool get isEarned => type == PointTransactionType.earned;
  bool get isSpent => type == PointTransactionType.spent;

  String get typeDisplayName {
    switch (type) {
      case PointTransactionType.earned:
        return '획득';
      case PointTransactionType.spent:
        return '사용';
      case PointTransactionType.refund:
        return '환불';
      case PointTransactionType.bonus:
        return '보너스';
      case PointTransactionType.purchase:
        return '구매';
      case PointTransactionType.superchat:
        return '슈퍼챗';
      case PointTransactionType.gift:
        return '선물';
      case PointTransactionType.reward:
        return '보상';
      case PointTransactionType.dailyLogin:
        return '출석체크';
      case PointTransactionType.profileCompletion:
        return '프로필완성';
    }
  }

  static List<PointTransaction> getMockTransactions() {
    final now = DateTime.now();
    return [
      PointTransaction(
        id: 'tx_1',
        amount: 100,
        type: PointTransactionType.earned,
        description: '회원가입 보너스',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      PointTransaction(
        id: 'tx_2',
        amount: -50,
        type: PointTransactionType.spent,
        description: '프로필 부스트 1시간 구매',
        createdAt: now.subtract(const Duration(days: 5)),
        relatedItemId: 'boost_1',
      ),
      PointTransaction(
        id: 'tx_3',
        amount: 50,
        type: PointTransactionType.bonus,
        description: '매일 출석 보너스',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PointTransaction(
        id: 'tx_4',
        amount: -90,
        type: PointTransactionType.spent,
        description: '슈퍼챗 3개 구매',
        createdAt: now.subtract(const Duration(days: 2)),
        relatedItemId: 'superchat_1',
      ),
      PointTransaction(
        id: 'tx_5',
        amount: -30,
        type: PointTransactionType.spent,
        description: '좋아요 한 사람 보기',
        createdAt: now.subtract(const Duration(days: 1)),
        relatedItemId: 'view_1',
      ),
    ];
  }
}

enum PointTransactionType {
  @JsonValue('earned')
  earned,
  @JsonValue('spent')
  spent,
  @JsonValue('refund')
  refund,
  @JsonValue('bonus')
  bonus,
  @JsonValue('PURCHASE')
  purchase,
  @JsonValue('SUPERCHAT')
  superchat,
  @JsonValue('GIFT')
  gift,
  @JsonValue('REWARD')
  reward,
  @JsonValue('DAILY_LOGIN')
  dailyLogin,
  @JsonValue('PROFILE_COMPLETION')
  profileCompletion,
}

/// 포인트 거래 상태 (새로운 시스템용)
enum PointTransactionStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REFUNDED')
  refunded,
}

/// 사용자 포인트 잔액 모델 (새로운 시스템용)
@JsonSerializable()
class UserPointsModel {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int pendingPoints;
  final int usedPoints;
  final DateTime lastUpdated;

  const UserPointsModel({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    this.pendingPoints = 0,
    this.usedPoints = 0,
    required this.lastUpdated,
  });

  factory UserPointsModel.fromJson(Map<String, dynamic> json) {
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

    return UserPointsModel(
      userId: json['userId'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      availablePoints: json['availablePoints'] as int? ?? 0,
      pendingPoints: json['pendingPoints'] as int? ?? 0,
      usedPoints: json['usedPoints'] as int? ?? 0,
      lastUpdated: parseDateTime(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'pendingPoints': pendingPoints,
      'usedPoints': usedPoints,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPointsModel copyWith({
    String? userId,
    int? totalPoints,
    int? availablePoints,
    int? pendingPoints,
    int? usedPoints,
    DateTime? lastUpdated,
  }) {
    return UserPointsModel(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods
  bool get hasPoints => availablePoints > 0;
  bool get hasPendingPoints => pendingPoints > 0;
  
  bool canAfford(int amount) => availablePoints >= amount;
  
  String get formattedAvailablePoints => availablePoints.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  String get formattedTotalPoints => totalPoints.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPointsModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserPointsModel(userId: $userId, availablePoints: $availablePoints, totalPoints: $totalPoints)';
  }
}