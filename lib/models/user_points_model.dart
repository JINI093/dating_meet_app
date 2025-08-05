class UserPointsModel {
  final String userId;
  final int currentPoints;
  final int totalEarned;
  final int totalSpent;
  final DateTime lastUpdated;
  final List<PointTransaction> transactions;

  const UserPointsModel({
    required this.userId,
    required this.currentPoints,
    required this.totalEarned,
    required this.totalSpent,
    required this.lastUpdated,
    this.transactions = const [],
  });

  factory UserPointsModel.fromJson(Map<String, dynamic> json) {
    return UserPointsModel(
      userId: json['userId'] as String,
      currentPoints: json['currentPoints'] as int,
      totalEarned: json['totalEarned'] as int,
      totalSpent: json['totalSpent'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentPoints': currentPoints,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  factory UserPointsModel.initial(String userId) {
    return UserPointsModel(
      userId: userId,
      currentPoints: 302, // 초기 포인트 302로 설정
      totalEarned: 302,
      totalSpent: 0,
      lastUpdated: DateTime.now(),
      transactions: [],
    );
  }

  UserPointsModel copyWith({
    String? userId,
    int? currentPoints,
    int? totalEarned,
    int? totalSpent,
    DateTime? lastUpdated,
    List<PointTransaction>? transactions,
  }) {
    return UserPointsModel(
      userId: userId ?? this.userId,
      currentPoints: currentPoints ?? this.currentPoints,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
    );
  }

  // Helper methods
  bool canSpend(int amount) => currentPoints >= amount;
  
  UserPointsModel addPoints(int amount, String description, PointTransactionType type) {
    final transaction = PointTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );

    return copyWith(
      currentPoints: currentPoints + amount,
      totalEarned: type == PointTransactionType.earned ? totalEarned + amount : totalEarned,
      lastUpdated: DateTime.now(),
      transactions: [...transactions, transaction],
    );
  }

  UserPointsModel spendPoints(int amount, String description, PointTransactionType type) {
    if (!canSpend(amount)) {
      throw Exception('포인트가 부족합니다. 현재: $currentPoints, 필요: $amount');
    }

    final transaction = PointTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: -amount, // Negative for spending
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );

    return copyWith(
      currentPoints: currentPoints - amount,
      totalSpent: totalSpent + amount,
      lastUpdated: DateTime.now(),
      transactions: [...transactions, transaction],
    );
  }
}

class PointTransaction {
  final String id;
  final String userId;
  final int amount; // Positive for earning, negative for spending
  final PointTransactionType type;
  final String description;
  final DateTime timestamp;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      type: PointTransactionTypeExtension.fromString(json['type'] as String),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toStringValue(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isEarning => amount > 0;
  bool get isSpending => amount < 0;
  int get absoluteAmount => amount.abs();
}

enum PointTransactionType {
  purchase, // 포인트 구매
  earned, // 포인트 획득 (이벤트, 리워드 등)
  spentVip, // VIP 구매
  spentSuperchat, // 슈퍼챗 사용
  spentBoost, // 프로필 부스트
  spentUnlock, // 프로필 언락
  spentOther, // 기타 사용
  refund, // 환불
}

extension PointTransactionTypeExtension on PointTransactionType {
  String toStringValue() {
    switch (this) {
      case PointTransactionType.purchase:
        return 'purchase';
      case PointTransactionType.earned:
        return 'earned';
      case PointTransactionType.spentVip:
        return 'spent_vip';
      case PointTransactionType.spentSuperchat:
        return 'spent_superchat';
      case PointTransactionType.spentBoost:
        return 'spent_boost';
      case PointTransactionType.spentUnlock:
        return 'spent_unlock';
      case PointTransactionType.spentOther:
        return 'spent_other';
      case PointTransactionType.refund:
        return 'refund';
    }
  }

  static PointTransactionType fromString(String value) {
    switch (value) {
      case 'purchase':
        return PointTransactionType.purchase;
      case 'earned':
        return PointTransactionType.earned;
      case 'spent_vip':
        return PointTransactionType.spentVip;
      case 'spent_superchat':
        return PointTransactionType.spentSuperchat;
      case 'spent_boost':
        return PointTransactionType.spentBoost;
      case 'spent_unlock':
        return PointTransactionType.spentUnlock;
      case 'spent_other':
        return PointTransactionType.spentOther;
      case 'refund':
        return PointTransactionType.refund;
      default:
        return PointTransactionType.spentOther;
    }
  }
}