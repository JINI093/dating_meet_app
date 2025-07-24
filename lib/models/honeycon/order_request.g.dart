// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderRequest _$OrderRequestFromJson(Map<String, dynamic> json) => OrderRequest(
      trId: json['trId'] as String,
      memberId: json['memberId'] as String,
      eventId: json['eventId'] as String,
      goodsId: json['goodsId'] as String,
      orderCnt: (json['orderCnt'] as num).toInt(),
      orderMobile: json['orderMobile'] as String,
      receiverMobile: json['receiverMobile'] as String,
      smsType: json['smsType'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$OrderRequestToJson(OrderRequest instance) =>
    <String, dynamic>{
      'trId': instance.trId,
      'memberId': instance.memberId,
      'eventId': instance.eventId,
      'goodsId': instance.goodsId,
      'orderCnt': instance.orderCnt,
      'orderMobile': instance.orderMobile,
      'receiverMobile': instance.receiverMobile,
      'smsType': instance.smsType,
      'title': instance.title,
      'content': instance.content,
    };
