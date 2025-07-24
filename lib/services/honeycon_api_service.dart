import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/honeycon_config.dart';
import '../models/honeycon/order_request.dart';
import '../models/honeycon/order_response.dart';
import '../models/honeycon/order_detail_response.dart';
import '../models/honeycon/goods_list_response.dart';
import '../utils/honeycon_crypto.dart';
import '../utils/logger.dart';

class HoneyconApiService {
  late final Dio _dio;

  HoneyconApiService() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // 재시도 로직 (최대 2회)
  Future<T> _retry<T>(Future<T> Function() fn) async {
    int retryCount = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        if (retryCount++ < 2) {
          Logger.w('[HoneyconApiService] 재시도: $retryCount, 에러: $e');
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        Logger.e('[HoneyconApiService] 요청 실패: $e');
        rethrow;
      }
    }
  }

  // 1. 주문 처리
  Future<OrderResponse> orderSend({
    required String receiverMobile,
    required String title,
    required String content,
    String smsType = 'M',
    int orderCnt = 1,
  }) async {
    return await _retry(() async {
      try {
        final request = OrderRequest(
          trId: HoneyconCrypto.generateTransactionId(),
          memberId: HoneyconConfig.memberId,
          eventId: HoneyconConfig.eventId,
          goodsId: HoneyconConfig.goodsId,
          orderCnt: orderCnt,
          orderMobile: HoneyconConfig.orderMobile,
          receiverMobile: receiverMobile,
          smsType: smsType,
          title: title,
          content: content,
        );
        final response = await _dio.post(
          HoneyconConfig.orderSendUrl,
          data: request.toJson(),
        );
        return OrderResponse.fromJson(response.data);
      } catch (e) {
        Logger.e('[orderSend] 에러: $e');
        rethrow;
      }
    });
  }

  // 2. 주문 취소
  Future<OrderResponse> orderCancel(String trId) async {
    return await _retry(() async {
      try {
        final data = {
          'tr_id': trId,
          'member_id': HoneyconConfig.memberId,
          'event_id': HoneyconConfig.eventId,
        };
        final response = await _dio.post(
          HoneyconConfig.orderCancelUrl,
          data: data,
        );
        return OrderResponse.fromJson(response.data);
      } catch (e) {
        Logger.e('[orderCancel] 에러: $e');
        rethrow;
      }
    });
  }

  // 3. 문자 재전송
  Future<OrderResponse> orderResend(String trId) async {
    return await _retry(() async {
      try {
        final data = {
          'tr_id': trId,
          'member_id': HoneyconConfig.memberId,
          'event_id': HoneyconConfig.eventId,
        };
        final response = await _dio.post(
          HoneyconConfig.orderResendUrl,
          data: data,
        );
        return OrderResponse.fromJson(response.data);
      } catch (e) {
        Logger.e('[orderResend] 에러: $e');
        rethrow;
      }
    });
  }

  // 4. 주문 상세 조회
  Future<OrderDetailResponse> orderDetail(String trId) async {
    return await _retry(() async {
      try {
        final data = {
          'tr_id': trId,
          'member_id': HoneyconConfig.memberId,
          'event_id': HoneyconConfig.eventId,
        };
        final response = await _dio.post(
          HoneyconConfig.orderDetailUrl,
          data: data,
        );
        return OrderDetailResponse.fromJson(response.data);
      } catch (e) {
        Logger.e('[orderDetail] 에러: $e');
        rethrow;
      }
    });
  }

  // 5. 이벤트 상품 리스트 조회
  Future<GoodsListResponse> getEventGoodsList({
    String? goodsId,
    String? rcompanyId,
    String? catId,
  }) async {
    return await _retry(() async {
      try {
        final data = {
          'event_id': HoneyconConfig.eventId,
          if (goodsId != null) 'goods_id': goodsId,
          if (rcompanyId != null) 'rcompany_id': rcompanyId,
          if (catId != null) 'cat_id': catId,
        };
        final response = await _dio.post(
          HoneyconConfig.eventGoodsListUrl,
          data: data,
        );
        return GoodsListResponse.fromJson(response.data);
      } catch (e) {
        Logger.e('[getEventGoodsList] 에러: $e');
        rethrow;
      }
    });
  }

  // 쿠폰 번호 복호화
  String decryptCouponNumber(String encryptedCoupon) {
    try {
      return HoneyconCrypto.decrypt(encryptedCoupon, HoneyconConfig.securityKey);
    } catch (e) {
      Logger.e('[decryptCouponNumber] 복호화 실패: $e');
      rethrow;
    }
  }
} 