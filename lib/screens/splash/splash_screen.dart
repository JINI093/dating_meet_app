import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/permission_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _proceeding = false;

  @override
  void initState() {
    super.initState();
    // 지연 시간을 1초로 단축하여 빠른 진행
    Future.delayed(const Duration(milliseconds: 800), _proceedToPermission);
  }

  void _proceedToPermission() {
    if (_proceeding) return;
    _proceeding = true;
    _showPermissionSequence();
  }

  void _onTap() {
    _proceedToPermission();
  }

  Future<void> _showPermissionSequence() async {
    final permissionState = ref.read(permissionProvider);
    
    // 권한이 이미 초기화되었고 요청이 완료된 경우, 바로 로그인 화면으로 이동
    if (permissionState.isInitialized && 
        permissionState.permissions != null && 
        permissionState.permissions!.allRequested) {
      print('권한이 이미 요청되었음. 로그인 화면으로 이동');
      if (mounted) {
        context.go('/login');
      }
      return;
    }
    
    // 권한이 초기화되지 않은 경우, 초기화 대기
    if (!permissionState.isInitialized) {
      print('권한 초기화 대기 중...');
      final permissionNotifier = ref.read(permissionProvider.notifier);
      await permissionNotifier.initializePermissions();
      
      // 초기화 후 상태 다시 확인
      final updatedState = ref.read(permissionProvider);
      if (updatedState.permissions != null && updatedState.permissions!.allRequested) {
        print('권한 초기화 완료. 로그인 화면으로 이동');
        if (mounted) {
          context.go('/login');
        }
        return;
      }
    }
    
    // 여기까지 도달하면 권한 요청이 완료되었으므로 로그인 화면으로 이동
    print('권한 처리 완료. 로그인 화면으로 이동');
    if (mounted) {
      context.go('/login');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/splash/SPLASH@3x.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 