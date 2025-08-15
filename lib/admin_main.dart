import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'admin/routes/admin_router.dart';
import 'admin/utils/admin_theme.dart';

/// 관리자 페이지 전용 앱 진입점
void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Dating Meet Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.theme,
        themeMode: ThemeMode.light,
        routerConfig: _adminRouter,
      ),
    );
  }
}

/// 관리자 전용 라우터 설정
final _adminRouter = GoRouter(
  initialLocation: '/admin/dashboard',
  debugLogDiagnostics: true,
  routes: AdminRouter.adminRoutes,
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '요청한 페이지를 찾을 수 없습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Path: ${state.matchedLocation}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/admin/login'),
            child: const Text('관리자 로그인으로 이동'),
          ),
        ],
      ),
    ),
  ),
  redirect: (context, state) {
    // 관리자 인증 상태 확인
    final isAdminRoute = state.matchedLocation.startsWith('/admin');
    
    if (isAdminRoute) {
      // TODO: 실제 관리자 인증 상태 확인 로직
      // 현재는 모든 관리자 라우트 허용
      return null;
    }
    
    // 관리자가 아닌 경우 로그인으로 리다이렉트
    return '/admin/login';
  },
);