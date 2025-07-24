import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

@JsonSerializable()
class OrderResponse {
  final String resultCode;
  final String resultMsg;
  final String? trId;
  final String? orderId;
  final String? receiverMobile;
  final String? couponNum;
  final String? externalPnm;
  final String? exchangeEnddate;
  final String? msgAdditionalInfo;

  OrderResponse({
    required this.resultCode,
    required this.resultMsg,
    this.trId,
    this.orderId,
    this.receiverMobile,
    this.couponNum,
    this.externalPnm,
    this.exchangeEnddate,
    this.msgAdditionalInfo,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);

  OrderResponse copyWith({
    String? resultCode,
    String? resultMsg,
    String? trId,
    String? orderId,
    String? receiverMobile,
    String? couponNum,
    String? externalPnm,
    String? exchangeEnddate,
    String? msgAdditionalInfo,
  }) => OrderResponse(
    resultCode: resultCode ?? this.resultCode,
    resultMsg: resultMsg ?? this.resultMsg,
    trId: trId ?? this.trId,
    orderId: orderId ?? this.orderId,
    receiverMobile: receiverMobile ?? this.receiverMobile,
    couponNum: couponNum ?? this.couponNum,
    externalPnm: externalPnm ?? this.externalPnm,
    exchangeEnddate: exchangeEnddate ?? this.exchangeEnddate,
    msgAdditionalInfo: msgAdditionalInfo ?? this.msgAdditionalInfo,
  );
} 