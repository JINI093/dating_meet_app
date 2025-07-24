import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/point_model.dart';
import '../services/aws_points_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

// Point State
class PointState {
  final int currentPoints;
  final List<PointItem> availableItems;
  final List<PointPurchase> purchases;
  final List<PointTransaction> transactions;
  final bool isLoading;
  final String? error;

  const PointState({
    required this.currentPoints,
    required this.availableItems,
    required this.purchases,
    required this.transactions,
    required this.isLoading,
    this.error,
  });

  PointState copyWith({
    int? currentPoints,
    List<PointItem>? availableItems,
    List<PointPurchase>? purchases,
    List<PointTransaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return PointState(
      currentPoints: currentPoints ?? this.currentPoints,
      availableItems: availableItems ?? this.availableItems,
      purchases: purchases ?? this.purchases,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Helper methods
  List<PointPurchase> getActivePurchases() {
    return purchases.where((p) => p.isActive).toList();
  }

  List<PointPurchase> getPurchasesByCategory(String category) {
    return purchases.where((p) {
      final item = availableItems.firstWhere(
        (item) => item.id == p.itemId,
        orElse: () => PointItem(
          id: '',
          name: '',
          description: '',
          category: '',
          points: 0,
          iconUrl: '',
        ),
      );
      return item.category == category;
    }).toList();
  }

  int getTotalSpentPoints() {
    return transactions
        .where((t) => t.isSpent)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  int getTotalEarnedPoints() {
    return transactions
        .where((t) => t.isEarned || t.type == PointTransactionType.bonus)
        .fold(0, (sum, t) => sum + t.amount);
  }
}

// Point Provider
class PointNotifier extends StateNotifier<PointState> {
  final Ref ref;
  final AWSPointsService _pointsService = AWSPointsService();

  PointNotifier(this.ref) : super(const PointState(
    currentPoints: 0,
    availableItems: [],
    purchases: [],
    transactions: [],
    isLoading: false,
  )) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _pointsService.initialize();
      await initializePoints();
    } catch (e) {
      Logger.error('포인트 provider 초기화 실패', error: e, name: 'PointProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  // Initialize point data
  Future<void> initializePoints() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get current user
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        // If not logged in, use default values
        state = state.copyWith(
          currentPoints: 0,
          availableItems: [],
          transactions: [],
          isLoading: false,
        );
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      
      // Load data from AWS services
      final userPoints = await _pointsService.getUserPoints(userId);
      final transactions = await _pointsService.getPointTransactions(userId: userId);
      
      // Use default values if userPoints is null
      final currentPoints = userPoints?.availablePoints ?? 0;
      final items = PointItem.getAllMockItems(); // Use mock items for now until AWS service is implemented
      
      state = state.copyWith(
        currentPoints: currentPoints,
        availableItems: items,
        transactions: transactions,
        purchases: [], // Will be populated from transactions
        isLoading: false,
        error: null,
      );

      Logger.log('포인트 데이터 로드 완료: ${currentPoints}포인트, ${transactions.length}개 거래', name: 'PointProvider');
    } catch (e) {
      Logger.error('포인트 데이터 로드 실패', error: e, name: 'PointProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Purchase item
  Future<bool> purchaseItem(PointItem item) async {
    if (state.currentPoints < item.points) {
      state = state.copyWith(error: '포인트가 부족합니다');
      return false;
    }

    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create purchase record
      final purchase = PointPurchase(
        id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        itemName: item.name,
        pointsSpent: item.points,
        purchasedAt: DateTime.now(),
        expiresAt: _getExpirationDate(item),
        status: PurchaseStatus.active,
      );
      
      // Create transaction record
      final transaction = PointTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: -item.points,
        type: PointTransactionType.spent,
        description: '${item.name} 구매',
        createdAt: DateTime.now(),
        relatedItemId: item.id,
      );
      
      // Update state
      final updatedPurchases = [...state.purchases, purchase];
      final updatedTransactions = [...state.transactions, transaction];
      final newCurrentPoints = state.currentPoints - item.points;
      
      state = state.copyWith(
        currentPoints: newCurrentPoints,
        purchases: updatedPurchases,
        transactions: updatedTransactions,
        isLoading: false,
        error: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Add points (for testing or admin purposes)
  Future<void> addPoints(int amount, String description) async {
    try {
      final transaction = PointTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        type: PointTransactionType.earned,
        description: description,
        createdAt: DateTime.now(),
      );
      
      final updatedTransactions = [...state.transactions, transaction];
      final newCurrentPoints = state.currentPoints + amount;
      
      state = state.copyWith(
        currentPoints: newCurrentPoints,
        transactions: updatedTransactions,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Spend points (for profile unlock, etc.)
  Future<void> spendPoints(int amount, String description) async {
    try {
      final transaction = PointTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: -amount,
        type: PointTransactionType.spent,
        description: description,
        createdAt: DateTime.now(),
      );
      
      final updatedTransactions = [...state.transactions, transaction];
      final newCurrentPoints = state.currentPoints - amount;
      
      state = state.copyWith(
        currentPoints: newCurrentPoints,
        transactions: updatedTransactions,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Use purchased item
  Future<bool> usePurchasedItem(String purchaseId) async {
    try {
      final purchaseIndex = state.purchases.indexWhere((p) => p.id == purchaseId);
      if (purchaseIndex == -1) {
        state = state.copyWith(error: '구매 항목을 찾을 수 없습니다');
        return false;
      }
      
      final purchase = state.purchases[purchaseIndex];
      if (!purchase.isActive) {
        state = state.copyWith(error: '사용할 수 없는 항목입니다');
        return false;
      }
      
      // Update purchase to used
      final updatedPurchase = PointPurchase(
        id: purchase.id,
        itemId: purchase.itemId,
        itemName: purchase.itemName,
        pointsSpent: purchase.pointsSpent,
        purchasedAt: purchase.purchasedAt,
        usedAt: DateTime.now(),
        expiresAt: purchase.expiresAt,
        status: PurchaseStatus.used,
      );
      
      final updatedPurchases = [...state.purchases];
      updatedPurchases[purchaseIndex] = updatedPurchase;
      
      state = state.copyWith(purchases: updatedPurchases);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Get items by category
  List<PointItem> getItemsByCategory(String category) {
    return state.availableItems.where((item) => item.category == category).toList();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  int _calculateCurrentPoints(List<PointTransaction> transactions) {
    return transactions.fold(0, (sum, transaction) => sum + transaction.amount);
  }

  DateTime? _getExpirationDate(PointItem item) {
    // Set expiration based on item type
    switch (item.category) {
      case 'boost':
        if (item.name.contains('1시간')) {
          return DateTime.now().add(const Duration(hours: 1));
        } else if (item.name.contains('3시간')) {
          return DateTime.now().add(const Duration(hours: 3));
        } else if (item.name.contains('24시간')) {
          return DateTime.now().add(const Duration(hours: 24));
        }
        break;
      case 'special':
        if (item.name.contains('무제한 좋아요')) {
          return DateTime.now().add(const Duration(days: 1));
        }
        break;
      default:
        return null; // No expiration for other items
    }
    return null;
  }
}

// Provider instances
final pointProvider = StateNotifierProvider<PointNotifier, PointState>((ref) {
  return PointNotifier(ref);
});

// Helper providers
final currentPointsProvider = Provider<int>((ref) {
  return ref.watch(pointProvider).currentPoints;
});

final availableItemsProvider = Provider<List<PointItem>>((ref) {
  return ref.watch(pointProvider).availableItems;
});

final activePurchasesProvider = Provider<List<PointPurchase>>((ref) {
  return ref.watch(pointProvider).getActivePurchases();
});

final pointTransactionsProvider = Provider<List<PointTransaction>>((ref) {
  return ref.watch(pointProvider).transactions;
});

// Category-specific providers
final boostItemsProvider = Provider<List<PointItem>>((ref) {
  final pointNotifier = ref.read(pointProvider.notifier);
  return pointNotifier.getItemsByCategory('boost');
});

final superChatItemsProvider = Provider<List<PointItem>>((ref) {
  final pointNotifier = ref.read(pointProvider.notifier);
  return pointNotifier.getItemsByCategory('super_chat');
});

final viewItemsProvider = Provider<List<PointItem>>((ref) {
  final pointNotifier = ref.read(pointProvider.notifier);
  return pointNotifier.getItemsByCategory('view');
});

final specialItemsProvider = Provider<List<PointItem>>((ref) {
  final pointNotifier = ref.read(pointProvider.notifier);
  return pointNotifier.getItemsByCategory('special');
});