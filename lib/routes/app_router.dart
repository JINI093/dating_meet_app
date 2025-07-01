import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/users/user_list_screen.dart';
import '../screens/users/user_detail_screen.dart';
import '../screens/notice/notice_list_screen.dart';
import '../screens/notice/notice_detail_screen.dart';
import '../screens/notice/notice_edit_screen.dart';
import '../screens/faq/faq_list_screen.dart';
import '../screens/point/withdrawal_screen.dart';
import '../screens/point/point_settings_screen.dart';
import '../screens/ticket/ticket_settings_screen.dart';
import '../screens/privacy/privacy_list_screen.dart';
import '../screens/auth/admin_setting_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../widgets/layout/app_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/signin',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 로그인하지 않은 경우 로그인 페이지로 리다이렉트
      if (!authProvider.isAuthenticated && state.uri.path != '/signin') {
        return '/signin';
      }
      
      // 로그인한 경우 대시보드로 리다이렉트
      if (authProvider.isAuthenticated && state.uri.path == '/signin') {
        return '/';
      }
      
      return null;
    },
    routes: [
      // 인증 관련 라우트
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      
      // 보호된 라우트들 (AppLayout 사용)
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          // 대시보드
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // 관리자 설정
          GoRoute(
            path: '/admin-setting',
            builder: (context, state) => const AdminSettingScreen(),
          ),
          
          // 사용자 관리
          GoRoute(
            path: '/user-list',
            builder: (context, state) => const UserListScreen(),
          ),
          GoRoute(
            path: '/user-detail',
            builder: (context, state) => const UserDetailScreen(),
          ),
          
          // 포인트 관리
          GoRoute(
            path: '/point/setting',
            builder: (context, state) => const PointSettingsScreen(),
          ),
          GoRoute(
            path: '/withdrawal',
            builder: (context, state) => const WithdrawalScreen(),
          ),
          
          // 티켓 관리
          GoRoute(
            path: '/ticket/setting',
            builder: (context, state) => const TicketSettingsScreen(),
          ),
          
          // 공지사항 관리
          GoRoute(
            path: '/notice-list',
            builder: (context, state) => const NoticeListScreen(),
          ),
          GoRoute(
            path: '/notice-detail/:noticeId',
            builder: (context, state) {
              final noticeId = state.pathParameters['noticeId'];
              return NoticeDetailScreen(noticeId: noticeId ?? '');
            },
          ),
          GoRoute(
            path: '/notice-edit',
            builder: (context, state) => const NoticeEditScreen(),
          ),
          
          // FAQ 관리
          GoRoute(
            path: '/faq',
            builder: (context, state) => const FaqListScreen(),
          ),
          
          // 개인정보 관리
          GoRoute(
            path: '/privacy',
            builder: (context, state) => const PrivacyListScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
} 