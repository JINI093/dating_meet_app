import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 차트 카드 위젯
class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  final List<Widget>? actions;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.height,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingM),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}