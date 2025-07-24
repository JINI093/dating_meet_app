import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/point_model.dart';

class PointItemCard extends StatelessWidget {
  final PointItem item;
  final bool canAfford;
  final VoidCallback onPurchase;
  final bool isPopular;

  const PointItemCard({
    super.key,
    required this.item,
    required this.canAfford,
    required this.onPurchase,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isPopular 
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: isPopular ? 2 : AppDimensions.borderNormal,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Icon
                _buildIcon(),
                
                const SizedBox(width: AppDimensions.spacing16),
                
                // Item Info
                Expanded(
                  child: _buildItemInfo(),
                ),
                
                const SizedBox(width: AppDimensions.spacing12),
                
                // Purchase Section
                _buildPurchaseSection(),
              ],
            ),
          ),
          
          // Popular Badge
          if (isPopular)
            Positioned(
              top: 8,
              right: 8,
              child: _buildPopularBadge(),
            ),
          
          // Limited Badge
          if (item.isLimited)
            Positioned(
              top: 8,
              left: 8,
              child: _buildLimitedBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: _getCategoryColor(),
        size: AppDimensions.iconL,
      ),
    );
  }

  Widget _buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppDimensions.spacing4),
        
        Text(
          item.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.categoryDisplayName,
            style: AppTextStyles.labelSmall.copyWith(
              color: _getCategoryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Points
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.points}P',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            
            if (item.hasBonus)
              Text(
                '+${item.bonusPoints}P',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spacing12),
        
        // Purchase Button
        GestureDetector(
          onTap: canAfford ? onPurchase : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: canAfford ? AppColors.primary : AppColors.textHint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              canAfford ? '구매' : '부족',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            color: AppColors.textWhite,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '인기',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.clock_fill,
            color: AppColors.textWhite,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '한정',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (item.category) {
      case 'boost':
        return AppColors.primary;
      case 'super_chat':
        return AppColors.secondary;
      case 'view':
        return AppColors.success;
      case 'special':
        return AppColors.vip;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'boost':
        return CupertinoIcons.rocket_fill;
      case 'super_chat':
        return CupertinoIcons.star_fill;
      case 'view':
        return CupertinoIcons.eye_fill;
      case 'special':
        return CupertinoIcons.sparkles;
      default:
        return CupertinoIcons.gift_fill;
    }
  }
}