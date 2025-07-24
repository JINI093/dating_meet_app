import 'package:json_annotation/json_annotation.dart';

part 'order_request.g.dart';

@JsonSerializable()
class OrderRequest {
  final String trId;
  final String memberId;
  final String eventId;
  final String goodsId;
  final int orderCnt;
  final String orderMobile;
  final String receiverMobile;
  final String smsType;
  final String title;
  final String content;

  OrderRequest({
    required this.trId,
    required this.memberId,
    required this.eventId,
    required this.goodsId,
    required this.orderCnt,
    required this.orderMobile,
    required this.receiverMobile,
    required this.smsType,
    required this.title,
    required this.content,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) => _$OrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OrderRequestToJson(this);

  OrderRequest copyWith({
    String? trId,
    String? memberId,
    String? eventId,
    String? goodsId,
    int? orderCnt,
    String? orderMobile,
    String? receiverMobile,
    String? smsType,
    String? title,
    String? content,
  }) => OrderRequest(
    trId: trId ?? this.trId,
    memberId: memberId ?? this.memberId,
    eventId: eventId ?? this.eventId,
    goodsId: goodsId ?? this.goodsId,
    orderCnt: orderCnt ?? this.orderCnt,
    orderMobile: orderMobile ?? this.orderMobile,
    receiverMobile: receiverMobile ?? this.receiverMobile,
    smsType: smsType ?? this.smsType,
    title: title ?? this.title,
    content: content ?? this.content,
  );
} 