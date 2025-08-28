import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/in_app_purchase_service.dart';
import '../models/purchase_models.dart';
import '../utils/logger.dart';
import '../utils/debug_config.dart';
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

      List<ProductDetails> productDetails = [];
      
      // 디버그 모드가 아닌 경우에만 실제 제품 정보 로드
      if (!DebugConfig.enableDebugPayments) {
        productDetails = await _purchaseService.getProducts();
      }

      // 제품 타입별로 분류
      final List<VipProduct> vipProducts = [];
      final List<PointsProduct> pointsProducts = [];
      final List<HeartsProduct> heartsProducts = [];
      final List<PurchaseProduct> allProducts = [];

      // 실제 제품이 있는 경우 처리
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

      // 디버그 모드이거나 제품이 없는 경우 가짜 제품 생성
      if (DebugConfig.enableDebugPayments || productDetails.isEmpty) {
        Logger.log('[DEBUG] 디버그 제품 생성', name: 'PurchaseProvider');
        
        // 디버그 포인트 제품들
        final debugPointsProducts = _createDebugPointsProducts();
        pointsProducts.addAll(debugPointsProducts);
        allProducts.addAll(debugPointsProducts);
        
        // 디버그 하트 제품들
        final debugHeartsProducts = _createDebugHeartsProducts();
        heartsProducts.addAll(debugHeartsProducts);
        allProducts.addAll(debugHeartsProducts);
        
        // 디버그 VIP 제품들
        final debugVipProducts = _createDebugVipProducts();
        vipProducts.addAll(debugVipProducts);
        allProducts.addAll(debugVipProducts);
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
      
      state = state.copyWith(isLoading: true, error: null);

      // 디버그 모드인 경우 시뮬레이션 구매
      if (DebugConfig.enableDebugPayments) {
        return await _handleDebugPurchase(productId);
      }

      // 실제 ProductDetails 찾기
      final productDetails = await _purchaseService.getProducts(productIds: [productId]);
      if (productDetails.isEmpty) {
        throw Exception('제품 정보를 찾을 수 없습니다');
      }

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

      // 영수증 검증 (디버그 모드에서는 스킵)
      if (result.purchaseDetails != null && !DebugConfig.enableDebugPayments) {
        final bool isValid = await _purchaseService.verifyPurchase(result.purchaseDetails!);
        if (!isValid) {
          Logger.error('구매 영수증 검증 실패', name: 'PurchaseProvider');
          state = state.copyWith(isLoading: false, error: '구매 검증에 실패했습니다');
          return;
        }
      } else if (DebugConfig.enableDebugPayments) {
        Logger.log('[DEBUG] 디버그 모드: 영수증 검증 스킵', name: 'PurchaseProvider');
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

      // 구매 완료 - 로딩 상태 해제
      state = state.copyWith(isLoading: false, error: null);

      Logger.log('구매 처리 완료: ${result.productId}', name: 'PurchaseProvider');
    } catch (e) {
      Logger.error('구매 처리 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(isLoading: false, error: '구매 처리 중 오류가 발생했습니다');
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

  /// 디버그 구매 처리
  Future<bool> _handleDebugPurchase(String productId) async {
    try {
      Logger.log('[DEBUG] 디버그 구매 시뮬레이션: $productId', name: 'PurchaseProvider');

      // 구매 지연 시뮬레이션
      await Future.delayed(DebugConfig.debugPaymentDelay);

      // 성공률 체크
      final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;
      if (random > DebugConfig.debugPaymentSuccessRate) {
        throw Exception('디버그 구매 실패 시뮬레이션');
      }

      // 가짜 구매 결과 생성
      final debugResult = PurchaseResult(
        status: PurchaseResultStatus.success,
        productId: productId,
        transactionId: DebugConfig.generateMockTransactionId(),
        purchaseDetails: null, // 디버그 모드에서는 null
        error: null,
      );

      // 구매 성공 처리 (_handleSuccessfulPurchase에서 loading 상태 해제함)
      await _handleSuccessfulPurchase(debugResult);
      
      Logger.log('[DEBUG] 디버그 구매 완료: $productId', name: 'PurchaseProvider');
      return true;
    } catch (e) {
      Logger.error('[DEBUG] 디버그 구매 실패: $e', name: 'PurchaseProvider');
      state = state.copyWith(
        isLoading: false,
        error: '디버그 구매 실패: $e',
      );
      return false;
    }
  }

  /// 디버그 포인트 제품 생성
  List<PointsProduct> _createDebugPointsProducts() {
    return [
      PointsProduct(
        id: 'dating_points_100',
        name: '100 포인트',
        description: '기본 포인트 패키지',
        price: '₩1,100',
        pointsAmount: 100,
        bonusPoints: 0,
      ),
      PointsProduct(
        id: 'dating_points_500',
        name: '500 포인트',
        description: '인기 포인트 패키지',
        price: '₩5,500',
        pointsAmount: 500,
        bonusPoints: 50,
      ),
      PointsProduct(
        id: 'dating_points_1000',
        name: '1000 포인트',
        description: '대용량 포인트 패키지',
        price: '₩11,000',
        pointsAmount: 1000,
        bonusPoints: 150,
      ),
      PointsProduct(
        id: 'dating_points_3000',
        name: '3000 포인트',
        description: '프리미엄 포인트 패키지',
        price: '₩33,000',
        pointsAmount: 3000,
        bonusPoints: 500,
      ),
      PointsProduct(
        id: 'dating_points_5000',
        name: '5000 포인트',
        description: '최고급 포인트 패키지',
        price: '₩55,000',
        pointsAmount: 5000,
        bonusPoints: 1000,
      ),
    ];
  }

  /// 디버그 하트 제품 생성
  List<HeartsProduct> _createDebugHeartsProducts() {
    return [
      HeartsProduct(
        id: 'dating_hearts_10',
        name: '10 하트',
        description: '기본 하트 패키지',
        price: '₩1,100',
        heartsAmount: 10,
        bonusHearts: 0,
      ),
      HeartsProduct(
        id: 'dating_hearts_50',
        name: '50 하트',
        description: '인기 하트 패키지',
        price: '₩5,500',
        heartsAmount: 50,
        bonusHearts: 5,
      ),
      HeartsProduct(
        id: 'dating_hearts_100',
        name: '100 하트',
        description: '대용량 하트 패키지',
        price: '₩11,000',
        heartsAmount: 100,
        bonusHearts: 15,
      ),
      HeartsProduct(
        id: 'dating_hearts_500',
        name: '500 하트',
        description: '프리미엄 하트 패키지',
        price: '₩55,000',
        heartsAmount: 500,
        bonusHearts: 100,
      ),
    ];
  }

  /// 디버그 VIP 제품 생성
  List<VipProduct> _createDebugVipProducts() {
    return [
      VipProduct(
        id: 'dating_vip_basic_1month',
        name: 'VIP 베이직 (1개월)',
        description: '기본 VIP 혜택',
        price: '₩9,900',
        vipTier: 'BASIC',
        durationDays: 30,
        features: ['무제한 좋아요', '슈퍼챗 2개/일', '기본 필터'],
      ),
      VipProduct(
        id: 'dating_vip_premium_1month',
        name: 'VIP 프리미엄 (1개월)',
        description: '프리미엄 VIP 혜택',
        price: '₩19,900',
        vipTier: 'PREMIUM',
        durationDays: 30,
        features: ['무제한 좋아요', '슈퍼챗 5개/일', '프로필 부스트', '고급 필터'],
      ),
      VipProduct(
        id: 'dating_vip_gold_1month',
        name: 'VIP 골드 (1개월)',
        description: '최고급 VIP 혜택',
        price: '₩29,900',
        vipTier: 'GOLD',
        durationDays: 30,
        features: ['무제한 좋아요', '무제한 슈퍼챗', '프로필 부스트', '모든 필터', '우선 고객지원'],
      ),
      VipProduct(
        id: 'dating_vip_basic_3months',
        name: 'VIP 베이직 (3개월)',
        description: '기본 VIP 혜택 3개월',
        price: '₩26,900',
        vipTier: 'BASIC',
        durationDays: 90,
        features: ['무제한 좋아요', '슈퍼챗 2개/일', '기본 필터'],
      ),
      VipProduct(
        id: 'dating_vip_premium_3months',
        name: 'VIP 프리미엄 (3개월)',
        description: '프리미엄 VIP 혜택 3개월',
        price: '₩53,900',
        vipTier: 'PREMIUM',
        durationDays: 90,
        features: ['무제한 좋아요', '슈퍼챗 5개/일', '프로필 부스트', '고급 필터'],
      ),
      VipProduct(
        id: 'dating_vip_gold_3months',
        name: 'VIP 골드 (3개월)',
        description: '최고급 VIP 혜택 3개월',
        price: '₩80,900',
        vipTier: 'GOLD',
        durationDays: 90,
        features: ['무제한 좋아요', '무제한 슈퍼챗', '프로필 부스트', '모든 필터', '우선 고객지원'],
      ),
    ];
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