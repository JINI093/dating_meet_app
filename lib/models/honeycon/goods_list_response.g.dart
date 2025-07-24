// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoodsListResponse _$GoodsListResponseFromJson(Map<String, dynamic> json) =>
    GoodsListResponse(
      resultCode: json['resultCode'] as String,
      resultMsg: json['resultMsg'] as String,
      eventList: (json['eventList'] as List<dynamic>?)
          ?.map((e) => EventInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GoodsListResponseToJson(GoodsListResponse instance) =>
    <String, dynamic>{
      'resultCode': instance.resultCode,
      'resultMsg': instance.resultMsg,
      'eventList': instance.eventList,
    };

EventInfo _$EventInfoFromJson(Map<String, dynamic> json) => EventInfo(
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      goodsList: (json['goodsList'] as List<dynamic>?)
          ?.map((e) => GoodsInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryList: (json['categoryList'] as List<dynamic>?)
          ?.map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventInfoToJson(EventInfo instance) => <String, dynamic>{
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'goodsList': instance.goodsList,
      'categoryList': instance.categoryList,
    };

GoodsInfo _$GoodsInfoFromJson(Map<String, dynamic> json) => GoodsInfo(
      goodsId: json['goodsId'] as String,
      goodsName: json['goodsName'] as String,
      price: (json['price'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$GoodsInfoToJson(GoodsInfo instance) => <String, dynamic>{
      'goodsId': instance.goodsId,
      'goodsName': instance.goodsName,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
    };

CategoryInfo _$CategoryInfoFromJson(Map<String, dynamic> json) => CategoryInfo(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
    );

Map<String, dynamic> _$CategoryInfoToJson(CategoryInfo instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
    };
