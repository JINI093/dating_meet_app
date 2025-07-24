import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/vip_model.dart';

class VipPlanCard extends StatelessWidget {
  final VipPlan plan;
  final bool isSelected;
  final VoidCallback? onTap;

  const VipPlanCard({
    super.key,
    required this.plan,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2.0 : AppDimensions.borderNormal,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: AppDimensions.cardElevation,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Recommended Badge
            if (plan.isRecommended)
              Positioned(
                top: -1,
                left: AppDimensions.paddingM,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(AppDimensions.radiusS),
                    ),
                  ),
                  child: Text(
                    '추천',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            
            // Popular Badge
            if (plan.isPopular && !plan.isRecommended)
              Positioned(
                top: -1,
                right: AppDimensions.paddingM,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing12,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppDimensions.radiusS),
                    ),
                  ),
                  child: Text(
                    '인기',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.paddingM,
                right: AppDimensions.paddingM,
                top: plan.isRecommended || plan.isPopular 
                    ? AppDimensions.paddingL 
                    : AppDimensions.paddingM,
                bottom: AppDimensions.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: AppTextStyles.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing4),
                            Text(
                              plan.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: AppDimensions.spacing12),
                      
                      // Radio Button
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: AppColors.textWhite,
                                size: 12,
                              )
                            : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing16),
                  
                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.displayPrice,
                        style: AppTextStyles.h4.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      if (plan.hasDiscount) ...[
                        const SizedBox(width: AppDimensions.spacing8),
                        Text(
                          plan.displayOriginalPrice,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing4,
                            vertical: AppDimensions.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                          ),
                          child: Text(
                            '${plan.discountPercent}%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      
                      const Spacer(),
                      
                      Text(
                        plan.pricePerDayText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing16),
                  
                  // Features
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.divider,
                        width: AppDimensions.borderNormal,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '포함된 혜택',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        ...plan.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: isSelected ? AppColors.primary : AppColors.success,
                                size: AppDimensions.iconS,
                              ),
                              const SizedBox(width: AppDimensions.spacing8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing12),
                  
                  // Duration and Auto-renewal Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12,
                      vertical: AppDimensions.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          color: AppColors.textHint,
                          size: AppDimensions.iconS,
                        ),
                        const SizedBox(width: AppDimensions.spacing8),
                        Expanded(
                          child: Text(
                            '${plan.durationText} 구독 • 자동 갱신',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}