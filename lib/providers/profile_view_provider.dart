import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/profile_view_service.dart';
import '../utils/logger.dart';

/// 프로필 열람권 상태
class ProfileViewState {
  final int currentProfileViewTickets;
  final bool isLoading;
  final String? error;

  const ProfileViewState({
    this.currentProfileViewTickets = 0,
    this.isLoading = false,
    this.error,
  });

  ProfileViewState copyWith({
    int? currentProfileViewTickets,
    bool? isLoading,
    String? error,
  }) {
    return ProfileViewState(
      currentProfileViewTickets: currentProfileViewTickets ?? this.currentProfileViewTickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 프로필 열람권 관리
class ProfileViewNotifier extends StateNotifier<ProfileViewState> {
  final ProfileViewService _service = ProfileViewService();

  ProfileViewNotifier() : super(const ProfileViewState());

  /// 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentProfileViewTickets = await _service.getCurrentProfileViewTickets();
      state = state.copyWith(
        currentProfileViewTickets: currentProfileViewTickets,
        isLoading: false,
      );
    } catch (e) {
      Logger.error('프로필 열람권 초기화 오류: $e', name: 'ProfileViewProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필 열람권 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 프로필 열람권 구매
  Future<bool> purchaseProfileViewTickets(int amount) async {
    try {
      final success = await _service.purchaseProfileViewTickets(amount);
      
      if (success) {
        final newProfileViewTickets = await _service.getCurrentProfileViewTickets();
        state = state.copyWith(
          currentProfileViewTickets: newProfileViewTickets,
          error: null,
        );
        
        Logger.log('✅ 프로필 열람권 구매 성공: $amount개', name: 'ProfileViewProvider');
        return true;
      } else {
        state = state.copyWith(error: '프로필 열람권 구매에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('프로필 열람권 구매 오류: $e', name: 'ProfileViewProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 프로필 열람권 사용
  Future<bool> spendProfileViewTickets(int amount, {String? description}) async {
    try {
      if (state.currentProfileViewTickets < amount) {
        state = state.copyWith(error: '프로필 열람권이 부족합니다. (현재: ${state.currentProfileViewTickets}개)');
        return false;
      }

      final success = await _service.spendProfileViewTickets(amount, description: description);
      
      if (success) {
        final newProfileViewTickets = await _service.getCurrentProfileViewTickets();
        state = state.copyWith(
          currentProfileViewTickets: newProfileViewTickets,
          error: null,
        );
        
        Logger.log('✅ 프로필 열람권 사용 성공: $amount개', name: 'ProfileViewProvider');
        return true;
      } else {
        state = state.copyWith(error: '프로필 열람권 사용에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('프로필 열람권 사용 오류: $e', name: 'ProfileViewProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 프로필 열람권 정보 새로고침
  Future<void> refreshProfileViewTickets() async {
    try {
      final currentProfileViewTickets = await _service.getCurrentProfileViewTickets();
      state = state.copyWith(
        currentProfileViewTickets: currentProfileViewTickets,
        error: null,
      );
    } catch (e) {
      Logger.error('프로필 열람권 새로고침 실패: $e', name: 'ProfileViewProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화
  void reset() {
    state = const ProfileViewState();
  }
}

/// 프로필 열람권 프로바이더
final profileViewProvider = StateNotifierProvider<ProfileViewNotifier, ProfileViewState>((ref) {
  return ProfileViewNotifier();
});

/// 현재 보유 프로필 열람권 수 프로바이더
final currentProfileViewTicketsProvider = Provider<int>((ref) {
  return ref.watch(profileViewProvider).currentProfileViewTickets;
});