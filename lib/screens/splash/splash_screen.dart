import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile_model.dart';
import '../../providers/permission_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../routes/route_names.dart';
import '../../services/aws_profile_service.dart';

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
    final permissionManager = ref.read(permissionManagerProvider);
    var permissionStatus =  await permissionManager.checkAllPermissionStatuses();
    print("_showPermissionSequence");
    await _checkAutoLogin();
  }
  
  Future<void> _checkAutoLogin() async {
    try {
      print("_checkAutoLogin--->1");

      final authProvider = ref.read(enhancedAuthProvider.notifier);
      final isAutoLoginEnabled = await authProvider.loadAutoLogin();
      print("_checkAutoLogin--->2");
      if (isAutoLoginEnabled) {
        print('자동로그인 시도 중...');
        final result = await authProvider.checkAutoLogin();

        if (result.success) {
          print('자동로그인 성공 - 메인화면으로 이동');
          final profileService = AWSProfileService();
          ProfileModel? profile;
          if(result.user?.user?.userId != null) {
            try {
              print("=====> 자동 로그인 아이디 : ${result.user!.user!.userId}");
              profile = await profileService.getProfileByUserId(result.user!.user!.userId).timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  print('프로필 조회 타임아웃 - 프로필 없는 것으로 간주');
                  return null;
                },
              );

            } catch (profileError) {
              print('프로필 조회 실패: $profileError');
              profile = null; // 조회 실패 시 프로필 없는 것으로 처리
            }

            if (profile != null) {
              // 프로필이 존재하면 홈으로
              print('프로필 존재 - 홈으로 이동: ${profile.name}');
              context.pushReplacement(RouteNames.home);
              // context.pushReplacement(RouteNames.profileSetup);

            } else {
              // 프로필이 없으면 온보딩으로
              print('프로필 없음 - 온보딩으로 이동');
              context.pushReplacement(RouteNames.onboardingTutorial);
            }
          } else {
            context.go('/login');
          }
        } else {
          context.go('/login');
          print('자동로그인 실패: ${result.error}');
        }
      } else {
        print('로그인 화면으로 이동');
        context.go('/login');

      }

    } catch (e) {
      print('자동로그인 체크 에러: $e');
      if (mounted) {
        context.go('/login');
      }
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

 