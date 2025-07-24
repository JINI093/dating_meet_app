import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/point_model.dart';
import '../../providers/point_provider.dart';

class PointHistoryScreen extends ConsumerStatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  ConsumerState<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends ConsumerState<PointHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointState = ref.watch(pointProvider);
    final currentPoints = ref.watch(currentPointsProvider);
    final transactions = ref.watch(pointTransactionsProvider);
    final purchases = ref.watch(activePurchasesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            CupertinoIcons.chevron_left,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Ïx∏ ¥Ì',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Points Summary
          _buildPointsSummary(currentPoints, pointState),
          
          // Tab Bar
          _buildTabBar(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Transactions
                _buildTransactionsList(transactions),
                
                // Active Purchases
                _buildPurchasesList(purchases),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummary(int currentPoints, PointState pointState) {
    final totalEarned = pointState.getTotalEarnedPoints();
    final totalSpent = pointState.getTotalSpentPoints();

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.money_dollar_circle_fill,
                color: AppColors.textWhite,
                size: AppDimensions.iconL,
              ),
              
              const SizedBox(width: AppDimensions.spacing8),
              
              Text(
                '¨ Ïx∏',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing8),
              
              Text(
                '$currentPoints P',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing20),
          
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  ' ç›',
                  '$totalEarned P',
                  AppColors.success,
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: AppColors.textWhite.withValues(alpha: 0.3),
              ),
              
              Expanded(
                child: _buildSummaryItem(
                  ' ¨©',
                  '$totalSpent P',
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(
          label == ' ç›' ? CupertinoIcons.add_circled : CupertinoIcons.minus_circled,
          color: iconColor,
          size: AppDimensions.iconM,
        ),
        
        const SizedBox(height: AppDimensions.spacing4),
        
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textWhite.withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing2),
        
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        indicatorPadding: const EdgeInsets.all(AppDimensions.spacing4),
        labelColor: AppColors.textWhite,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Ïx∏ ¥Ì'),
          Tab(text: 'Ù  Dt\'),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<PointTransaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState('Ïx∏ ¥Ìt ∆µ»‰', 'Ïx∏| ¨©Xpò ç›Xt Ï0– \‹)»‰');
    }

    // Sort by date (newest first)
    final sortedTransactions = List<PointTransaction>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(PointTransaction transaction) {
    final isPositive = transaction.amount > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              isPositive 
                  ? CupertinoIcons.add_circled_solid
                  : CupertinoIcons.minus_circled,
              color: isPositive ? AppColors.success : AppColors.error,
              size: AppDimensions.iconM,
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          // Transaction info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing4),
                
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${transaction.amount} P',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.typeDisplayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesList(List<PointPurchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState('Ù  Dt\t ∆µ»‰', 'Dt\D l‰Xt Ï0– \‹)»‰');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return _buildPurchaseItem(purchase);
      },
    );
  }

  Widget _buildPurchaseItem(PointPurchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: purchase.isActive 
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              _getIconForPurchase(purchase),
              color: AppColors.primary,
              size: AppDimensions.iconM,
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          // Purchase info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.itemName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing4),
                
                Text(
                  'l‰|: ${_formatDateTime(purchase.purchasedAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                if (purchase.expiresAt != null)
                  Text(
                    'ÃÃ|: ${_formatDateTime(purchase.expiresAt!)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: purchase.isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Status and Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(purchase).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  purchase.statusDisplayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getStatusColor(purchase),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing8),
              
              if (purchase.isActive && !purchase.isUsed)
                GestureDetector(
                  onTap: () => _usePurchasedItem(purchase),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Text(
                      '¨©X0',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(
                color: AppColors.cardBorder,
                width: AppDimensions.borderNormal,
              ),
            ),
            child: const Icon(
              CupertinoIcons.doc_text,
              color: AppColors.textHint,
              size: 40,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing20),
          
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForPurchase(PointPurchase purchase) {
    // This would typically be based on the item category
    // For now, using a generic icon
    return CupertinoIcons.gift_fill;
  }

  Color _getStatusColor(PointPurchase purchase) {
    switch (purchase.status) {
      case PurchaseStatus.active:
        return purchase.isExpired ? AppColors.error : AppColors.success;
      case PurchaseStatus.used:
        return AppColors.textSecondary;
      case PurchaseStatus.expired:
        return AppColors.error;
      case PurchaseStatus.refunded:
        return AppColors.warning;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return ') ';
        }
        return '${difference.inMinutes}Ñ ';
      }
      return '${difference.inHours}‹ ';
    } else if (difference.inDays == 1) {
      return '¥';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}| ';
    } else {
      return '${dateTime.month}‘ ${dateTime.day}|';
    }
  }

  void _usePurchasedItem(PointPurchase purchase) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(purchase.itemName),
        content: const Text('t Dt\D ¨©X‹†µ»L?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ëå'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('¨©'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(pointProvider.notifier).usePurchasedItem(purchase.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${purchase.itemName}D(|) ¨©àµ»‰!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final error = ref.read(pointProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? '¨©  $X  ›àµ»‰'),
              backgroundColor: AppColors.error,
            ),
          );
          ref.read(pointProvider.notifier).clearError();
        }
      }
    }
  }
}