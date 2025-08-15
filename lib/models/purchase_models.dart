import 'package:in_app_purchase/in_app_purchase.dart';

/// 구매 결과 상태
enum PurchaseResultStatus {
  pending,   // 대기 중
  success,   // 성공
  error,     // 실패
  canceled,  // 취소
  restored,  // 복원
}

/// 구매 결과 모델
class PurchaseResult {
  final PurchaseResultStatus status;
  final String productId;
  final String? transactionId;
  final String? error;
  final PurchaseDetails? purchaseDetails;
  final DateTime timestamp;

  PurchaseResult({
    required this.status,
    required this.productId,
    this.transactionId,
    this.error,
    this.purchaseDetails,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => status == PurchaseResultStatus.success;
  bool get isError => status == PurchaseResultStatus.error;
  bool get isPending => status == PurchaseResultStatus.pending;
  bool get isCanceled => status == PurchaseResultStatus.canceled;
  bool get isRestored => status == PurchaseResultStatus.restored;

  @override
  String toString() {
    return 'PurchaseResult{status: $status, productId: $productId, transactionId: $transactionId, error: $error}';
  }
}

/// 구매 가능한 제품 타입
enum ProductType {
  vip,      // VIP 구독
  points,   // 포인트
  hearts,   // 하트
}

/// 구매 제품 정보
class PurchaseProduct {
  final String id;
  final String name;
  final String description;
  final String price;
  final ProductType type;
  final Map<String, dynamic>? metadata;

  const PurchaseProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.metadata,
  });

  factory PurchaseProduct.fromProductDetails(ProductDetails details) {
    ProductType type;
    if (details.id.contains('vip')) {
      type = ProductType.vip;
    } else if (details.id.contains('points')) {
      type = ProductType.points;
    } else if (details.id.contains('hearts')) {
      type = ProductType.hearts;
    } else {
      type = ProductType.points; // 기본값
    }

    return PurchaseProduct(
      id: details.id,
      name: details.title,
      description: details.description,
      price: details.price,
      type: type,
      metadata: {
        'currencyCode': details.currencyCode,
        'rawPrice': details.rawPrice,
      },
    );
  }

  @override
  String toString() {
    return 'PurchaseProduct{id: $id, name: $name, price: $price, type: $type}';
  }
}

/// VIP 제품 정보
class VipProduct extends PurchaseProduct {
  final String vipTier;      // BASIC, PREMIUM, GOLD
  final int durationDays;    // 기간 (일)
  final List<String> features; // 기능 목록

  const VipProduct({
    required String id,
    required String name,
    required String description,
    required String price,
    required this.vipTier,
    required this.durationDays,
    required this.features,
    Map<String, dynamic>? metadata,
  }) : super(
         id: id,
         name: name,
         description: description,
         price: price,
         type: ProductType.vip,
         metadata: metadata,
       );

  factory VipProduct.fromProductDetails(ProductDetails details) {
    // ID에서 VIP 등급과 기간 추출
    String vipTier = 'BASIC';
    int durationDays = 30;
    List<String> features = [];

    if (details.id.contains('premium')) {
      vipTier = 'PREMIUM';
      features = [
        '무제한 좋아요',
        '슈퍼챗 5개/일',
        '프로필 부스트',
        '고급 필터',
      ];
    } else if (details.id.contains('gold')) {
      vipTier = 'GOLD';
      features = [
        '무제한 좋아요',
        '무제한 슈퍼챗',
        '프로필 부스트',
        '모든 필터',
        '우선 고객지원',
      ];
    } else {
      features = [
        '무제한 좋아요',
        '슈퍼챗 2개/일',
        '기본 필터',
      ];
    }

    if (details.id.contains('3months')) {
      durationDays = 90;
    }

    return VipProduct(
      id: details.id,
      name: details.title,
      description: details.description,
      price: details.price,
      vipTier: vipTier,
      durationDays: durationDays,
      features: features,
      metadata: {
        'currencyCode': details.currencyCode,
        'rawPrice': details.rawPrice,
      },
    );
  }
}

/// 포인트 제품 정보
class PointsProduct extends PurchaseProduct {
  final int pointsAmount;    // 포인트 수량
  final int bonusPoints;     // 보너스 포인트

