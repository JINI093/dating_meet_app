import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin_main_layout.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
// 회원관리 화면
import '../screens/users/admin_users_screen.dart';
import '../screens/users/admin_vip_screen.dart';
import '../screens/users/admin_points_screen.dart';
import '../screens/users/admin_realtime_screen.dart';
import '../screens/users/admin_rankings_screen.dart';
import '../screens/users/admin_admins_screen.dart';

// 상품 스토어 관리 화면
import '../screens/store/admin_general_products_screen.dart';
import '../screens/store/admin_vip_products_screen.dart';

// 결제 및 정산 화면
import '../screens/payment/admin_payment_history_screen.dart';
import '../screens/payment/admin_settlement_screen.dart';
import '../screens/payment/admin_coupons_screen.dart';

// 신고 관리 화면
import '../screens/report/admin_report_screen.dart';
import '../screens/report/admin_blacklist_screen.dart';

// 통계 및 공지사항 화면
import '../screens/statistics/admin_statistics_screen.dart';
import '../screens/notice/admin_notice_screen.dart';
import '../screens/notice/admin_male_notice_screen.dart';
import '../screens/notice/admin_female_notice_screen.dart';
import '../screens/settings/admin_settings_screen.dart';

/// 관리자 라우터 설정
class AdminRouter {
  static final adminRoutes = [
    // Admin 기본 경로 - 바로 대시보드로 리다이렉트
    GoRoute(
      path: '/admin',
      redirect: (context, state) => '/admin/dashboard',
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
            child: const AdminReportScreen(),
          ),
        ),
        // GoRoute(
        //   path: '/admin/rankings',
        //   pageBuilder: (context, state) => MaterialPage(
        //     key: state.pageKey,
        //     child: const AdminRankingsScreen(),
        //   ),
        // ),
        // GoRoute(
        //   path: '/admin/admins',
        //   pageBuilder: (context, state) => MaterialPage(
        //     key: state.pageKey,
        //     child: const AdminAdminsScreen(),
        //   ),
        // ),
        
        // 상품 스토어 관리
        GoRoute(
          path: '/admin/store/general',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminGeneralProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/store/vip',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminVipProductsScreen(),
          ),
        ),
        
        // 결제 및 정산
        GoRoute(
          path: '/admin/payment/history',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminPaymentHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/payment/settlement',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminSettlementScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/payment/coupons',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminCouponsScreen(),
          ),
        ),
        
        // 신고 관리
        GoRoute(
          path: '/admin/report/history',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminReportScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/report/blacklist',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminBlacklistScreen(),
          ),
        ),
        
        // 통계 데이터
        GoRoute(
          path: '/admin/statistics',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminStatisticsScreen(),
          ),
        ),
        
        // 공지사항
        GoRoute(
          path: '/admin/notice',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminNoticeScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/notice/male',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminMaleNoticeScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/notice/female',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminFemaleNoticeScreen(),
          ),
        ),
        
        // 설정
        GoRoute(
          path: '/admin/settings',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminSettingsScreen(),
          ),
        ),
      ],
    ),
  ];

  /// 관리자 인증 리다이렉트 (로그인 제거됨)
  static String? adminRedirect(BuildContext context, GoRouterState state) {
    // 로그인 검증 없이 모든 관리자 페이지 접근 허용
    return null;
  }

}