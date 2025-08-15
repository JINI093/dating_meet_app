import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/in_app_purchase_service.dart';
import '../models/purchase_models.dart';
import '../utils/logger.dart';
import 'points_provider.dart';
import 'heart_provider.dart';

/// 인앱결제 상태
class PurchaseState {
  final bool isLoading;
  final List<PurchaseProduct> products;
  final List<VipProduct> vipProducts;
  final List<PointsProduct> pointsProducts;
  final List<HeartsProduct> heartsProducts;
  final List<PurchaseHistory> purchaseHistory;
  final String? error;
  final bool isInitialized;

  const PurchaseState({
    this.isLoading = false,
    this.products = const [],
    this.vipProducts = const [],
    this.pointsProducts = const [],
    this.heartsProducts = const [],
    this.purchaseHistory = const [],
    this.error,
    this.isInitialized = false,
  });

  PurchaseState copyWith({
    bool? isLoading,
    List<PurchaseProduct>? products,
    List<VipProduct>? vipProducts,
    List<PointsProduct>? pointsProducts,
    List<HeartsProduct>? heartsProducts,
    List<PurchaseHistory>? purchaseHistory,
    String? error,
    bool? isInitialized,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      vipProducts: vipProducts ?? this.vipProducts,
      pointsProducts: pointsProducts ?? this.pointsProducts,
      heartsProducts: heartsProducts ?? this.heartsProducts,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// 인앱결제 Provider
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier(this._ref) : super(const PurchaseState()) {
    _initializeService();
  }

  final Ref _ref;
  final InAppPurchaseService _purchaseService = InAppPurchaseService();

  /// 서비스 초기화
  Future<void> _initializeService() async {
    try {
      Logger.log('인앱결제 Provider 초기화 시작', name: 'PurchaseProvider');
      
      state = state.copyWith(isLoading: true, error: null);

      // 인앱결제 서비스 초기화
      final bool isInitialized = await _purchaseService.initialize();
      if (!isInitialized) {
        throw Exception('인앱결제를 사용할 수 없습니다');
      }

      // 콜백 설정
      _purchaseService.onPurchaseUpdated = _onPurchaseUpdated;
      _purchaseService.onPurchaseError = _onPurchaseError;
      _purchaseService.onProductsLoaded = _onProductsLoaded;

      // 제품 정보 로드
      await loadProducts();

      // 구매 히스토리 로드
      await _loadPurchaseHistory();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );

      Logger.log('인앱결제 Provider 초기화 완료', name: 'PurchaseProvider');
    } catch (e) {
      Logger.error('인앱결제 Provider 초기화 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(
        isLoading: false,
        error: '인앱결제를 초기화할 수 없습니다: $e',
      );
    }
  }

  /// 제품 정보 로드
  Future<void> loadProducts() async {
    try {
      Logger.log('제품 정보 로드 시작', name: 'PurchaseProvider');
      
      state = state.copyWith(isLoading: true, error: null);

      final List<ProductDetails> productDetails = await _purchaseService.getProducts();
      
      // 제품 타입별로 분류
      final List<VipProduct> vipProducts = [];
      final List<PointsProduct> pointsProducts = [];
      final List<HeartsProduct> heartsProducts = [];
      final List<PurchaseProduct> allProducts = [];

      for (final ProductDetails details in productDetails) {
        if (details.id.contains('vip')) {
          final vipProduct = VipProduct.fromProductDetails(details);
          vipProducts.add(vipProduct);
          allProducts.add(vipProduct);
        } else if (details.id.contains('points')) {
          final pointsProduct = PointsProduct.fromProductDetails(details);
          pointsProducts.add(pointsProduct);
          allProducts.add(pointsProduct);
        } else if (details.id.contains('hearts')) {
          final heartsProduct = HeartsProduct.fromProductDetails(details);
          heartsProducts.add(heartsProduct);
          allProducts.add(heartsProduct);
        }
      }

      state = state.copyWith(
        isLoading: false,
        products: allProducts,
        vipProducts: vipProducts,
        pointsProducts: pointsProducts,
        heartsProducts: heartsProducts,
      );

      Logger.log('제품 정보 로드 완료: ${allProducts.length}개', name: 'PurchaseProvider');
    } catch (e) {
      Logger.error('제품 정보 로드 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(
        isLoading: false,
        error: '제품 정보를 불러올 수 없습니다',
      );
    }
  }

  /// 제품 구매
  Future<bool> purchaseProduct(String productId) async {
    try {
      Logger.log('제품 구매 시작: $productId', name: 'PurchaseProvider');
      
      // 실제 ProductDetails 찾기
      final productDetails = await _purchaseService.getProducts(productIds: [productId]);
      if (productDetails.isEmpty) {
        throw Exception('제품 정보를 찾을 수 없습니다');
      }

      state = state.copyWith(isLoading: true, error: null);

      // 구매 시작
      final bool success = await _purchaseService.purchaseProduct(productDetails.first);
      
      if (!success) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      // 구매 성공 시 loading 상태는 onPurchaseUpdated에서 처리
      return true;
    } catch (e) {
      Logger.error('제품 구매 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(
        isLoading: false,
        error: '구매에 실패했습니다: $e',
      );
      return false;
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    try {
      Logger.log('구매 복원 시작', name: 'PurchaseProvider');
      state = state.copyWith(isLoading: true, error: null);

      await _purchaseService.restorePurchases();
      
      // 복원 결과는 onPurchaseUpdated에서 처리
    } catch (e) {
      Logger.error('구매 복원 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(
        isLoading: false,
        error: '구매 복원에 실패했습니다',
      );
    }
  }

  /// 구매 상태 업데이트 콜백
  void _onPurchaseUpdated(PurchaseResult result) async {
    Logger.log('구매 상태 업데이트: ${result.status}', name: 'PurchaseProvider');
    
    state = state.copyWith(isLoading: false);

    if (result.isSuccess || result.isRestored) {
      await _handleSuccessfulPurchase(result);
    } else if (result.isError) {
      state = state.copyWith(error: result.error);
    }
    // canceled나 pending은 별도 처리 없음
  }

  /// 성공한 구매 처리
  Future<void> _handleSuccessfulPurchase(PurchaseResult result) async {
    try {
      Logger.log('성공한 구매 처리: ${result.productId}', name: 'PurchaseProvider');

      // 제품 찾기
      final product = state.products.firstWhere(
        (p) => p.id == result.productId,
        orElse: () => throw Exception('제품을 찾을 수 없습니다'),
      );

      // 영수증 검증
      if (result.purchaseDetails != null) {
        final bool isValid = await _purchaseService.verifyPurchase(result.purchaseDetails!);
        if (!isValid) {
          Logger.error('구매 영수증 검증 실패', name: 'PurchaseProvider');
          state = state.copyWith(error: '구매 검증에 실패했습니다');
          return;
        }
      }

      // 제품 타입별 처리
      switch (product.type) {
        case ProductType.vip:
          await _handleVipPurchase(product as VipProduct);
          break;
        case ProductType.points:
          await _handlePointsPurchase(product as PointsProduct);
          break;
        case ProductType.hearts:
          await _handleHeartsPurchase(product as HeartsProduct);
          break;
      }

      // 구매 히스토리 저장
      await _savePurchaseHistory(result, product);

      Logger.log('구매 처리 완료: ${result.productId}', name: 'PurchaseProvider');
    } catch (e) {
      Logger.error('구매 처리 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(error: '구매 처리 중 오류가 발생했습니다');
    }
  }

  /// VIP 구매 처리
  Future<void> _handleVipPurchase(VipProduct product) async {
    Logger.log('VIP 구매 처리: ${product.vipTier}', name: 'PurchaseProvider');
    
    // VIP Provider를 통해 VIP 상태 활성화
    // TODO: 실제 구매 정보로 VIP 활성화
    // await _ref.read(vipProvider.notifier).activateVipFromPurchase(product);
  }

  /// 포인트 구매 처리
  Future<void> _handlePointsPurchase(PointsProduct product) async {
    Logger.log('포인트 구매 처리: ${product.totalPoints}P', name: 'PurchaseProvider');
    
    // 포인트 Provider를 통해 포인트 추가
    await _ref.read(pointsProvider.notifier).addPoints(
      amount: product.totalPoints,
      description: '${product.name} 구매',
    );
  }

  /// 하트 구매 처리
  Future<void> _handleHeartsPurchase(HeartsProduct product) async {
    Logger.log('하트 구매 처리: ${product.totalHearts}개', name: 'PurchaseProvider');
    
    // 하트 Provider를 통해 하트 추가
    await _ref.read(heartProvider.notifier).addHearts(
      product.totalHearts,
      description: '${product.name} 구매',
    );
  }

  /// 구매 오류 콜백
  void _onPurchaseError(String error) {
    Logger.error('구매 오류: $error', name: 'PurchaseProvider');
    state = state.copyWith(
      isLoading: false,
      error: error,
    );
  }

  /// 제품 로드 완료 콜백
  void _onProductsLoaded(List<ProductDetails> products) {
    Logger.log('제품 로드 완료: ${products.length}개', name: 'PurchaseProvider');
  }

  /// 구매 히스토리 저장
  Future<void> _savePurchaseHistory(PurchaseResult result, PurchaseProduct product) async {
    try {
      final history = PurchaseHistory.fromPurchaseResult(result, product);
      final updatedHistory = [...state.purchaseHistory, history];
      
      state = state.copyWith(purchaseHistory: updatedHistory);

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      final historyJson = updatedHistory.map((h) => h.toJson()).toList();
      await prefs.setString('purchase_history', jsonEncode(historyJson));
      
      Logger.log('구매 히스토리 저장 완료', name: 'PurchaseProvider');
    } catch (e) {
      Logger.error('구매 히스토리 저장 실패: $e', name: 'PurchaseProvider');
    }
  }

  /// 구매 히스토리 로드
  Future<void> _loadPurchaseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('purchase_history');
      
      if (historyString != null) {
        final List<dynamic> historyJson = jsonDecode(historyString);
        final List<PurchaseHistory> history = historyJson
            .map((json) => PurchaseHistory.fromJson(json))
            .toList();
        
        state = state.copyWith(purchaseHistory: history);
        Logger.log('구매 히스토리 로드 완료: ${history.length}개', name: 'PurchaseProvider');
      }
    } catch (e) {
      Logger.error('구매 히스토리 로드 실패: $e', name: 'PurchaseProvider');
    }
  }

  /// 오류 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}

/// 인앱결제 Provider
final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);

/// VIP 제품만 가져오는 Provider
final vipProductsProvider = Provider<List<VipProduct>>((ref) {
  return ref.watch(purchaseProvider).vipProducts;
});

/// 포인트 제품만 가져오는 Provider
final pointsProductsProvider = Provider<List<PointsProduct>>((ref) {
  return ref.watch(purchaseProvider).pointsProducts;
});

/// 하트 제품만 가져오는 Provider
final heartsProductsProvider = Provider<List<HeartsProduct>>((ref) {
  return ref.watch(purchaseProvider).heartsProducts;
});

/// 구매 히스토리 Provider
final purchaseHistoryProvider = Provider<List<PurchaseHistory>>((ref) {
  return ref.watch(purchaseProvider).purchaseHistory;
});