  const PointsProduct({
    required String id,
    required String name,
    required String description,
    required String price,
    required this.pointsAmount,
    this.bonusPoints = 0,
    Map<String, dynamic>? metadata,
  }) : super(
         id: id,
         name: name,
         description: description,
         price: price,
         type: ProductType.points,
         metadata: metadata,
       );

  int get totalPoints => pointsAmount + bonusPoints;

  factory PointsProduct.fromProductDetails(ProductDetails details) {
    // ID에서 포인트 수량 추출
    int pointsAmount = 100; // 기본값
    int bonusPoints = 0;

    if (details.id.contains('100')) {
      pointsAmount = 100;
    } else if (details.id.contains('500')) {
      pointsAmount = 500;
      bonusPoints = 50; // 10% 보너스
    } else if (details.id.contains('1000')) {
      pointsAmount = 1000;
      bonusPoints = 150; // 15% 보너스
    } else if (details.id.contains('3000')) {
      pointsAmount = 3000;
      bonusPoints = 600; // 20% 보너스
    } else if (details.id.contains('5000')) {
      pointsAmount = 5000;
      bonusPoints = 1250; // 25% 보너스
    }

    return PointsProduct(
      id: details.id,
      name: details.title,
      description: details.description,
      price: details.price,
      pointsAmount: pointsAmount,
      bonusPoints: bonusPoints,
      metadata: {
        'currencyCode': details.currencyCode,
        'rawPrice': details.rawPrice,
      },
    );
  }
}

/// 하트 제품 정보
class HeartsProduct extends PurchaseProduct {
  final int heartsAmount;    // 하트 수량
  final int bonusHearts;     // 보너스 하트

  const HeartsProduct({
    required String id,
    required String name,
    required String description,
    required String price,
    required this.heartsAmount,
    this.bonusHearts = 0,
    Map<String, dynamic>? metadata,
  }) : super(
         id: id,
         name: name,
         description: description,
         price: price,
         type: ProductType.hearts,
         metadata: metadata,
       );

  int get totalHearts => heartsAmount + bonusHearts;

  factory HeartsProduct.fromProductDetails(ProductDetails details) {
    // ID에서 하트 수량 추출
    int heartsAmount = 10; // 기본값
    int bonusHearts = 0;

    if (details.id.contains('10')) {
      heartsAmount = 10;
    } else if (details.id.contains('50')) {
      heartsAmount = 50;
      bonusHearts = 5; // 10% 보너스
    } else if (details.id.contains('100')) {
      heartsAmount = 100;
      bonusHearts = 15; // 15% 보너스
    } else if (details.id.contains('500')) {
      heartsAmount = 500;
      bonusHearts = 100; // 20% 보너스
    }

    return HeartsProduct(
      id: details.id,
      name: details.title,
      description: details.description,
      price: details.price,
      heartsAmount: heartsAmount,
      bonusHearts: bonusHearts,
      metadata: {
        'currencyCode': details.currencyCode,
        'rawPrice': details.rawPrice,
      },
    );
  }
}

/// 구매 히스토리
class PurchaseHistory {
  final String id;
  final String productId;
  final String productName;
  final ProductType productType;
  final String price;
  final DateTime purchaseDate;
  final String transactionId;
  final PurchaseResultStatus status;

  const PurchaseHistory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.price,
    required this.purchaseDate,
    required this.transactionId,
    required this.status,
  });

  factory PurchaseHistory.fromPurchaseResult(PurchaseResult result, PurchaseProduct product) {
    return PurchaseHistory(
      id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
      productId: result.productId,
      productName: product.name,
      productType: product.type,
      price: product.price,
      purchaseDate: result.timestamp,
      transactionId: result.transactionId ?? '',
      status: result.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productType': productType.toString(),
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'transactionId': transactionId,
      'status': status.toString(),
    };
  }

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productType: ProductType.values.firstWhere(
        (e) => e.toString() == json['productType'],
        orElse: () => ProductType.points,
      ),
      price: json['price'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      transactionId: json['transactionId'],
      status: PurchaseResultStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PurchaseResultStatus.success,
      ),
    );
  }
}