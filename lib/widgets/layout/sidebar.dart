import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    return Container(
      width: isCollapsed ? 70 : 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 로고 영역
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!isCollapsed) ...[
                  const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Meet Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ],
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: AppTheme.lightTextSecondary,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),

          const Divider(),

          // 사용자 정보
          if (!isCollapsed && userData != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      userData['name']?[0] ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? '관리자',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          userData['email'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // 메뉴 아이템들
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: '대시보드',
                  route: '/',
                  isActive: currentLocation == '/',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  title: '사용자 관리',
                  route: '/user-list',
                  isActive: currentLocation == '/user-list',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.announcement,
                  title: '공지사항',
                  route: '/notice-list',
                  isActive: currentLocation.startsWith('/notice'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'FAQ',
                  route: '/faq',
                  isActive: currentLocation == '/faq',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: '포인트 관리',
                  route: '/point/setting',
                  isActive: currentLocation.startsWith('/point') || currentLocation == '/withdrawal',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.confirmation_number,
                  title: '티켓 관리',
                  route: '/ticket/setting',
                  isActive: currentLocation.startsWith('/ticket'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.privacy_tip,
                  title: '개인정보',
                  route: '/privacy',
                  isActive: currentLocation == '/privacy',
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: '관리자 설정',
                  route: '/admin-setting',
                  isActive: currentLocation == '/admin-setting',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : AppTheme.lightTextSecondary,
        ),
        title: isCollapsed
            ? null
            : Text(
                title,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : AppTheme.lightText,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
        tileColor: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          context.go(route);
        },
      ),
    );
  }
} 