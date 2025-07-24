import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';

class SignupCompleteScreen extends ConsumerWidget {
  final Map<String, dynamic>? signupData;
  
  const SignupCompleteScreen({super.key, this.signupData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.spacing12,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: AppColors.textPrimary,
                      size: AppDimensions.iconM,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    _buildLogo(),
                    
                    const SizedBox(height: AppDimensions.spacing64),
                    
                    // Title
                    Text(
                      '회원가입 완료!',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing24),
                    
                    // Description
                    Column(
                      children: [
                        Text(
                          '회원가입이 완료되었습니다!',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Text(
                          '완벽한 MEET이음을 위하여',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Text(
                          '본인 프로필 등록 과정으로 이동합니다',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: CustomButton(
                text: '프로필 작성하기',
                onPressed: () => _goToProfileSetup(context),
                style: CustomButtonStyle.gradient,
                size: CustomButtonSize.large,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Heart with Crown
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing8),
              child: const Icon(
                CupertinoIcons.heart_fill,
                color: AppColors.primary,
                size: 64,
              ),
            ),
            Positioned(
              top: -8,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(width: AppDimensions.spacing16),
        
        // App Name
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
            vertical: AppDimensions.spacing12,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Text(
            '사랑해',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
        ),
      ],
    );
  }

  void _goToProfileSetup(BuildContext context) {
    // Navigate to profile setup with signup data if available
    if (signupData != null) {
      context.go('/profile-setup', extra: signupData);
    } else {
      // Fallback to onboarding tutorial
      context.go('/onboarding-tutorial');
    }
  }
}