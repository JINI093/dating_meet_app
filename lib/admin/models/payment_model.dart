/// 결제 상태 열거형
enum PaymentStatus {
  pending('대기중'),
  completed('완료'),
  failed('실패'),
  cancelled('취소'),
  refunded('환불'),
  partialRefund('부분환불');

  const PaymentStatus(this.displayName);
  final String displayName;
}

/// 결제 방법 열거형
enum PaymentMethod {
  creditCard('카드'),
  bankTransfer('계좌이체'),
  paypal('페이팔'),
  googlePlay('구글플레이'),
  appStore('앱스토어'),
  kakaoPay('카카오페이'),
  naverpay('네이버페이');

  const PaymentMethod(this.displayName);
  final String displayName;
}

/// 상품 유형 열거형
enum ProductType {
  vip('VIP'),
  points('포인트'),
  superchat('슈퍼챗'),
  boost('프로필 부스트'),
  subscription('구독');

  const ProductType(this.displayName);
  final String displayName;
}

/// 결제 모델
class PaymentModel {
  final String id;
  final String userId;
  final String userName;
  final String productName;
  final ProductType productType;
  final int amount; // 원화 기준 금액 (원)
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId; // 외부 결제 게이트웨이 트랜잭션 ID
  final String? gatewayResponse; // 게이트웨이 응답 정보
  final int? refundAmount; // 환불 금액
  final String? refundReason; // 환불 사유
  final DateTime? refundedAt; // 환불 처리 일시
  final String? failureReason; // 실패 사유
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productName,
    required this.productType,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.gatewayResponse,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// copyWith 메서드
  PaymentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? productName,
    ProductType? productType,
    int? amount,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? transactionId,
    String? gatewayResponse,
    int? refundAmount,
    String? refundReason,
    DateTime? refundedAt,
    String? failureReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 환불 가능 여부
  bool get canRefund => status == PaymentStatus.completed;

  /// 환불 처리 여부
  bool get isRefunded => status == PaymentStatus.refunded || status == PaymentStatus.partialRefund;

  /// 결제 성공 여부
  bool get isSuccessful => status == PaymentStatus.completed;

  /// 환불 가능 금액
  int get refundableAmount {
    if (!canRefund) return 0;
    return amount - (refundAmount ?? 0);
  }

  /// 포맷된 금액
  String get formattedAmount => '${_formatNumber(amount)}원';

  /// 포맷된 환불 금액
  String get formattedRefundAmount => 
      refundAmount != null ? '${_formatNumber(refundAmount!)}원' : '';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'productName': productName,
      'productType': productType.name,
      'amount': amount,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'refundAmount': refundAmount,
      'refundReason': refundReason,
      'refundedAt': refundedAt?.toIso8601String(),
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      productName: json['productName'] ?? '',
      productType: ProductType.values.firstWhere(
        (type) => type.name == json['productType'],
        orElse: () => ProductType.points,
      ),
      amount: json['amount'] ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      gatewayResponse: json['gatewayResponse'],
      refundAmount: json['refundAmount'],
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null 
          ? DateTime.tryParse(json['refundedAt'])
          : null,
      failureReason: json['failureReason'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// 환불 처리를 위한 DTO
class RefundProcessDto {
  final int refundAmount;
  final String refundReason;
  final String processedBy;

  RefundProcessDto({
    required this.refundAmount,
    required this.refundReason,
    required this.processedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'refundAmount': refundAmount,
      'refundReason': refundReason,
      'processedBy': processedBy,
    };
  }
}