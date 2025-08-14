import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// VIP 회원 관리 화면
class AdminVipScreen extends ConsumerWidget {
  const AdminVipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VIP 회원 관리',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AdminTheme.spacingXL),
        
        // VIP 통계 카드들
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingL),
                  child: Column(
                    children: [
                      Text(
                        'VIP 회원 수',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AdminTheme.spacingS),
                      Text(
                        '2,845',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingL),
                  child: Column(
                    children: [
                      Text(
                        '월 VIP 매출',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AdminTheme.spacingS),
                      Text(
                        '₩12.5M',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.successColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AdminTheme.spacingXL),
        
        // VIP 회원 목록
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Center(
                child: Text(
                  'VIP 회원 관리 기능 구현 예정',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AdminTheme.secondaryTextColor,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}