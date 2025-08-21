import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_auth_provider.dart';
import '../utils/admin_theme.dart';
import '../models/admin_user.dart';

/// 관리자 사이드바
class AdminSidebar extends ConsumerWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUser = ref.watch(currentAdminUserProvider);
    
    return Container(
      color: AdminTheme.surfaceColor,
      child: Column(
        children: [
          // Logo & Toggle
          _buildHeader(context),
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AdminTheme.spacingM),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: '대시보드',
                  route: '/admin/dashboard',
                  isActive: currentRoute == '/admin/dashboard',
                  hasPermission: true,
                ),
                
                // 회원관리
                if (adminUser != null && adminUser.role.accessibleMenus.contains('users')) ...[
                  _buildSectionTitle('회원관리'),
                  _buildMenuItem(
                    context,
                    icon: Icons.people_outline,
                    label: '회원정보',
                    route: '/admin/users',
                    isActive: currentRoute == '/admin/users',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: 'VIP회원관리',
                    route: '/admin/vip',
                    isActive: currentRoute == '/admin/vip',
                    hasPermission: adminUser.role.accessibleMenus.contains('vip'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.monetization_on_outlined,
                    label: '포인트 전환',
                    route: '/admin/points',
                    isActive: currentRoute == '/admin/points',
                    hasPermission: adminUser.role.accessibleMenus.contains('points'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.online_prediction,
                    label: '실시간 접속',
                    route: '/admin/realtime',
                    isActive: currentRoute == '/admin/realtime',
                    hasPermission: adminUser.role.accessibleMenus.contains('realtime'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.report_outlined,
                    label: '신고 관리',
                    route: '/admin/reports',
                    isActive: currentRoute == '/admin/reports',
                    hasPermission: adminUser.role.accessibleMenus.contains('reports'),
                  ),
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.leaderboard_outlined,
                  //   label: '순위',
                  //   route: '/admin/rankings',
                  //   isActive: currentRoute == '/admin/rankings',
                  //   hasPermission: adminUser.role.accessibleMenus.contains('rankings'),
                  // ),
                  // if (adminUser.role == AdminRole.superAdmin)
                  //   _buildMenuItem(
                  //     context,
                  //     icon: Icons.admin_panel_settings_outlined,
                  //     label: '관리자 관리',
                  //     route: '/admin/admins',
                  //     isActive: currentRoute == '/admin/admins',
                  //     hasPermission: true,
                  //   ),
                ],
                
                // 상품 스토어 관리
                if (adminUser != null && adminUser.role.accessibleMenus.contains('products')) ...[
                  _buildSectionTitle('상품 스토어'),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: '일반 상품',
                    route: '/admin/store/general',
                    isActive: currentRoute == '/admin/store/general',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.stars_outlined,
                    label: 'VIP 상품',
                    route: '/admin/store/vip',
                    isActive: currentRoute == '/admin/store/vip',
                    hasPermission: true,
                  ),
                ],
                
                // 결제 및 정산
                if (adminUser != null && adminUser.role.accessibleMenus.contains('payments')) ...[
                  _buildSectionTitle('결제 및 정산'),
                  _buildMenuItem(
                    context,
                    icon: Icons.payment_outlined,
                    label: '결제 내역',
                    route: '/admin/payment/history',
                    isActive: currentRoute == '/admin/payment/history',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_outlined,
                    label: '정산 내역',
                    route: '/admin/payment/settlement',
                    isActive: currentRoute == '/admin/payment/settlement',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.local_offer_outlined,
                    label: '쿠폰 및 코드',
                    route: '/admin/payment/coupons',
                    isActive: currentRoute == '/admin/payment/coupons',
                    hasPermission: adminUser.role.accessibleMenus.contains('coupons'),
                  ),
                ],
                
                // 신고 관리
                if (adminUser != null && adminUser.role.accessibleMenus.contains('reports')) ...[
                  _buildSectionTitle('신고 관리'),
                  _buildMenuItem(
                    context,
                    icon: Icons.flag_outlined,
                    label: '신고내역',
                    route: '/admin/report/history',
                    isActive: currentRoute == '/admin/report/history',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.block_outlined,
                    label: '블랙리스트',
                    route: '/admin/report/blacklist',
                    isActive: currentRoute == '/admin/report/blacklist',
                    hasPermission: adminUser.role.accessibleMenus.contains('blacklist'),
                  ),
                ],
                
                // 통계 데이터
                if (adminUser != null && adminUser.role.accessibleMenus.contains('statistics'))
                  _buildMenuItem(
                    context,
                    icon: Icons.analytics_outlined,
                    label: '통계 데이터',
                    route: '/admin/statistics',
                    isActive: currentRoute == '/admin/statistics',
                    hasPermission: true,
                  ),
                
                // 공지사항
                if (adminUser != null && adminUser.role.accessibleMenus.contains('notices')) ...[
                  _buildSectionTitle('공지사항'),
                  _buildMenuItem(
                    context,
                    icon: Icons.male_outlined,
                    label: '남성회원 공지',
                    route: '/admin/notice/male',
                    isActive: currentRoute == '/admin/notice/male',
                    hasPermission: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.female_outlined,
                    label: '여성회원 공지',
                    route: '/admin/notice/female',
                    isActive: currentRoute == '/admin/notice/female',
                    hasPermission: true,
                  ),
                ],
                
                // 설정
                if (adminUser != null && adminUser.role == AdminRole.superAdmin) ...[
                  _buildSectionTitle('시스템'),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: '설정',
                    route: '/admin/settings',
                    isActive: currentRoute == '/admin/settings',
                    hasPermission: true,
                  ),
                ],
              ],
            ),
          ),
          
          // Bottom Actions
          const Divider(height: 1),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? AdminTheme.spacingS : AdminTheme.spacingM,
      ),
      child: Row(
        children: [
          if (!isCollapsed) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            const Expanded(
              child: Text(
                '관리자',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.menu : Icons.menu_open,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    if (isCollapsed) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AdminTheme.spacingL,
        AdminTheme.spacingM,
        AdminTheme.spacingL,
        AdminTheme.spacingS,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AdminTheme.secondaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    required bool hasPermission,
  }) {
    if (!hasPermission) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? AdminTheme.spacingS : AdminTheme.spacingM,
        vertical: AdminTheme.spacingXS,
      ),
      child: Material(
        color: isActive ? AdminTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : AdminTheme.spacingM,
            ),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      icon,
                      color: isActive ? AdminTheme.primaryColor : AdminTheme.secondaryTextColor,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        icon,
                        color: isActive ? AdminTheme.primaryColor : AdminTheme.secondaryTextColor,
                        size: 24,
                      ),
                      const SizedBox(width: AdminTheme.spacingM),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isActive ? AdminTheme.primaryColor : AdminTheme.primaryTextColor,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(isCollapsed ? AdminTheme.spacingS : AdminTheme.spacingM),
      child: Material(
        color: AdminTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃 하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(adminAuthProvider.notifier).logout();
                      context.go('/admin/login');
                    },
                    child: Text(
                      '로그아웃',
                      style: TextStyle(color: AdminTheme.errorColor),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : AdminTheme.spacingM,
            ),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      Icons.logout,
                      color: AdminTheme.errorColor,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: AdminTheme.errorColor,
                        size: 24,
                      ),
                      const SizedBox(width: AdminTheme.spacingM),
                      Text(
                        '로그아웃',
                        style: TextStyle(
                          color: AdminTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}