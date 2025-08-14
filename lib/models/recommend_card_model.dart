// 추천카드 더보기 패키지 모델
class RecommendCardPackage {
  final int id;
  final int baseCount;
  final int bonusCount;
  final int price;
  final String? bonusIconPath;

  RecommendCardPackage({
    required this.id,
    required this.baseCount,
    required this.bonusCount,
    required this.price,
    this.bonusIconPath,
  });

  int get totalCount => baseCount + bonusCount;
  bool get hasBonus => bonusCount > 0;

  factory RecommendCardPackage.fromJson(Map<String, dynamic> json) {
    return RecommendCardPackage(
      id: json['id'] as int,
      baseCount: json['baseCount'] as int,
      bonusCount: json['bonusCount'] as int,
      price: json['price'] as int,
      bonusIconPath: json['bonusIconPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseCount': baseCount,
      'bonusCount': bonusCount,
      'price': price,
      'bonusIconPath': bonusIconPath,
    };
  }
}

// 추천카드 더보기 트랜잭션 모델
class RecommendCardTransaction {
  final String id;
  final String userId;
  final int amount; // 양수: 구매, 음수: 사용
  final String type; // 'purchase' 또는 'spend'
  final String description;
  final DateTime timestamp;

  RecommendCardTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory RecommendCardTransaction.fromJson(Map<String, dynamic> json) {
    return RecommendCardTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
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