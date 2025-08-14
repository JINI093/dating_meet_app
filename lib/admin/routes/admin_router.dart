import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_auth_provider.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_main_layout.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/users/admin_users_screen.dart';
import '../screens/users/admin_vip_screen.dart';
import '../screens/users/admin_points_screen.dart';
import '../screens/users/admin_realtime_screen.dart';
import '../screens/users/admin_reports_screen.dart';
import '../screens/users/admin_rankings_screen.dart';
import '../screens/users/admin_admins_screen.dart';

/// 관리자 라우터 설정
class AdminRouter {
  static final adminRoutes = [
    // Admin Login
    GoRoute(
      path: '/admin/login',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AdminLoginScreen(),
      ),
    ),
    
    // Admin Shell Route
    ShellRoute(
      builder: (context, state, child) {
        return AdminMainLayout(
          currentRoute: state.uri.toString(),
          child: child,
        );
      },
      routes: [
        // Dashboard
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminDashboardScreen(),
          ),
        ),
        
        // 회원관리
        GoRoute(
          path: '/admin/users',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminUsersScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/vip',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminVipScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/points',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminPointsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/realtime',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminRealtimeScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/reports',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminReportsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/rankings',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminRankingsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/admins',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminAdminsScreen(),
          ),
        ),
        
        // TODO: Add more routes for other screens
      ],
    ),
  ];

  /// 관리자 인증 리다이렉트
  static String? adminRedirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(adminAuthProvider);
    
    final isLoginRoute = state.uri.toString() == '/admin/login';
    final isAuthenticated = authState.isAuthenticated;
    
    // 로그인되지 않았는데 로그인 페이지가 아닌 경우
    if (!isAuthenticated && !isLoginRoute) {
      return '/admin/login';
    }
    
    // 로그인되었는데 로그인 페이지인 경우
    if (isAuthenticated && isLoginRoute) {
      return '/admin/dashboard';
    }
    
    // 권한 체크
    if (isAuthenticated && !isLoginRoute) {
      final path = state.uri.toString();
      final menu = _extractMenuFromPath(path);
      
      if (menu != null) {
        final hasPermission = container.read(hasAdminPermissionProvider(menu));
        if (!hasPermission) {
          return '/admin/dashboard';
        }
      }
    }
    
    return null;
  }
  
  static String? _extractMenuFromPath(String path) {
    final parts = path.split('/');
    if (parts.length >= 3 && parts[1] == 'admin') {
      return parts[2];
    }
    return null;
  }
}