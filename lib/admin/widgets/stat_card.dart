import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 통계 카드 위젯
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (trend != null && trendUp != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminTheme.spacingS,
                      vertical: AdminTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: trendUp!
                          ? AdminTheme.successColor.withOpacity(0.1)
                          : AdminTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp! ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trendUp!
                              ? AdminTheme.successColor
                              : AdminTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendUp!
                                ? AdminTheme.successColor
                                : AdminTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primaryTextColor,
                  ),
            ),
            const SizedBox(height: AdminTheme.spacingXS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdminTheme.secondaryTextColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}