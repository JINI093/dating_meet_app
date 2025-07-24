// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailResponse _$OrderDetailResponseFromJson(Map<String, dynamic> json) =>
    OrderDetailResponse(
      resultCode: json['resultCode'] as String,
      resultMsg: json['resultMsg'] as String,
      orderId: json['orderId'] as String?,
      trId: json['trId'] as String?,
      status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']),
      receiverMobile: json['receiverMobile'] as String?,
      couponNum: json['couponNum'] as String?,
      externalPnm: json['externalPnm'] as String?,
      exchangeEnddate: json['exchangeEnddate'] as String?,
      msgAdditionalInfo: json['msgAdditionalInfo'] as String?,
    );

Map<String, dynamic> _$OrderDetailResponseToJson(
        OrderDetailResponse instance) =>
    <String, dynamic>{
      'resultCode': instance.resultCode,
      'resultMsg': instance.resultMsg,
      'orderId': instance.orderId,
      'trId': instance.trId,
      'status': _$OrderStatusEnumMap[instance.status],
      'receiverMobile': instance.receiverMobile,
      'couponNum': instance.couponNum,
      'externalPnm': instance.externalPnm,
      'exchangeEnddate': instance.exchangeEnddate,
      'msgAdditionalInfo': instance.msgAdditionalInfo,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.requested: '01',
  OrderStatus.completed: '02',
  OrderStatus.canceled: '03',
  OrderStatus.expired: '04',
  OrderStatus.failed: '05',
  OrderStatus.unknown: '99',
};
