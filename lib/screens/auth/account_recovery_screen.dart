import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';

class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'ID/PW 찾기',
          style: AppTextStyles.h6.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacing32),
            
            // 제목
            Text(
              '계정 복구 방법을 선택하세요',
              style: AppTextStyles.h4.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing8),
            
            // 설명
            Text(
              '아이디를 찾거나 비밀번호를 재설정할 수 있습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing48),
            
            // 아이디 찾기 카드
            _buildOptionCard(
              icon: CupertinoIcons.person,
              title: '아이디 찾기',
              subtitle: '휴대폰 번호로 아이디를 찾을 수 있습니다',
              onTap: () => _goToFindId(),
            ),
            
            const SizedBox(height: AppDimensions.spacing24),
            
            // 비밀번호 찾기 카드
            _buildOptionCard(
              icon: CupertinoIcons.lock,
              title: '비밀번호 찾기',
              subtitle: '아이디를 입력하여 비밀번호를 재설정합니다',
              onTap: () => _goToResetPassword(),
            ),
            
            const Spacer(),
            
            // 도움말 텍스트
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      Text(
                        '도움말',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    '• 회원가입 시 입력한 정보로만 찾을 수 있습니다\n• 문제가 지속되면 고객센터로 문의해 주세요',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
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

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing16),
              
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h6.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 화살표
              Icon(
                CupertinoIcons.right_chevron,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToFindId() {
    context.push('/find-id');
  }

  void _goToResetPassword() {
    context.push('/reset-password');
  }
}