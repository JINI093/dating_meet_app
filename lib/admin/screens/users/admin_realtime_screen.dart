import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// 실시간 접속 현황 화면
class AdminRealtimeScreen extends ConsumerWidget {
  const AdminRealtimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 접속 현황',
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
                  '실시간 접속 현황 기능 구현 예정',
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