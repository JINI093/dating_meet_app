import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_points_model.dart';
import '../services/aws_points_service.dart';
import '../utils/logger.dart';
import '../utils/debug_config.dart';
import 'enhanced_auth_provider.dart';

// Points State
class PointsState {
  final UserPointsModel? userPoints;
  final bool isLoading;
  final String? error;
  final List<PointTransaction> recentTransactions;

  const PointsState({
    this.userPoints,
    this.isLoading = false,
    this.error,
    this.recentTransactions = const [],
  });

  PointsState copyWith({
    UserPointsModel? userPoints,
    bool? isLoading,
    String? error,
    List<PointTransaction>? recentTransactions,
  }) {
    return PointsState(
      userPoints: userPoints ?? this.userPoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  int get currentPoints => userPoints?.currentPoints ?? 0;
  int get totalEarned => userPoints?.totalEarned ?? 0;
  int get totalSpent => userPoints?.totalSpent ?? 0;
  bool get hasPoints => currentPoints > 0;
  bool canSpend(int amount) => currentPoints >= amount;
}

// Points Provider
class PointsNotifier extends StateNotifier<PointsState> {
  final Ref _ref;
  final AWSPointsService _pointsService = AWSPointsService();
  DateTime? _lastLoadTime;
  String? _lastUserId;
  static const Duration _cacheTimeout = Duration(minutes: 5); // 5분 캐시
  
  PointsNotifier(this._ref) : super(const PointsState()) {
    // Listen to auth state changes
    _ref.listen(enhancedAuthProvider, (previous, next) {
      if (next.isSignedIn && next.currentUser?.user?.userId != null) {
        final userId = next.currentUser!.user!.userId;
        // 새로운 사용자이거나 캐시가 만료된 경우에만 로드
        if (_lastUserId != userId || _shouldReloadCache()) {
          loadUserPoints(force: true);
        }
      }
    });
    
    // Try to load points on initialization
    _initialize();
  }

  // Initialize points data
  Future<void> _initialize() async {
    // Add a small delay to ensure auth state is ready
    await Future.delayed(const Duration(milliseconds: 500));
    await loadUserPoints();
  }

  // 캐시 만료 확인
  bool _shouldReloadCache() {
    if (_lastLoadTime == null) return true;
    return DateTime.now().difference(_lastLoadTime!) > _cacheTimeout;
  }
  
  // Load user points from AWS
  Future<void> loadUserPoints({bool force = false}) async {
    // Get current user from auth provider
    final authState = _ref.read(enhancedAuthProvider);
    
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      Logger.log('사용자 인증 실패 - 포인트 로드 불가', name: 'PointsProvider');
      return;
    }
    
    final userId = authState.currentUser!.user!.userId;
    
    // 캐시 확인 (force가 false이고 캐시가 유효한 경우 스킵)
    if (!force && _lastUserId == userId && !_shouldReloadCache()) {
      Logger.log('포인트 캐시 사용 - 새로 로드하지 않음', name: 'PointsProvider');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      Logger.log('사용자 포인트 로드 시작', name: 'PointsProvider');
      Logger.log('Auth state: isSignedIn=${authState.isSignedIn}, userId=${authState.currentUser?.user?.userId}', name: 'PointsProvider');
      Logger.log('포인트 로드 중 - userId: $userId', name: 'PointsProvider');
      
      UserPointsModel? userPoints;
      List<PointTransaction> transactions = [];
      
      // 디버그 모드에서는 로컬 데이터 우선 로드
      if (DebugConfig.enableDebugPayments) {
        Logger.log('[DEBUG] 디버그 모드 - 로컬 포인트 로드', name: 'PointsProvider');
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final pointsJson = prefs.getString('debug_user_points_$userId');
          if (pointsJson != null) {
            userPoints = UserPointsModel.fromJson(json.decode(pointsJson));
            transactions = userPoints.transactions;
            Logger.log('[DEBUG] 로컬 포인트 로드 성공: ${userPoints.currentPoints}P', name: 'PointsProvider');
          } else {
            // 로컬 데이터가 없으면 초기 포인트 생성
            userPoints = UserPointsModel.initial(userId);
            Logger.log('[DEBUG] 초기 포인트 생성: ${userPoints.currentPoints}P', name: 'PointsProvider');
          }
        } catch (e) {
          Logger.log('[DEBUG] 로컬 포인트 로드 실패, 초기 포인트 생성: $e', name: 'PointsProvider');
          userPoints = UserPointsModel.initial(userId);
        }
      } else {
        // 실제 AWS 서비스 사용
        try {
          userPoints = await _pointsService.getUserPoints(userId);
          if (userPoints != null) {
            transactions = await _pointsService.getPointTransactions(userId, limit: 10);
          }
        } catch (e) {
          Logger.log('AWS 포인트 로드 실패, 로컬 데이터 시도: $e', name: 'PointsProvider');
          // AWS 실패 시 로컬 데이터로 폴백
          try {
            final prefs = await SharedPreferences.getInstance();
            final pointsJson = prefs.getString('debug_user_points_$userId');
            if (pointsJson != null) {
              userPoints = UserPointsModel.fromJson(json.decode(pointsJson));
              transactions = userPoints.transactions;
            } else {
              userPoints = UserPointsModel.initial(userId);
            }
          } catch (localError) {
            userPoints = UserPointsModel.initial(userId);
          }
        }
      }
      
      if (userPoints != null) {
        state = state.copyWith(
          userPoints: userPoints,
          recentTransactions: transactions,
          isLoading: false,
        );
        
        // 캐시 정보 업데이트
        _lastLoadTime = DateTime.now();
        _lastUserId = userId;
        
        Logger.log('포인트 로드 성공: ${userPoints.currentPoints}P', name: 'PointsProvider');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '포인트 정보를 불러올 수 없습니다.',
        );
      }
      
    } catch (e) {
      Logger.error('포인트 로드 실패: $e', name: 'PointsProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add points (purchase, reward, etc.)
  Future<bool> addPoints({
    required int amount,
    required String description,
    PointTransactionType type = PointTransactionType.earned,
  }) async {
    try {
      Logger.log('포인트 추가 요청: +$amount', name: 'PointsProvider');
      
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      UserPointsModel? updatedPoints;
      
      // 디버그 모드에서는 로컬 상태만 업데이트
      if (DebugConfig.enableDebugPayments) {
        Logger.log('[DEBUG] 디버그 모드 - 로컬 포인트 추가만 수행', name: 'PointsProvider');
        
        // 현재 포인트 가져오기 (없으면 기본값)
        final currentUserPoints = state.userPoints ?? UserPointsModel.initial(userId);
        
        // 포인트 추가 (모델의 addPoints 메서드 사용)
        updatedPoints = currentUserPoints.addPoints(amount, description, type);
        
        // 로컬 저장 (SharedPreferences)
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('debug_user_points_$userId', json.encode(updatedPoints.toJson()));
        } catch (e) {
          Logger.log('[DEBUG] 로컬 포인트 저장 실패: $e', name: 'PointsProvider');
        }
      } else {
        // 실제 AWS 서비스 사용
        updatedPoints = await _pointsService.addPoints(
          userId: userId,
          amount: amount,
          description: description,
          type: type,
        );
      }
      
      if (updatedPoints != null) {
        // Update local state
        List<PointTransaction> transactions = [];
        if (!DebugConfig.enableDebugPayments) {
          try {
            transactions = await _pointsService.getPointTransactions(userId, limit: 10);
          } catch (e) {
            Logger.log('트랜잭션 로드 실패, 로컬 트랜잭션 사용: $e', name: 'PointsProvider');
            transactions = updatedPoints.transactions;
          }
        } else {
          transactions = updatedPoints.transactions;
        }
        
        state = state.copyWith(
          userPoints: updatedPoints,
          recentTransactions: transactions,
          error: null,
        );
        
        Logger.log('포인트 추가 완료: ${updatedPoints.currentPoints}P', name: 'PointsProvider');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('포인트 추가 실패: $e', name: 'PointsProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Spend points
  Future<bool> spendPoints({
    required int amount,
    required String description,
    PointTransactionType type = PointTransactionType.spentOther,
  }) async {
    try {
      Logger.log('포인트 사용 요청: -$amount', name: 'PointsProvider');
      
      // Check if user has enough points
      if (!canSpendPoints(amount)) {
        throw Exception('포인트가 부족합니다. 현재: ${state.currentPoints}P, 필요: ${amount}P');
      }
      
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      final updatedPoints = await _pointsService.spendPoints(
        userId: userId,
        amount: amount,
        description: description,
        type: type,
      );
      
      if (updatedPoints != null) {
        // Update local state
        final transactions = await _pointsService.getPointTransactions(userId, limit: 10);
        
        state = state.copyWith(
          userPoints: updatedPoints,
          recentTransactions: transactions,
          error: null,
        );
        
        Logger.log('포인트 사용 완료: ${updatedPoints.currentPoints}P', name: 'PointsProvider');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('포인트 사용 실패: $e', name: 'PointsProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Purchase points
  Future<bool> purchasePoints({
    required int amount,
    required int price,
    required String paymentMethod,
  }) async {
    try {
      Logger.log('포인트 구매 요청: +$amount (₩$price)', name: 'PointsProvider');
      
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      final updatedPoints = await _pointsService.purchasePoints(
        userId: userId,
        amount: amount,
        price: price,
        paymentMethod: paymentMethod,
      );
      
      if (updatedPoints != null) {
        // Update local state
        final transactions = await _pointsService.getPointTransactions(userId, limit: 10);
        
        state = state.copyWith(
          userPoints: updatedPoints,
          recentTransactions: transactions,
          error: null,
        );
        
        Logger.log('포인트 구매 완료: ${updatedPoints.currentPoints}P', name: 'PointsProvider');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('포인트 구매 실패: $e', name: 'PointsProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Check if user can spend points
  bool canSpendPoints(int amount) {
    return state.canSpend(amount);
  }

  // Get point balance
  int getPointBalance() {
    return state.currentPoints;
  }

  // Load transaction history
  Future<void> loadTransactionHistory({int limit = 50}) async {
    try {
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }
      
      final userId = authState.currentUser!.user!.userId;
      final transactions = await _pointsService.getPointTransactions(userId, limit: limit);
      
      state = state.copyWith(recentTransactions: transactions);
      
    } catch (e) {
      Logger.error('거래 내역 로드 실패: $e', name: 'PointsProvider');
    }
  }

  // Refresh points data
  Future<void> refreshPoints() async {
    await loadUserPoints();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods for specific use cases
  Future<bool> spendForVip(int amount, String vipTier) async {
    return await spendPoints(
      amount: amount,
      description: 'VIP $vipTier 구매',
      type: PointTransactionType.spentVip,
    );
  }

  Future<bool> spendForSuperchat(int amount) async {
    return await spendPoints(
      amount: amount,
      description: '슈퍼챗 사용',
      type: PointTransactionType.spentSuperchat,
    );
  }

  Future<bool> spendForBoost(int amount) async {
    return await spendPoints(
      amount: amount,
      description: '프로필 부스트',
      type: PointTransactionType.spentBoost,
    );
  }

  Future<bool> spendForUnlock(int amount, String profileName) async {
    return await spendPoints(
      amount: amount,
      description: '$profileName 프로필 언락',
      type: PointTransactionType.spentUnlock,
    );
  }
}

// Provider definitions
final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((ref) {
  return PointsNotifier(ref);
});

// Convenience providers
final currentPointsProvider = Provider<int>((ref) {
  final pointsState = ref.watch(pointsProvider);
  return pointsState.currentPoints;
});

final canSpendProvider = Provider.family<bool, int>((ref, amount) {
  final pointsState = ref.watch(pointsProvider);
  return pointsState.canSpend(amount);
});

final recentTransactionsProvider = Provider<List<PointTransaction>>((ref) {
  final pointsState = ref.watch(pointsProvider);
  return pointsState.recentTransactions;
});