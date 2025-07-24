import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../providers/notification_provider.dart';

class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final bool showDot;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final hasUnread = unreadCount > 0;

    return Stack(
      children: [
        child,
        if (hasUnread || showDot)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: showDot
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: showDot
                  ? null
                  : Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
      ],
    );
  }
}