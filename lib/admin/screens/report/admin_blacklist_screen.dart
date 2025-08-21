import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// 블랙리스트 관리 화면
class AdminBlacklistScreen extends ConsumerWidget {
  const AdminBlacklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '블랙리스트',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AdminTheme.spacingL),
        const Expanded(
          child: Center(
            child: Text('블랙리스트 관리 기능 구현 예정'),
          ),
        ),
      ],
    );
  }
}