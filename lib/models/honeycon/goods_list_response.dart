import 'package:json_annotation/json_annotation.dart';

part 'goods_list_response.g.dart';

@JsonSerializable()
class GoodsListResponse {
  final String resultCode;
  final String resultMsg;
  final List<EventInfo>? eventList;

  GoodsListResponse({
    required this.resultCode,
    required this.resultMsg,
    this.eventList,
  });

  factory GoodsListResponse.fromJson(Map<String, dynamic> json) =>
      _$GoodsListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GoodsListResponseToJson(this);

  GoodsListResponse copyWith({
    String? resultCode,
    String? resultMsg,
    List<EventInfo>? eventList,
  }) =>
      GoodsListResponse(
        resultCode: resultCode ?? this.resultCode,
        resultMsg: resultMsg ?? this.resultMsg,
        eventList: eventList ?? this.eventList,
      );
}

@JsonSerializable()
class EventInfo {
  final String eventId;
  final String eventName;
  final List<GoodsInfo>? goodsList;
  final List<CategoryInfo>? categoryList;

  EventInfo({
    required this.eventId,
    required this.eventName,
    this.goodsList,
    this.categoryList,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) =>
      _$EventInfoFromJson(json);
  Map<String, dynamic> toJson() => _$EventInfoToJson(this);

  EventInfo copyWith({
    String? eventId,
    String? eventName,
    List<GoodsInfo>? goodsList,
    List<CategoryInfo>? categoryList,
  }) =>
      EventInfo(
        eventId: eventId ?? this.eventId,
        eventName: eventName ?? this.eventName,
        goodsList: goodsList ?? this.goodsList,
        categoryList: categoryList ?? this.categoryList,
      );
}

@JsonSerializable()
class GoodsInfo {
  final String goodsId;
  final String goodsName;
  final int price;
  final String? imageUrl;

  GoodsInfo({
    required this.goodsId,
    required this.goodsName,
    required this.price,
    this.imageUrl,
  });

  factory GoodsInfo.fromJson(Map<String, dynamic> json) =>
      _$GoodsInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GoodsInfoToJson(this);

  GoodsInfo copyWith({
    String? goodsId,
    String? goodsName,
    int? price,
    String? imageUrl,
  }) =>
      GoodsInfo(
        goodsId: goodsId ?? this.goodsId,
        goodsName: goodsName ?? this.goodsName,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

@JsonSerializable()
class CategoryInfo {
  final String categoryId;
  final String categoryName;

  CategoryInfo({
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) =>
      _$CategoryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryInfoToJson(this);

  CategoryInfo copyWith({
    String? categoryId,
    String? categoryName,
  }) =>
      CategoryInfo(
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
      );
}
