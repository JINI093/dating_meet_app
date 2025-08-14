class HeartPackage {
  final int id;
  final int baseCount;
  final int bonusCount;
  final int price;
  final String? bonusIconPath;
  final bool isPopular;

  HeartPackage({
    required this.id,
    required this.baseCount,
    required this.bonusCount,
    required this.price,
    this.bonusIconPath,
    this.isPopular = false,
  });

  int get totalCount => baseCount + bonusCount;
  bool get hasBonus => bonusCount > 0;

  factory HeartPackage.fromJson(Map<String, dynamic> json) {
    return HeartPackage(
      id: json['id'],
      baseCount: json['baseCount'],
      bonusCount: json['bonusCount'],
      price: json['price'],
      bonusIconPath: json['bonusIconPath'],
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseCount': baseCount,
      'bonusCount': bonusCount,
      'price': price,
      'bonusIconPath': bonusIconPath,
      'isPopular': isPopular,
    };
  }
}

class UserHearts {
  final String userId;
  final int currentHearts;
  final DateTime lastUpdated;

  UserHearts({
    required this.userId,
    required this.currentHearts,
    required this.lastUpdated,
  });

  factory UserHearts.fromJson(Map<String, dynamic> json) {
    return UserHearts(
      userId: json['userId'],
      currentHearts: json['currentHearts'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentHearts': currentHearts,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserHearts copyWith({
    String? userId,
    int? currentHearts,
    DateTime? lastUpdated,
  }) {
    return UserHearts(
      userId: userId ?? this.userId,
      currentHearts: currentHearts ?? this.currentHearts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class HeartTransaction {
  final String id;
  final String userId;
  final int amount;
  final String type; // 'purchase', 'spend', 'bonus'
  final String? description;
  final DateTime timestamp;

  HeartTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.timestamp,
  });

  factory HeartTransaction.fromJson(Map<String, dynamic> json) {
    return HeartTransaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}