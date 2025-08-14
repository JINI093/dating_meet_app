import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/heart_model.dart';
import '../services/heart_service.dart';
import '../utils/logger.dart';

class HeartState {
  final int currentHearts;
  final List<HeartPackage> packages;
  final List<HeartTransaction> transactions;
  final bool isLoading;
  final String? error;

  HeartState({
    required this.currentHearts,
    required this.packages,
    required this.transactions,
    this.isLoading = false,
    this.error,
  });

  HeartState copyWith({
    int? currentHearts,
    List<HeartPackage>? packages,
    List<HeartTransaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return HeartState(
      currentHearts: currentHearts ?? this.currentHearts,
      packages: packages ?? this.packages,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HeartNotifier extends StateNotifier<HeartState> {
  final HeartService _heartService = HeartService();

  HeartNotifier() : super(HeartState(
    currentHearts: 0,
    packages: [],
    transactions: [],
  )) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final packages = _heartService.getHeartPackages();
      final currentHearts = await _heartService.getCurrentHearts();
      final transactions = await _heartService.getHeartTransactions();

      state = state.copyWith(
        packages: packages,
        currentHearts: currentHearts,
        transactions: transactions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      Logger.error('하트 초기화 실패: $e', name: 'HeartProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 하트 구매
  Future<bool> purchaseHearts(HeartPackage package) async {
    try {
      // 로딩 상태는 UI에서 관리하도록 하고, 여기서는 데이터만 처리
      final success = await _heartService.purchaseHearts(package);
      
      if (success) {
        // 현재 하트 수와 거래 내역 업데이트
        final newHearts = await _heartService.getCurrentHearts();
        final newTransactions = await _heartService.getHeartTransactions();
        
        state = state.copyWith(
          currentHearts: newHearts,
          transactions: newTransactions,
          isLoading: false, // 명시적으로 false 설정
          error: null,
        );
        
        Logger.log('✅ 하트 구매 성공: ${package.totalCount}개', name: 'HeartProvider');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '하트 구매에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      Logger.error('하트 구매 오류: $e', name: 'HeartProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 하트 사용
  Future<bool> spendHearts(int amount, {String? description}) async {
    try {
      if (state.currentHearts < amount) {
        state = state.copyWith(error: '하트가 부족합니다. (현재: ${state.currentHearts}개)');
        return false;
      }

      final success = await _heartService.spendHearts(amount, description: description);
      
      if (success) {
        // 현재 하트 수와 거래 내역 업데이트
        final newHearts = await _heartService.getCurrentHearts();
        final newTransactions = await _heartService.getHeartTransactions();
        
        state = state.copyWith(
          currentHearts: newHearts,
          transactions: newTransactions,
          error: null,
        );
        
        Logger.log('✅ 하트 사용 성공: $amount개', name: 'HeartProvider');
        return true;
      } else {
        state = state.copyWith(error: '하트 사용에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('하트 사용 오류: $e', name: 'HeartProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 하트 정보 새로고침
  Future<void> refreshHearts() async {
    try {
      final currentHearts = await _heartService.getCurrentHearts();
      final transactions = await _heartService.getHeartTransactions();
      
      state = state.copyWith(
        currentHearts: currentHearts,
        transactions: transactions,
        error: null,
      );
    } catch (e) {
      Logger.error('하트 새로고침 실패: $e', name: 'HeartProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 오류 메시지 지우기
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 하트 정보 초기화 (개발/테스트용)
  Future<void> resetHearts() async {
    try {
      await _heartService.resetHearts();
      await _initialize();
    } catch (e) {
      Logger.error('하트 초기화 실패: $e', name: 'HeartProvider');
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider 정의
final heartProvider = StateNotifierProvider<HeartNotifier, HeartState>((ref) {
  return HeartNotifier();
});

// 현재 하트 수만 가져오는 간단한 Provider
final currentHeartsProvider = Provider<int>((ref) {
  return ref.watch(heartProvider).currentHearts;
});

// 하트 패키지 목록만 가져오는 Provider
final heartPackagesProvider = Provider<List<HeartPackage>>((ref) {
  return ref.watch(heartProvider).packages;
});

// 로딩 상태만 가져오는 Provider
final heartLoadingProvider = Provider<bool>((ref) {
  return ref.watch(heartProvider).isLoading;
});