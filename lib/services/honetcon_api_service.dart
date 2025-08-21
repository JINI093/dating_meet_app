import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

/// HonetCon API service for point to gift card conversion
class HonetConApiService {
  static const String _baseUrl = 'https://api.honetcon.com/v1';
  static const String _apiKey = 'YOUR_HONETCON_API_KEY'; // Replace with actual API key
  
  static final HonetConApiService _instance = HonetConApiService._internal();
  factory HonetConApiService() => _instance;
  HonetConApiService._internal();

  /// Convert points to gift card
  Future<GiftCardExchangeResult> exchangePointsToGiftCard({
    required String userId,
    required int points,
    required String giftCardType,
    required int giftCardValue,
    required String recipientEmail,
    String? recipientPhone,
    String? message,
  }) async {
    try {
      Logger.log('HonetCon API 호출 시작: ${points}P -> $giftCardValue원 상품권', name: 'HonetConAPI');

      final request = GiftCardExchangeRequest(
        userId: userId,
        points: points,
        giftCardType: giftCardType,
        giftCardValue: giftCardValue,
        recipientEmail: recipientEmail,
        recipientPhone: recipientPhone,
        message: message,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/giftcard/exchange'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      Logger.log('HonetCon API 응답: ${response.statusCode}', name: 'HonetConAPI');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final result = GiftCardExchangeResult.fromJson(responseData);
        
        Logger.log('상품권 전환 성공: ${result.giftCardId}', name: 'HonetConAPI');
        return result;
      } else {
        final errorData = jsonDecode(response.body);
        throw HonetConApiException(
          message: errorData['message'] ?? '상품권 전환에 실패했습니다',
          errorCode: errorData['error_code'] ?? 'EXCHANGE_FAILED',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('HonetCon API 오류: $e', name: 'HonetConAPI');
      if (e is HonetConApiException) {
        rethrow;
      }
      throw HonetConApiException(
        message: '네트워크 오류가 발생했습니다',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  /// Get available gift card types
  Future<List<GiftCardType>> getAvailableGiftCardTypes() async {
    try {
      Logger.log('사용 가능한 상품권 종류 조회', name: 'HonetConAPI');

      final response = await http.get(
        Uri.parse('$_baseUrl/giftcard/types'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> typesData = responseData['gift_card_types'];
        
        final giftCardTypes = typesData
            .map((data) => GiftCardType.fromJson(data))
            .toList();

        Logger.log('상품권 종류 ${giftCardTypes.length}개 조회됨', name: 'HonetConAPI');
        return giftCardTypes;
      } else {
        throw HonetConApiException(
          message: '상품권 정보를 가져올 수 없습니다',
          errorCode: 'FETCH_TYPES_FAILED',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('상품권 종류 조회 오류: $e', name: 'HonetConAPI');
      if (e is HonetConApiException) {
        rethrow;
      }
      throw HonetConApiException(
        message: '네트워크 오류가 발생했습니다',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  /// Check exchange status
  Future<ExchangeStatus> checkExchangeStatus(String exchangeId) async {
    try {
      Logger.log('전환 상태 확인: $exchangeId', name: 'HonetConAPI');

      final response = await http.get(
        Uri.parse('$_baseUrl/giftcard/exchange/$exchangeId/status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ExchangeStatus.fromJson(responseData);
      } else {
        throw HonetConApiException(
          message: '전환 상태를 확인할 수 없습니다',
          errorCode: 'STATUS_CHECK_FAILED',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('전환 상태 확인 오류: $e', name: 'HonetConAPI');
      if (e is HonetConApiException) {
        rethrow;
      }
      throw HonetConApiException(
        message: '네트워크 오류가 발생했습니다',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }
}

/// Gift card exchange request model
class GiftCardExchangeRequest {
  final String userId;
  final int points;
  final String giftCardType;
  final int giftCardValue;
  final String recipientEmail;
  final String? recipientPhone;
  final String? message;

  GiftCardExchangeRequest({
    required this.userId,
    required this.points,
    required this.giftCardType,
    required this.giftCardValue,
    required this.recipientEmail,
    this.recipientPhone,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'points': points,
        'gift_card_type': giftCardType,
        'gift_card_value': giftCardValue,
        'recipient_email': recipientEmail,
        if (recipientPhone != null) 'recipient_phone': recipientPhone,
        if (message != null) 'message': message,
        'exchange_timestamp': DateTime.now().toIso8601String(),
      };
}

/// Gift card exchange result model
class GiftCardExchangeResult {
  final bool success;
  final String exchangeId;
  final String giftCardId;
  final String giftCardCode;
  final String giftCardType;
  final int giftCardValue;
  final int pointsDeducted;
  final String status;
  final DateTime exchangeDate;
  final DateTime? estimatedDeliveryDate;
  final String? message;

  GiftCardExchangeResult({
    required this.success,
    required this.exchangeId,
    required this.giftCardId,
    required this.giftCardCode,
    required this.giftCardType,
    required this.giftCardValue,
    required this.pointsDeducted,
    required this.status,
    required this.exchangeDate,
    this.estimatedDeliveryDate,
    this.message,
  });

  factory GiftCardExchangeResult.fromJson(Map<String, dynamic> json) {
    return GiftCardExchangeResult(
      success: json['success'] ?? false,
      exchangeId: json['exchange_id'] ?? '',
      giftCardId: json['gift_card_id'] ?? '',
      giftCardCode: json['gift_card_code'] ?? '',
      giftCardType: json['gift_card_type'] ?? '',
      giftCardValue: json['gift_card_value'] ?? 0,
      pointsDeducted: json['points_deducted'] ?? 0,
      status: json['status'] ?? 'pending',
      exchangeDate: DateTime.parse(json['exchange_date']),
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      message: json['message'],
    );
  }
}

/// Available gift card type model
class GiftCardType {
  final String id;
  final String name;
  final String brand;
  final List<int> availableValues;
  final int minPoints;
  final int maxPoints;
  final double conversionRate;
  final bool isAvailable;

  GiftCardType({
    required this.id,
    required this.name,
    required this.brand,
    required this.availableValues,
    required this.minPoints,
    required this.maxPoints,
    required this.conversionRate,
    required this.isAvailable,
  });

  factory GiftCardType.fromJson(Map<String, dynamic> json) {
    return GiftCardType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      availableValues: List<int>.from(json['available_values'] ?? []),
      minPoints: json['min_points'] ?? 0,
      maxPoints: json['max_points'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? false,
    );
  }
}

/// Exchange status model
class ExchangeStatus {
  final String exchangeId;
  final String status;
  final String statusMessage;
  final DateTime lastUpdated;
  final String? trackingNumber;
  final DateTime? deliveredAt;

  ExchangeStatus({
    required this.exchangeId,
    required this.status,
    required this.statusMessage,
    required this.lastUpdated,
    this.trackingNumber,
    this.deliveredAt,
  });

  factory ExchangeStatus.fromJson(Map<String, dynamic> json) {
    return ExchangeStatus(
      exchangeId: json['exchange_id'] ?? '',
      status: json['status'] ?? '',
      statusMessage: json['status_message'] ?? '',
      lastUpdated: DateTime.parse(json['last_updated']),
      trackingNumber: json['tracking_number'],
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }
}

/// HonetCon API exception
class HonetConApiException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  HonetConApiException({
    required this.message,
    required this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => 'HonetConApiException: $message (Code: $errorCode)';
}