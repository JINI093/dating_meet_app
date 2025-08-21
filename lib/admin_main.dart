import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'dart:async';

import 'admin/routes/admin_router.dart';
import 'admin/utils/admin_theme.dart';
import 'admin/services/admin_banner_service_amplify.dart';
import 'amplifyconfiguration.dart';

/// 관리자 페이지 전용 앱 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 캐시 초기화
  AdminBannerServiceAmplify.resetCache();
  
  // Amplify 초기화 (앱 시작 전에 완료)
  await _configureAmplify();
  
  // Storage 접근을 위한 설정은 AWS 콘솔에서 처리 필요
  
  runApp(const AdminApp());
}

/// AWS Amplify 초기화 (Auth + API + Storage)
Future<void> _configureAmplify() async {
  try {
    print('🚀 [Admin] Amplify 초기화 시작...');
    
    if (Amplify.isConfigured) {
      print('✅ [Admin] AWS Amplify 이미 초기화됨');
      await _verifyStorageService();
      return;
    }
    
    print('📦 [Admin] Amplify 플러그인 추가 중...');
    
    // Auth, API, Storage 플러그인 모두 추가
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
      AmplifyStorageS3(),
    ]);
    
    print('✅ [Admin] 플러그인 추가 완료 (Auth + API + Storage)');
    
    // 설정 적용
    print('⚙️ [Admin] Amplify 설정 적용 중...');
    await Amplify.configure(amplifyconfig);
    
    // Storage 서비스 검증
    await _verifyStorageService();
    
    print('✅ [Admin] AWS Amplify 초기화 완료!');
    print('📡 [Admin] 실제 AWS 서비스 사용 가능');
    
  } catch (e) {
    print('❌ [Admin] AWS Amplify 초기화 실패: $e');
    print('📊 [Admin] 시뮬레이션 모드로 계속 진행');
  }
}

/// Storage 서비스 검증
Future<void> _verifyStorageService() async {
  try {
    print('🔍 [Admin] Storage 서비스 검증 중...');
    
    // Storage 서비스가 사용 가능한지 확인
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 간단한 Storage 작업으로 연결 확인
    try {
      await Amplify.Storage.list(
        path: const StoragePath.fromString('public/'),
      ).result;
      print('✅ [Admin] Storage 서비스 연결 확인 완료');
    } catch (storageError) {
      print('⚠️ [Admin] Storage 연결 테스트 실패: $storageError');
      
      // guest 레벨로 재시도
      try {
        await Amplify.Storage.list(
          path: const StoragePath.fromString('guest/'),
        ).result;
        print('✅ [Admin] Storage 서비스 연결 확인 완료 (guest 레벨)');
      } catch (fallbackError) {
        print('⚠️ [Admin] Storage 폴백 테스트도 실패: $fallbackError');
        // 이 경우에도 계속 진행 (권한 문제일 수 있음)
      }
    }
    
  } catch (e) {
    print('⚠️ [Admin] Storage 검증 실패: $e');
  }
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