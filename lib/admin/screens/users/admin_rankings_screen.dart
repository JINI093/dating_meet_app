import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// 순위 관리 화면
class AdminRankingsScreen extends ConsumerWidget {
  const AdminRankingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '순위 관리',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AdminTheme.spacingXL),
        
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Center(
                child: Text(
                  '순위 관리 기능 구현 예정',
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