// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      resultCode: json['resultCode'] as String,
      resultMsg: json['resultMsg'] as String,
      trId: json['trId'] as String?,
      orderId: json['orderId'] as String?,
      receiverMobile: json['receiverMobile'] as String?,
      couponNum: json['couponNum'] as String?,
      externalPnm: json['externalPnm'] as String?,
      exchangeEnddate: json['exchangeEnddate'] as String?,
      msgAdditionalInfo: json['msgAdditionalInfo'] as String?,
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'resultCode': instance.resultCode,
      'resultMsg': instance.resultMsg,
      'trId': instance.trId,
      'orderId': instance.orderId,
      'receiverMobile': instance.receiverMobile,
      'couponNum': instance.couponNum,
      'externalPnm': instance.externalPnm,
      'exchangeEnddate': instance.exchangeEnddate,
      'msgAdditionalInfo': instance.msgAdditionalInfo,
    };
