import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// 신고 내역 관리 화면
class AdminReportHistoryScreen extends ConsumerWidget {
  const AdminReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신고 내역',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AdminTheme.spacingL),
        const Expanded(
          child: Center(
            child: Text('신고 내역 관리 기능 구현 예정'),
          ),
        ),
      ],
    );
  }
}