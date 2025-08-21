import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 알림 전송 기록을 표시하는 위젯
class NotificationLogWidget extends StatelessWidget {
  final String userId;
  final String userName;

  const NotificationLogWidget({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AdminTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.history, color: AdminTheme.primaryColor),
                const SizedBox(width: AdminTheme.spacingS),
                Text(
                  '알림 전송 기록',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingM),
            
            // Recent notifications (placeholder)
            _buildNotificationItem(
              '인연은 타이밍, 지금 사귈래~ 🤍',
              DateTime.now().subtract(const Duration(minutes: 5)),
              true,
            ),
            const Divider(),
            _buildNotificationItem(
              '새로운 메시지가 도착했어요!',
              DateTime.now().subtract(const Duration(hours: 2)),
              true,
            ),
            const Divider(),
            _buildNotificationItem(
              '프로필을 업데이트해보세요',
              DateTime.now().subtract(const Duration(days: 1)),
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String message, DateTime sentAt, bool success) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? AdminTheme.successColor : AdminTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: AdminTheme.spacingM),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(sentAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Status text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: success 
                  ? AdminTheme.successColor.withValues(alpha: 0.1)
                  : AdminTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: success ? AdminTheme.successColor : AdminTheme.errorColor,
              ),
            ),
            child: Text(
              success ? '전송됨' : '실패',
              style: TextStyle(
                color: success ? AdminTheme.successColor : AdminTheme.errorColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}