import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/vip_model.dart';
import '../../widgets/common/custom_button.dart';

class PaymentConfirmationSheet extends StatefulWidget {
  final VipPlan plan;

  const PaymentConfirmationSheet({
    super.key,
    required this.plan,
  });

  @override
  State<PaymentConfirmationSheet> createState() => _PaymentConfirmationSheetState();
}

class _PaymentConfirmationSheetState extends State<PaymentConfirmationSheet> {
  int _selectedPaymentMethod = 0;
  bool _agreeToTerms = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': '카카오페이',
      'icon': CupertinoIcons.creditcard_fill,
      'color': Colors.yellow[700],
    },
    {
      'name': '네이버페이',
      'icon': CupertinoIcons.creditcard_fill,
      'color': Colors.green[600],
    },
    {
      'name': '신용카드',
      'icon': CupertinoIcons.creditcard,
      'color': AppColors.textSecondary,
    },
    {
      'name': '휴대폰 결제',
      'icon': CupertinoIcons.device_phone_portrait,
      'color': AppColors.textSecondary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacing12),
            width: AppDimensions.bottomSheetHandleWidth,
            height: AppDimensions.bottomSheetHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(
                AppDimensions.bottomSheetHandleHeight / 2,
              ),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: Row(
              children: [
                Text(
                  '결제 확인',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconM,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.bottomSheetPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Summary
                  _buildPlanSummary(),
                  
                  const SizedBox(height: AppDimensions.spacing24),
                  
                  // Payment Methods
                  _buildPaymentMethods(),
                  
                  const SizedBox(height: AppDimensions.spacing24),
                  
                  // Terms Agreement
                  _buildTermsAgreement(),
                  
                  const SizedBox(height: AppDimensions.spacing24),
                  
                  // Payment Info
                  _buildPaymentInfo(),
                  
                  const SizedBox(height: AppDimensions.spacing20),
                ],
              ),
            ),
          ),
          
          // Bottom Action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing8),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.star_fill,
                  color: AppColors.textWhite,
                  size: AppDimensions.iconM,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.name,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      widget.plan.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Price Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '결제 금액',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Row(
                      children: [
                        Text(
                          widget.plan.displayPrice,
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.plan.hasDiscount) ...[
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            widget.plan.displayOriginalPrice,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.7),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.plan.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '${widget.plan.discountPercent}% 할인',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textWhite,
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

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '결제 방법',
          style: AppTextStyles.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppDimensions.borderNormal,
            ),
          ),
          child: Column(
            children: _paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isSelected = _selectedPaymentMethod == index;
              final isLast = index == _paymentMethods.length - 1;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                        width: AppDimensions.borderNormal,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: AppDimensions.iconM,
                        ),
                      ),
                      
                      const SizedBox(width: AppDimensions.spacing12),
                      
                      Expanded(
                        child: Text(
                          method['name'] as String,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
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
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '약관 동의',
          style: AppTextStyles.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: _agreeToTerms ? AppColors.primary : AppColors.cardBorder,
                width: AppDimensions.borderNormal,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _agreeToTerms ? AppColors.primary : AppColors.cardBorder,
                      width: 2,
                    ),
                    color: _agreeToTerms ? AppColors.primary : Colors.transparent,
                  ),
                  child: _agreeToTerms
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: AppColors.textWhite,
                          size: 12,
                        )
                      : null,
                ),
                
                const SizedBox(width: AppDimensions.spacing12),
                
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: '서비스 이용약관'),
                        TextSpan(
                          text: ' 및 ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const TextSpan(text: '개인정보 처리방침'),
                        TextSpan(
                          text: '에 동의합니다.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.textHint,
                  size: AppDimensions.iconS,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 안내',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            '• 구독은 ${widget.plan.durationText} 단위로 자동 갱신됩니다',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            '• 자동 갱신은 언제든지 해지할 수 있습니다',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            '• 결제 후 즉시 VIP 혜택을 이용하실 수 있습니다',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.bottomSheetPadding,
        right: AppDimensions.bottomSheetPadding,
        top: AppDimensions.spacing12,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.spacing12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderNormal,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 결제 금액',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  widget.plan.displayPrice,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing16),
          
          CustomButton(
            text: '결제하기',
            onPressed: _agreeToTerms ? () => Navigator.pop(context, true) : null,
            width: 120,
          ),
        ],
      ),
    );
  }
}