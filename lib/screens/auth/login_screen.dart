import 'package:dating_app_40s/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../services/aws_profile_service.dart';
import '../../models/profile_model.dart';
import 'mobileok_api_verification_screen.dart';
import '../../providers/user_provider.dart';
import '../../providers/likes_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool showLoginForm = false;
  bool showPhoneForm = false;
  
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,  // 키보드가 나타나도 화면이 리사이즈되지 않도록 설정
      body: Stack(
        children: [
          // 배경 이미지 (항상 화면 전체를 덮도록)
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/background/image 12.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          // 실제 컨텐츠만 SafeArea로 감싸기
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 120), // 앱바와 로고 사이 간격 줄임
                        _buildLogoSection(),
                        // 로고와 버튼 사이 간격 제거
                        AnimatedSwitcher(
                          duration: AppConstants.normalAnimation,
                          child: _buildLoginContent(),
                        ),
                      ],
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset(
          'assets/icons/logo.png',
          width: 333,
          height: 95,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 48), // 로고와 버튼 사이 간격
      ],
    );
  }

  Widget _buildLoginContent() {
    if (showLoginForm) {
      return _buildIdLoginForm();
    } else if (showPhoneForm) {
      return _buildPhoneLoginForm();
    } else {
      return _buildSocialLoginButtons();
    }
  }

  Widget _buildSocialLoginButtons() {
    return Container(
      key: const ValueKey('social_buttons'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ID Login Button
          _SocialLoginButton(
            icon: CupertinoIcons.person,
            text: '아이디 로그인',
            backgroundColor: Color(0xFF1D1D1D),
            borderColor: AppColors.textWhite.withValues(alpha: 0.3),
            textColor: AppColors.textWhite,
            onTap: () {
              setState(() {
                showLoginForm = true;
                showPhoneForm = false;
              });
            },
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Phone Login Button
          _SocialLoginButton(
            icon: CupertinoIcons.phone,
            text: '전화번호로 로그인',
            backgroundColor: Color(0xFF1D1D1D),
            borderColor: AppColors.textWhite.withValues(alpha: 0.3),
            textColor: AppColors.textWhite,
            onTap: () {
              setState(() {
                showPhoneForm = true;
                showLoginForm = false;
              });
            },
          ),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // Kakao Login
          _SocialLoginButton(
            iconAsset: 'assets/icons/kakao.png',
            text: '카카오로 로그인',
            backgroundColor: Color(0xFF1D1D1D),
            borderColor: AppColors.textWhite.withValues(alpha: 0.3),
            textColor: AppColors.textWhite,
            onTap: _loginWithKakao,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Naver Login
          _SocialLoginButton(
            iconAsset: 'assets/icons/naver.png',
            text: '네이버로 로그인',
            backgroundColor: Color(0xFF1D1D1D),
            borderColor: AppColors.textWhite.withValues(alpha: 0.3),
            textColor: AppColors.textWhite,
            onTap: _loginWithNaver,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Google Login
          _SocialLoginButton(
            iconAsset: 'assets/icons/google.png',
            text: '구글 로그인',
            backgroundColor: Color(0xFF1D1D1D),
            borderColor: AppColors.textWhite.withValues(alpha: 0.3),
            textColor: AppColors.textWhite,
            onTap: _loginWithGoogle,
          ),
          
          const SizedBox(height: 8), // 구글 로그인과 회원가입 버튼 사이 간격
        ],
      ),
    );
  }

  Widget _buildIdLoginForm() {
    final authState = ref.watch(enhancedAuthProvider);
    final isLoading = authState.isLoading;
    
    return Container(
      key: const ValueKey('id_form'),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Back Button
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showLoginForm = false;
                  });
                },
                icon: const Icon(
                  CupertinoIcons.back,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          
          // Login Form
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Column(
              children: [
                // ID Input
                TextField(
                  controller: _idController,
                  style: AppTextStyles.inputText,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: '아이디(이메일)를 입력해주세요',
                    hintStyle: AppTextStyles.inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing16),
                
                // Password Input
                TextField(
                  controller: _passwordController,
                  style: AppTextStyles.inputText,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: AppTextStyles.inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing24),
                
                // Login Button
                CustomButton(
                  text: isLoading ? '로그인 중...' : '로그인',
                  onPressed: isLoading ? null : _login,
                  style: CustomButtonStyle.gradient,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginForm() {
    return Container(
      key: const ValueKey('phone_form'),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Back Button
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showPhoneForm = false;
                  });
                },
                icon: const Icon(
                  CupertinoIcons.back,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          
          // Phone Form
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                Text(
                  '전화번호',
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing16),
                
                // Phone Input
                TextField(
                  controller: _phoneController,
                  style: AppTextStyles.inputText,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력해주세요',
                    hintStyle: AppTextStyles.inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing24),
                
                // Login Button
                CustomButton(
                  text: '로그인',
                  onPressed: _loginWithPhone,
                  style: CustomButtonStyle.gradient,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        bottom: AppDimensions.paddingL,
      ),
      child: Column(
        children: [
          // Footer Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _goToSignup,
                child: Text(
                  '회원가입',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 12,
                color: AppColors.textWhite.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                ),
              ),
              TextButton(
                onPressed: _findIdPassword,
                child: Text(
                  'ID/PW 찾기',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 56), // Copyright과의 간격 56px
          
          // Copyright
          Text(
            'Copyright Co.coco',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _loginWithKakao() async {
    try {
      final authNotifier = ref.read(enhancedAuthProvider.notifier);
      await authNotifier.signInWithSocial('KAKAO');
      
      final authState = ref.read(enhancedAuthProvider);
      if (authState.isSignedIn && mounted) {
        // 카카오 로그인 성공 시 PASS 본인인증으로 이동
        _navigateToMobileOKAPI('소셜로그인', {
          'socialProvider': 'KAKAO',
          'socialLoginData': authState.currentUser?.toJson(),
        });
      } else if (authState.error != null) {
        _showErrorSnackBar(authState.error!);
      }
    } catch (e) {
      _showErrorSnackBar('카카오 로그인 중 오류가 발생했습니다.');
    }
  }


  void _loginWithNaver() async {
    try {
      final authNotifier = ref.read(enhancedAuthProvider.notifier);
      await authNotifier.signInWithSocial('NAVER');
      
      final authState = ref.read(enhancedAuthProvider);
      if (authState.isSignedIn && mounted) {
        // 네이버 로그인 성공 시 PASS 본인인증으로 이동
        _navigateToMobileOKAPI('소셜로그인', {
          'socialProvider': 'NAVER',
          'socialLoginData': authState.currentUser?.toJson(),
        });
      } else if (authState.error != null) {
        _showErrorSnackBar(authState.error!);
      }
    } catch (e) {
      _showErrorSnackBar('네이버 로그인 중 오류가 발생했습니다.');
    }
  }

  void _loginWithGoogle() async {
    try {
      final authNotifier = ref.read(enhancedAuthProvider.notifier);
      await authNotifier.signInWithSocial('GOOGLE');
      
      final authState = ref.read(enhancedAuthProvider);
      if (authState.isSignedIn && mounted) {
        // 구글 로그인 성공 시 PASS 본인인증으로 이동
        _navigateToMobileOKAPI('소셜로그인', {
          'socialProvider': 'GOOGLE',
          'socialLoginData': authState.currentUser?.toJson(),
        });
      } else if (authState.error != null) {
        _showErrorSnackBar(authState.error!);
      }
    } catch (e) {
      _showErrorSnackBar('구글 로그인 중 오류가 발생했습니다.');
    }
  }

  void _loginWithPhone() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar('전화번호를 입력해주세요.');
      return;
    }
    
    // AWS Cognito 전화번호 로그인
    final authNotifier = ref.read(enhancedAuthProvider.notifier);
    final success = await authNotifier.signInWithPhone(phoneNumber);
    
    if (success) {
      // 전화번호 인증 화면으로 이동 필요
      _showErrorSnackBar('전화번호 인증 코드가 발송되었습니다.');
    } else {
      final authState = ref.read(enhancedAuthProvider);
      _showErrorSnackBar(authState.error ?? '전화번호 인증에 실패했습니다.');
    }
  }

  void _goToSignup() {
    // 약관 동의 페이지로 이동
    context.push(RouteNames.terms);
  }

  /// MobileOK API 본인인증 화면으로 이동
  void _navigateToMobileOKAPI(String purpose, Map<String, dynamic> additionalData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileOKAPIVerificationScreen(
          purpose: purpose,
          userId: ref.read(enhancedAuthProvider).currentUser?.user?.userId,
          additionalData: additionalData,
        ),
      ),
    );
  }

  void _findIdPassword() {
    context.push(RouteNames.forgotPassword);
  }

  void _login() async {
    final username = _idController.text.trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('아이디와 비밀번호를 입력해주세요.');
      return;
    }
    
    // AWS Cognito로 실제 로그인
    final authNotifier = ref.read(enhancedAuthProvider.notifier);
    final success = await authNotifier.signInWithCredentials(username, password);
    
    if (success && mounted) {
      // 사용자 프로바이더 초기화
      await _initializeUserProviders();
      
      // 실제 프로필 데이터 존재 여부 확인
      await _checkProfileAndNavigate();
    } else {
      // 로그인 실패 시 에러 메시지 표시
      final authState = ref.read(enhancedAuthProvider);
      final errorMessage = authState.error ?? '로그인에 실패했습니다.';
      
      // AWS Cognito 에러 메시지를 사용자 친화적으로 변환
      if (errorMessage.contains('UserNotFoundException')) {
        _showErrorSnackBar('존재하지 않는 아이디입니다.');
      } else if (errorMessage.contains('NotAuthorizedException')) {
        _showErrorSnackBar('아이디 또는 비밀번호가 올바르지 않습니다.');
      } else if (errorMessage.contains('UserNotConfirmedException')) {
        _showErrorSnackBar('이메일 인증이 필요합니다. 이메일을 확인해주세요.');
      } else {
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  /// 사용자 프로바이더 초기화
  Future<void> _initializeUserProviders() async {
    try {
      print('🔄 사용자 프로바이더 초기화 시작...');
      
      final userNotifier = ref.read(userProvider.notifier);
      await userNotifier.initializeUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ 사용자 프로필 로드 타임아웃');
        },
      );
      
      print('✅ 사용자 프로필 로드 완료');
      
      // 좋아요 데이터 초기화
      print('🔄 좋아요 데이터 로드 시작...');
      final likesNotifier = ref.read(likesProvider.notifier);
      await likesNotifier.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ 좋아요 데이터 로드 타임아웃');
        },
      );
      
      print('✅ 좋아요 데이터 로드 완료');
    } catch (e) {
      print('❌ 사용자 프로바이더 초기화 실패: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    );
  }

  /// 프로필 존재 여부를 확인하고 적절한 페이지로 이동
  Future<void> _checkProfileAndNavigate() async {
    try {
      // 현재 로그인한 사용자 정보 가져오기
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        print('사용자가 로그인되어 있지 않음');
        if (mounted) {
          context.pushReplacement(RouteNames.onboardingTutorial);
        }
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      print('프로필 확인 중... userId: $userId');

      // AWS에서 프로필 조회 (타임아웃 설정)
      final profileService = AWSProfileService();
      ProfileModel? profile;
      
      try {
        profile = await profileService.getProfileByUserId(userId).timeout(
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

      if (mounted) {
        if (profile != null) {
          // 프로필이 존재하면 홈으로
          print('프로필 존재 - 홈으로 이동: ${profile.name}');
          context.pushReplacement(RouteNames.home);
        } else {
          // 프로필이 없으면 온보딩으로
          print('프로필 없음 - 온보딩으로 이동');
          context.pushReplacement(RouteNames.onboardingTutorial);
        }
      }
    } catch (e) {
      print('프로필 확인 중 전체 오류: $e');
      
      // 오류 발생 시 SharedPreferences의 플래그로 대체 확인
      try {
        final prefs = await SharedPreferences.getInstance();
        final profileCreated = prefs.getBool('profile_created') ?? false;
        
        if (mounted) {
          if (profileCreated) {
            context.pushReplacement(RouteNames.home);
          } else {
            context.pushReplacement(RouteNames.onboardingTutorial);
          }
        }
      } catch (prefsError) {
        print('SharedPreferences 확인 중 오류: $prefsError');
        // 모든 방법이 실패하면 온보딩으로
        if (mounted) {
          context.pushReplacement(RouteNames.onboardingTutorial);
        }
      }
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String text;
  final Color backgroundColor;
  final Color? borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SocialLoginButton({
    this.icon,
    this.iconAsset,
    required this.text,
    required this.backgroundColor,
    this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppDimensions.socialButtonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.socialButtonRadius),
        child: Container(
          height: AppDimensions.socialButtonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.socialButtonRadius),
            border: borderColor != null 
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 아이콘을 왼쪽에 고정
              Positioned(
                left: 20,
                child: icon != null
                    ? Icon(
                        icon,
                        color: textColor,
                        size: AppDimensions.socialButtonIconSize,
                      )
                    : iconAsset != null
                        ? Image.asset(
                            iconAsset!,
                            width: AppDimensions.socialButtonIconSize,
                            height: AppDimensions.socialButtonIconSize,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                CupertinoIcons.circle,
                                color: textColor,
                                size: AppDimensions.socialButtonIconSize,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
              ),
              // 텍스트는 중앙에 배치
              Center(
                child: Text(
                  text,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}