import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/recommend_card_service.dart';
import '../utils/logger.dart';

/// 추천카드 더보기 상태
class RecommendCardState {
  final int currentRecommendCards;
  final bool isLoading;
  final String? error;

  const RecommendCardState({
    this.currentRecommendCards = 0,
    this.isLoading = false,
    this.error,
  });

  RecommendCardState copyWith({
    int? currentRecommendCards,
    bool? isLoading,
    String? error,
  }) {
    return RecommendCardState(
      currentRecommendCards: currentRecommendCards ?? this.currentRecommendCards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 추천카드 더보기 관리
class RecommendCardNotifier extends StateNotifier<RecommendCardState> {
  final RecommendCardService _service = RecommendCardService();

  RecommendCardNotifier() : super(const RecommendCardState());

  /// 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentRecommendCards = await _service.getCurrentRecommendCards();
      state = state.copyWith(
        currentRecommendCards: currentRecommendCards,
        isLoading: false,
      );
    } catch (e) {
      Logger.error('추천카드 초기화 오류: $e', name: 'RecommendCardProvider');
      state = state.copyWith(
        isLoading: false,
        error: '추천카드 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 추천카드 구매
  Future<bool> purchaseRecommendCards(int amount) async {
    try {
      final success = await _service.purchaseRecommendCards(amount);
      
      if (success) {
        final newRecommendCards = await _service.getCurrentRecommendCards();
        state = state.copyWith(
          currentRecommendCards: newRecommendCards,
          error: null,
        );
        
        Logger.log('✅ 추천카드 구매 성공: $amount개', name: 'RecommendCardProvider');
        return true;
      } else {
        state = state.copyWith(error: '추천카드 구매에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('추천카드 구매 오류: $e', name: 'RecommendCardProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 추천카드 사용
  Future<bool> spendRecommendCards(int amount, {String? description}) async {
    try {
      if (state.currentRecommendCards < amount) {
        state = state.copyWith(error: '추천카드가 부족합니다. (현재: ${state.currentRecommendCards}개)');
        return false;
      }

      final success = await _service.spendRecommendCards(amount, description: description);
      
      if (success) {
        final newRecommendCards = await _service.getCurrentRecommendCards();
        state = state.copyWith(
          currentRecommendCards: newRecommendCards,
          error: null,
        );
        
        Logger.log('✅ 추천카드 사용 성공: $amount개', name: 'RecommendCardProvider');
        return true;
      } else {
        state = state.copyWith(error: '추천카드 사용에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('추천카드 사용 오류: $e', name: 'RecommendCardProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 추천카드 정보 새로고침
  Future<void> refreshRecommendCards() async {
    try {
      final currentRecommendCards = await _service.getCurrentRecommendCards();
      state = state.copyWith(
        currentRecommendCards: currentRecommendCards,
        error: null,
      );
    } catch (e) {
      Logger.error('추천카드 새로고침 실패: $e', name: 'RecommendCardProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화
  void reset() {
    state = const RecommendCardState();
  }
}

/// 추천카드 프로바이더
final recommendCardProvider = StateNotifierProvider<RecommendCardNotifier, RecommendCardState>((ref) {
  return RecommendCardNotifier();
});

/// 현재 보유 추천카드 수 프로바이더
final currentRecommendCardsProvider = Provider<int>((ref) {
  return ref.watch(recommendCardProvider).currentRecommendCards;
});