import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/honetcon_api_service.dart';
import '../providers/points_provider.dart';
import '../providers/enhanced_auth_provider.dart';
import '../utils/logger.dart';

/// Point exchange state
class PointExchangeState {
  final bool isLoading;
  final bool isExchanging;
  final List<GiftCardType> availableGiftCards;
  final GiftCardExchangeResult? lastExchangeResult;
  final String? error;
  final String? successMessage;

  const PointExchangeState({
    this.isLoading = false,
    this.isExchanging = false,
    this.availableGiftCards = const [],
    this.lastExchangeResult,
    this.error,
    this.successMessage,
  });

  PointExchangeState copyWith({
    bool? isLoading,
    bool? isExchanging,
    List<GiftCardType>? availableGiftCards,
    GiftCardExchangeResult? lastExchangeResult,
    String? error,
    String? successMessage,
  }) {
    return PointExchangeState(
      isLoading: isLoading ?? this.isLoading,
      isExchanging: isExchanging ?? this.isExchanging,
      availableGiftCards: availableGiftCards ?? this.availableGiftCards,
      lastExchangeResult: lastExchangeResult ?? this.lastExchangeResult,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Point exchange provider
class PointExchangeNotifier extends StateNotifier<PointExchangeState> {
  PointExchangeNotifier(this._ref) : super(const PointExchangeState()) {
    _loadAvailableGiftCards();
  }

  final Ref _ref;
  final HonetConApiService _apiService = HonetConApiService();

  /// Load available gift card types
  Future<void> _loadAvailableGiftCards() async {
    try {
      Logger.log('사용 가능한 상품권 목록 로드 시작', name: 'PointExchangeProvider');
      state = state.copyWith(isLoading: true, error: null);

      final giftCards = await _apiService.getAvailableGiftCardTypes();
      
      state = state.copyWith(
        isLoading: false,
        availableGiftCards: giftCards,
      );
      
      Logger.log('상품권 목록 로드 완료: ${giftCards.length}개', name: 'PointExchangeProvider');
    } catch (e) {
      Logger.error('상품권 목록 로드 실패: $e', name: 'PointExchangeProvider');
      state = state.copyWith(
        isLoading: false,
        error: e is HonetConApiException ? e.message : '상품권 정보를 불러올 수 없습니다',
      );
    }
  }

  /// Exchange points to gift card
  Future<bool> exchangePointsToGiftCard({
    required int points,
    required String giftCardType,
    required int giftCardValue,
    required String recipientEmail,
    String? recipientPhone,
    String? message,
  }) async {
    try {
      Logger.log('포인트 상품권 전환 시작: ${points}P -> $giftCardValue원', name: 'PointExchangeProvider');
      
      // 사용자 정보 확인
      final authState = _ref.read(enhancedAuthProvider);
      final currentUser = authState.currentUser?.user;
      
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 포인트 확인
      final pointsState = _ref.read(pointsProvider);
      if (pointsState.currentPoints < points) {
        throw Exception('보유 포인트가 부족합니다');
      }

      state = state.copyWith(isExchanging: true, error: null);

      // HonetCon API를 통한 상품권 전환
      final result = await _apiService.exchangePointsToGiftCard(
        userId: currentUser.userId,
        points: points,
        giftCardType: giftCardType,
        giftCardValue: giftCardValue,
        recipientEmail: recipientEmail,
        recipientPhone: recipientPhone,
        message: message,
      );

      if (result.success) {
        // 포인트 차감
        await _ref.read(pointsProvider.notifier).spendPoints(
          amount: points,
          description: '상품권 전환 (${result.giftCardType} $giftCardValue원)',
        );

        state = state.copyWith(
          isExchanging: false,
          lastExchangeResult: result,
          successMessage: '상품권 전환이 완료되었습니다. 전환 ID: ${result.exchangeId}',
        );

        Logger.log('상품권 전환 완료: ${result.exchangeId}', name: 'PointExchangeProvider');
        return true;
      } else {
        throw Exception('상품권 전환에 실패했습니다');
      }
    } catch (e) {
      Logger.error('상품권 전환 실패: $e', name: 'PointExchangeProvider');
      state = state.copyWith(
        isExchanging: false,
        error: e is HonetConApiException ? e.message : '상품권 전환 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  /// Check exchange status
  Future<ExchangeStatus?> checkExchangeStatus(String exchangeId) async {
    try {
      Logger.log('전환 상태 확인: $exchangeId', name: 'PointExchangeProvider');
      
      final status = await _apiService.checkExchangeStatus(exchangeId);
      Logger.log('전환 상태: ${status.status}', name: 'PointExchangeProvider');
      
      return status;
    } catch (e) {
      Logger.error('전환 상태 확인 실패: $e', name: 'PointExchangeProvider');
      state = state.copyWith(
        error: e is HonetConApiException ? e.message : '상태 확인 중 오류가 발생했습니다',
      );
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  /// Refresh gift card types
  Future<void> refreshGiftCardTypes() async {
    await _loadAvailableGiftCards();
  }

  /// Get recommended gift card based on points
  GiftCardType? getRecommendedGiftCard(int userPoints) {
    final availableCards = state.availableGiftCards
        .where((card) => card.isAvailable && userPoints >= card.minPoints)
        .toList();

    if (availableCards.isEmpty) return null;

    // 사용자 포인트에 가장 적합한 상품권 반환
    availableCards.sort((a, b) => 
        (a.minPoints - userPoints).abs().compareTo((b.minPoints - userPoints).abs()));

    return availableCards.first;
  }

  /// Calculate gift card value from points
  int calculateGiftCardValue(int points, double conversionRate) {
    return (points * conversionRate).round();
  }

  /// Validate exchange request
  String? validateExchangeRequest({
    required int points,
    required int userPoints,
    required String email,
    String? phone,
  }) {
    // 포인트 확인
    if (points <= 0) {
      return '전환할 포인트를 입력해주세요';
    }

    if (userPoints < points) {
      return '보유 포인트가 부족합니다';
    }

    // 최소 전환 포인트 확인 (1,000P)
    if (points < 1000) {
      return '최소 1,000P 이상부터 전환 가능합니다';
    }

    // 이메일 확인
    if (email.isEmpty) {
      return '이메일 주소를 입력해주세요';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return '올바른 이메일 주소를 입력해주세요';
    }

    // 전화번호 확인 (선택사항)
    if (phone != null && phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
      if (!phoneRegex.hasMatch(phone)) {
        return '전화번호는 010-XXXX-XXXX 형식으로 입력해주세요';
      }
    }

    return null; // 유효함
  }
}

/// Point exchange provider
final pointExchangeProvider = StateNotifierProvider<PointExchangeNotifier, PointExchangeState>((ref) {
  return PointExchangeNotifier(ref);
});