import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_points_model.dart';
import '../services/aws_points_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

// Point State - AWS 호환 버전
class PointState {
  final UserPointsModel? userPoints;
  final bool isLoading;
  final String? error;
  final List<PointTransaction> transactions;

  const PointState({
    this.userPoints,
    this.isLoading = false,
    this.error,
    this.transactions = const [],
  });

  PointState copyWith({
    UserPointsModel? userPoints,
    bool? isLoading,
    String? error,
    List<PointTransaction>? transactions,
  }) {
    return PointState(
      userPoints: userPoints ?? this.userPoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transactions: transactions ?? this.transactions,
    );
  }

  // Helper getters
  int get currentPoints => userPoints?.currentPoints ?? 0;
  int get totalEarned => userPoints?.totalEarned ?? 0;
  int get totalSpent => userPoints?.totalSpent ?? 0;
  bool get hasPoints => currentPoints > 0;
  bool canSpend(int amount) => currentPoints >= amount;
}

// Point Provider - AWS 호환 버전
class PointNotifier extends StateNotifier<PointState> {
  final Ref ref;
  final AWSPointsService _pointsService = AWSPointsService();

  PointNotifier(this.ref) : super(const PointState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await initializePoints();
  }

  // Initialize point data from AWS
  Future<void> initializePoints() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      Logger.log('포인트 데이터 초기화 시작', name: 'PointProvider');
      
      // Get current user
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        Logger.log('사용자 인증 실패 - 포인트 초기화 불가', name: 'PointProvider');
        state = state.copyWith(isLoading: false);
        return;
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      // Load points from AWS
      final userPoints = await _pointsService.getUserPoints(userId);
      final transactions = await _pointsService.getPointTransactions(userId, limit: 50);
      
      state = state.copyWith(
        userPoints: userPoints,
        transactions: transactions,
        isLoading: false,
      );
      
      Logger.log('포인트 초기화 완료: ${userPoints?.currentPoints ?? 0}P', name: 'PointProvider');
      
    } catch (e) {
      Logger.error('포인트 초기화 실패: $e', name: 'PointProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add points (for testing or admin purposes)
  Future<void> addPoints(int amount, String description) async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      final updatedPoints = await _pointsService.addPoints(
        userId: userId,
        amount: amount,
        description: description,
        type: PointTransactionType.earned,
      );
      
      if (updatedPoints != null) {
        final transactions = await _pointsService.getPointTransactions(userId, limit: 50);
        
        state = state.copyWith(
          userPoints: updatedPoints,
          transactions: transactions,
          error: null,
        );
        
        Logger.log('포인트 추가 완료: ${updatedPoints.currentPoints}P', name: 'PointProvider');
      }
      
    } catch (e) {
      Logger.error('포인트 추가 실패: $e', name: 'PointProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  // Spend points
  Future<void> spendPoints(int amount, String description) async {
    try {
      if (!canSpendPoints(amount)) {
        throw Exception('포인트가 부족합니다. 현재: ${state.currentPoints}P, 필요: ${amount}P');
      }
      
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      final updatedPoints = await _pointsService.spendPoints(
        userId: userId,
        amount: amount,
        description: description,
        type: PointTransactionType.spentOther,
      );
      
      if (updatedPoints != null) {
        final transactions = await _pointsService.getPointTransactions(userId, limit: 50);
        
        state = state.copyWith(
          userPoints: updatedPoints,
          transactions: transactions,
          error: null,
        );
        
        Logger.log('포인트 사용 완료: ${updatedPoints.currentPoints}P', name: 'PointProvider');
      }
      
    } catch (e) {
      Logger.error('포인트 사용 실패: $e', name: 'PointProvider');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Check if user can spend points
  bool canSpendPoints(int amount) {
    return state.canSpend(amount);
  }

  // Get current point balance
  int getCurrentPoints() {
    return state.currentPoints;
  }

  // Refresh points data
  Future<void> refreshPoints() async {
    await initializePoints();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods for backward compatibility
  Future<bool> purchaseItem(String itemName, int points) async {
    try {
      await spendPoints(points, '$itemName 구매');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get transactions by type
  List<PointTransaction> getTransactionsByType(PointTransactionType type) {
    return state.transactions.where((t) => t.type == type).toList();
  }

  // Get earning transactions
  List<PointTransaction> getEarningTransactions() {
    return state.transactions.where((t) => t.amount > 0).toList();
  }

  // Get spending transactions
  List<PointTransaction> getSpendingTransactions() {
    return state.transactions.where((t) => t.amount < 0).toList();
  }
}

// Provider instances
final pointProvider = StateNotifierProvider<PointNotifier, PointState>((ref) {
  return PointNotifier(ref);
});

// Helper providers for backward compatibility
final currentPointsProvider = Provider<int>((ref) {
  return ref.watch(pointProvider).currentPoints;
});

final pointTransactionsProvider = Provider<List<PointTransaction>>((ref) {
  return ref.watch(pointProvider).transactions;
});

// Additional convenience providers
final canSpendProvider = Provider.family<bool, int>((ref, amount) {
  final pointState = ref.watch(pointProvider);
  return pointState.canSpend(amount);
});

final totalEarnedProvider = Provider<int>((ref) {
  return ref.watch(pointProvider).totalEarned;
});

final totalSpentProvider = Provider<int>((ref) {
  return ref.watch(pointProvider).totalSpent;
});