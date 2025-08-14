import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_auth_provider.dart';
import '../utils/admin_theme.dart';

/// 관리자 헤더
class AdminHeader extends ConsumerWidget {
  final VoidCallback? onMenuTap;

  const AdminHeader({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUser = ref.watch(currentAdminUserProvider);
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AdminTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
      child: Row(
        children: [
          // Mobile Menu Button
          if (onMenuTap != null) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: AdminTheme.spacingM),
          ],
          
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AdminTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AdminTheme.radiusM),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색...',
                  hintStyle: const TextStyle(
                    color: AdminTheme.disabledTextColor,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AdminTheme.disabledTextColor,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AdminTheme.spacingM,
                    vertical: AdminTheme.spacingS,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          
          const SizedBox(width: AdminTheme.spacingL),
          
          // Notifications
          _buildNotificationButton(),
          
          const SizedBox(width: AdminTheme.spacingM),
          
          // User Profile
          if (adminUser != null) _buildUserProfile(adminUser),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Show notifications
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AdminTheme.errorColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile(adminUser) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingM,
          vertical: AdminTheme.spacingS,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AdminTheme.borderColor),
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminTheme.primaryColor,
              child: Text(
                adminUser.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AdminTheme.spacingS),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminUser.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  adminUser.role.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AdminTheme.spacingS),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AdminTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: AdminTheme.spacingM),
              const Text('내 프로필'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: AdminTheme.spacingM),
              const Text('설정'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AdminTheme.errorColor),
              const SizedBox(width: AdminTheme.spacingM),
              Text(
                '로그아웃',
                style: TextStyle(color: AdminTheme.errorColor),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // TODO: Navigate to profile
            break;
          case 'settings':
            // TODO: Navigate to settings
            break;
          case 'logout':
            // TODO: Logout
            break;
        }
      },
    );
  }
}