import 'package:json_annotation/json_annotation.dart';

part 'order_detail_response.g.dart';

enum OrderStatus {
  @JsonValue('01') requested,
  @JsonValue('02') completed,
  @JsonValue('03') canceled,
  @JsonValue('04') expired,
  @JsonValue('05') failed,
  @JsonValue('99') unknown,
}

@JsonSerializable()
class OrderDetailResponse {
  final String resultCode;
  final String resultMsg;
  final String? orderId;
  final String? trId;
  final OrderStatus? status;
  final String? receiverMobile;
  final String? couponNum;
  final String? externalPnm;
  final String? exchangeEnddate;
  final String? msgAdditionalInfo;
  // 기타 상세 필드 필요시 추가

  OrderDetailResponse({
    required this.resultCode,
    required this.resultMsg,
    this.orderId,
    this.trId,
    this.status,
    this.receiverMobile,
    this.couponNum,
    this.externalPnm,
    this.exchangeEnddate,
    this.msgAdditionalInfo,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) => _$OrderDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailResponseToJson(this);

  OrderDetailResponse copyWith({
    String? resultCode,
    String? resultMsg,
    String? orderId,
    String? trId,
    OrderStatus? status,
    String? receiverMobile,
    String? couponNum,
    String? externalPnm,
    String? exchangeEnddate,
    String? msgAdditionalInfo,
  }) => OrderDetailResponse(
    resultCode: resultCode ?? this.resultCode,
    resultMsg: resultMsg ?? this.resultMsg,
    orderId: orderId ?? this.orderId,
    trId: trId ?? this.trId,
    status: status ?? this.status,
    receiverMobile: receiverMobile ?? this.receiverMobile,
    couponNum: couponNum ?? this.couponNum,
    externalPnm: externalPnm ?? this.externalPnm,
    exchangeEnddate: exchangeEnddate ?? this.exchangeEnddate,
    msgAdditionalInfo: msgAdditionalInfo ?? this.msgAdditionalInfo,
  );
} 