import 'package:flutter/material.dart';
import '../services/honeycon_api_service.dart';
import '../models/honeycon/order_response.dart';
import '../models/honeycon/order_detail_response.dart';
import '../models/honeycon/goods_list_response.dart';

class HoneyconProvider extends ChangeNotifier {
  final HoneyconApiService _apiService = HoneyconApiService();

  // 상태 관리
  bool _isLoading = false;
  String? _error;
  List<OrderDetailResponse> _orderHistory = [];
  List<GoodsInfo> _goodsList = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderDetailResponse> get orderHistory => _orderHistory;
  List<GoodsInfo> get goodsList => _goodsList;

  // 상품권 주문
  Future<OrderResponse?> orderGiftCard({
    required String receiverMobile,
    required String title,
    required String content,
    String smsType = 'M',
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _apiService.orderSend(
        receiverMobile: receiverMobile,
        title: title,
        content: content,
        smsType: smsType,
      );
      if (response.resultCode == 'LINK_SUCCESS_S0000') {
        await _refreshOrderHistory();
        return response;
      } else {
        _setError(response.resultMsg);
        return null;
      }
    } catch (e) {
      _setError('주문 처리 중 오류가 발생했습니다: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 주문 취소
  Future<bool> cancelOrder(String trId) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _apiService.orderCancel(trId);
      if (response.resultCode == 'LINK_SUCCESS_S0000') {
        await _refreshOrderHistory();
        return true;
      } else {
        _setError(response.resultMsg);
        return false;
      }
    } catch (e) {
      _setError('주문 취소 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 주문 내역 새로고침 (실제 구현시 서버/DB 연동 필요)
  Future<void> _refreshOrderHistory() async {
    // TODO: 서버 또는 로컬 DB에서 주문 내역 조회 구현
    _orderHistory = [];
    notifyListeners();
  }

  // 상품 리스트 조회
  Future<void> loadGoodsList() async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _apiService.getEventGoodsList();
      if (response.resultCode == 'LINK_SUCCESS_S0000') {
        _goodsList = [];
        if (response.eventList != null && response.eventList!.isNotEmpty) {
          for (final event in response.eventList!) {
            if (event.goodsList != null) {
              _goodsList.addAll(event.goodsList!);
            }
          }
        }
      } else {
        _setError(response.resultMsg);
      }
    } catch (e) {
      _setError('상품 목록 조회 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 쿠폰 번호 복호화
  String? decryptCoupon(String encryptedCoupon) {
    try {
      return _apiService.decryptCouponNumber(encryptedCoupon);
    } catch (e) {
      _setError('쿠폰 번호 복호화 실패: $e');
      return null;
    }
  }

  // 상태 초기화
  void reset() {
    _isLoading = false;
    _error = null;
    _orderHistory = [];
    _goodsList = [];
    notifyListeners();
  }

  // 캐싱 예시 (메모리 캐시)
  void cacheOrderHistory(List<OrderDetailResponse> orders) {
    _orderHistory = orders;
    notifyListeners();
  }
  void cacheGoodsList(List<GoodsInfo> goods) {
    _goodsList = goods;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 