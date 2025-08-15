import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/logger.dart';
import '../models/purchase_models.dart';

/// 인앱결제 서비스
/// iOS App Store와 Google Play Store에서 제품 구매, 복원 등을 처리
class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // 콜백 함수들
  Function(PurchaseResult)? onPurchaseUpdated;
  Function(String error)? onPurchaseError;
  Function(List<ProductDetails>)? onProductsLoaded;

  // 제품 ID 정의
  static const Map<String, String> productIds = {
    // VIP 플랜
    'vip_basic_1month': 'dating_vip_basic_1month',
    'vip_premium_1month': 'dating_vip_premium_1month',
    'vip_gold_1month': 'dating_vip_gold_1month',
    'vip_basic_3months': 'dating_vip_basic_3months',
    'vip_premium_3months': 'dating_vip_premium_3months',
    'vip_gold_3months': 'dating_vip_gold_3months',
    
    // 포인트 패키지
    'points_100': 'dating_points_100',
    'points_500': 'dating_points_500',
    'points_1000': 'dating_points_1000',
    'points_3000': 'dating_points_3000',
    'points_5000': 'dating_points_5000',
    
    // 하트 패키지
    'hearts_10': 'dating_hearts_10',
    'hearts_50': 'dating_hearts_50',
    'hearts_100': 'dating_hearts_100',
    'hearts_500': 'dating_hearts_500',
  };

  /// 서비스 초기화
  Future<bool> initialize() async {
    try {
      Logger.log('인앱결제 서비스 초기화 시작', name: 'InAppPurchase');
      
      // 인앱결제 사용 가능 여부 확인
      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        Logger.log('인앱결제를 사용할 수 없습니다', name: 'InAppPurchase');
        return false;
      }

      // 플랫폼별 초기화
      if (Platform.isAndroid) {
        await _initializeAndroid();
      } else if (Platform.isIOS) {
        await _initializeiOS();
      }

      // 구매 상태 변경 리스너 설정
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => Logger.log('구매 스트림 완료', name: 'InAppPurchase'),
        onError: (error) => Logger.error('구매 스트림 오류: $error', name: 'InAppPurchase'),
      );

      Logger.log('인앱결제 서비스 초기화 완료', name: 'InAppPurchase');
      return true;
    } catch (e) {
      Logger.error('인앱결제 서비스 초기화 실패: $e', name: 'InAppPurchase');
      return false;
    }
  }

  /// Android 전용 초기화
  Future<void> _initializeAndroid() async {
    if (Platform.isAndroid) {
      // Google Play Billing Client는 자동으로 설정됩니다
      Logger.log('Android 인앱결제 설정 완료', name: 'InAppPurchase');
    }
  }

  /// iOS 전용 초기화
  Future<void> _initializeiOS() async {
    if (Platform.isIOS) {
      // App Store 연결은 자동으로 설정됩니다
      Logger.log('iOS 인앱결제 설정 완룼', name: 'InAppPurchase');
    }
  }

  /// 제품 정보 조회
  Future<List<ProductDetails>> getProducts({List<String>? productIds}) async {
    try {
      final Set<String> ids = productIds?.toSet() ?? 
          InAppPurchaseService.productIds.values.toSet();
      
      Logger.log('제품 정보 조회 시작: ${ids.length}개', name: 'InAppPurchase');
      
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
      
      if (response.error != null) {
        Logger.error('제품 정보 조회 실패: ${response.error}', name: 'InAppPurchase');
        throw Exception('제품 정보를 가져올 수 없습니다: ${response.error!.message}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        Logger.log('찾을 수 없는 제품 ID: ${response.notFoundIDs}', name: 'InAppPurchase');
      }

      Logger.log('제품 정보 조회 완료: ${response.productDetails.length}개', name: 'InAppPurchase');
      onProductsLoaded?.call(response.productDetails);
      
      return response.productDetails;
    } catch (e) {
      Logger.error('제품 정보 조회 중 오류: $e', name: 'InAppPurchase');
      throw Exception('제품 정보를 가져오는 중 오류가 발생했습니다');
    }
  }

  /// 제품 구매
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      Logger.log('제품 구매 시작: ${product.id}', name: 'InAppPurchase');
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null, // 사용자 ID를 넣을 수 있음
      );

      bool success = false;
      
      if (product.id.contains('subscription') || product.id.contains('vip')) {
        // 구독 제품
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // 소비성 제품 (포인트, 하트)
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }

      if (success) {
        Logger.log('구매 요청 성공: ${product.id}', name: 'InAppPurchase');
      } else {
        Logger.log('구매 요청 실패: ${product.id}', name: 'InAppPurchase');
      }

      return success;
    } catch (e) {
      Logger.error('제품 구매 중 오류: $e', name: 'InAppPurchase');
      onPurchaseError?.call('구매 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    try {
      Logger.log('구매 복원 시작', name: 'InAppPurchase');
      await _inAppPurchase.restorePurchases();
      Logger.log('구매 복원 완료', name: 'InAppPurchase');
    } catch (e) {
      Logger.error('구매 복원 실패: $e', name: 'InAppPurchase');
      onPurchaseError?.call('구매 복원 중 오류가 발생했습니다');
    }
  }

  /// 구매 상태 변경 처리
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      Logger.log('구매 상태 업데이트: ${purchaseDetails.productID} - ${purchaseDetails.status}', 
          name: 'InAppPurchase');
      
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }
    }
  }

  /// 대기 중인 구매 처리
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    Logger.log('구매 대기 중: ${purchaseDetails.productID}', name: 'InAppPurchase');
    onPurchaseUpdated?.call(PurchaseResult(
      status: PurchaseResultStatus.pending,
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID,
      purchaseDetails: purchaseDetails,
    ));
  }

  /// 성공한 구매 처리
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    Logger.log('구매 성공: ${purchaseDetails.productID}', name: 'InAppPurchase');
    
    // 구매 완료 처리
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    onPurchaseUpdated?.call(PurchaseResult(
      status: PurchaseResultStatus.success,
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID,
      purchaseDetails: purchaseDetails,
    ));
  }

  /// 실패한 구매 처리
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    Logger.error('구매 실패: ${purchaseDetails.productID} - ${purchaseDetails.error}', 
        name: 'InAppPurchase');
    
    onPurchaseUpdated?.call(PurchaseResult(
      status: PurchaseResultStatus.error,
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID,
      error: purchaseDetails.error?.message ?? '구매 실패',
      purchaseDetails: purchaseDetails,
    ));
  }

  /// 복원된 구매 처리
  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    Logger.log('구매 복원: ${purchaseDetails.productID}', name: 'InAppPurchase');
    
    onPurchaseUpdated?.call(PurchaseResult(
      status: PurchaseResultStatus.restored,
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID,
      purchaseDetails: purchaseDetails,
    ));
  }

  /// 취소된 구매 처리
  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    Logger.log('구매 취소: ${purchaseDetails.productID}', name: 'InAppPurchase');
    
    onPurchaseUpdated?.call(PurchaseResult(
      status: PurchaseResultStatus.canceled,
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID,
      purchaseDetails: purchaseDetails,
    ));
  }

  /// 구매 영수증 검증 (서버 검증)
  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      Logger.log('구매 영수증 검증 시작: ${purchaseDetails.productID}', name: 'InAppPurchase');
      
      // TODO: 실제 서버 검증 로직 구현
      // 현재는 로컬 검증만 수행
      final bool isValid = purchaseDetails.verificationData.localVerificationData.isNotEmpty;
      
      if (isValid) {
        Logger.log('구매 영수증 검증 성공', name: 'InAppPurchase');
      } else {
        Logger.log('구매 영수증 검증 실패', name: 'InAppPurchase');
      }
      
      return isValid;
    } catch (e) {
      Logger.error('구매 영수증 검증 중 오류: $e', name: 'InAppPurchase');
      return false;
    }
  }

  /// 서비스 종료
  void dispose() {
    _subscription.cancel();
    Logger.log('인앱결제 서비스 종료', name: 'InAppPurchase');
  }
}

