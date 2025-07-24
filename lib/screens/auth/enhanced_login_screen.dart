import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../services/multi_auth_service.dart';
import '../../services/aws_profile_service.dart';
import '../../widgets/dialogs/info_dialog.dart';
import '../../models/auth_result.dart';

enum LoginMethod { idPassword, phone, social }

class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen>
    with TickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;
  
  // 로그인 방식
  LoginMethod _currentMethod = LoginMethod.idPassword;
  
  // 컨트롤러들
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  
  // 상태 변수들
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberLogin = false;
  bool _useBiometric = false;
  String? _errorMessage;
  String? _verificationId;
  String _selectedCountryCode = '+82';
  
  // 생체 인증
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  
  // MultiAuthService
  final MultiAuthService _authService = MultiAuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeBiometric();
    _loadLoginPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  // 생체 인증 초기화
  Future<void> _initializeBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      print('생체 인증 초기화 오류: $e');
    }
  }

  // 로그인 설정 로드
  Future<void> _loadLoginPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberLogin = prefs.getBool('remember_login') ?? false;
        _useBiometric = prefs.getBool('use_biometric') ?? false;
      });
    } catch (e) {
      print('설정 로드 오류: $e');
    }
  }

  // 로그인 설정 저장
  Future<void> _saveLoginPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_login', _rememberLogin);
      await prefs.setBool('use_biometric', _useBiometric);
    } catch (e) {
      print('설정 저장 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 배경 이미지
          _buildBackground(),
          
          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                _buildLogoSection(),
                Expanded(
                  child: _buildMainContent(),
                ),
                _buildFooter(),
              ],
            ),
          ),
          
          // 로딩 오버레이
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
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
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'assets/icons/logo.png',
        width: 300,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        children: [
          // 로그인 방식 선택 탭
          _buildLoginMethodTabs(),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIdPasswordLogin(),
                _buildPhoneLogin(),
                _buildSocialLogin(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginMethodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        labelColor: AppColors.textWhite,
        unselectedLabelColor: AppColors.textWhite.withValues(alpha: 0.7),
        labelStyle: AppTextStyles.buttonMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.buttonMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '아이디/비밀번호'),
          Tab(text: '전화번호'),
          Tab(text: '소셜 로그인'),
        ],
        onTap: (index) {
          setState(() {
            _currentMethod = LoginMethod.values[index];
            _errorMessage = null;
          });
        },
      ),
    );
  }

  Widget _buildIdPasswordLogin() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 에러 메시지
          if (_errorMessage != null) _buildErrorMessage(),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // 아이디 입력
          TextField(
            controller: _idController,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: '아이디를 입력해주세요',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(
                CupertinoIcons.person,
                color: AppColors.textWhite,
              ),
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
          
          // 비밀번호 입력
          TextField(
            controller: _passwordController,
            style: AppTextStyles.inputText,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: '비밀번호를 입력해주세요',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(
                CupertinoIcons.lock,
                color: AppColors.textWhite,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible
                      ? CupertinoIcons.eye_slash
                      : CupertinoIcons.eye,
                  color: AppColors.textWhite,
                ),
              ),
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
          
          // 로그인 설정
          _buildLoginSettings(),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 로그인 버튼
          CustomButton(
            text: '로그인',
            onPressed: _isLoading ? null : _loginWithIdPassword,
            style: CustomButtonStyle.gradient,
            size: CustomButtonSize.large,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLogin() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 에러 메시지
          if (_errorMessage != null) _buildErrorMessage(),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // 국가 코드 선택
          Row(
            children: [
              // 국가 코드 드롭다운
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  dropdownColor: AppColors.background,
                  style: AppTextStyles.inputText,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: '+82', child: Text('🇰🇷 +82')),
                    DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                    DropdownMenuItem(value: '+81', child: Text('🇯🇵 +81')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing12),
              
              // 전화번호 입력
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  style: AppTextStyles.inputText,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력해주세요',
                    hintStyle: AppTextStyles.inputHint,
                    prefixIcon: const Icon(
                      CupertinoIcons.phone,
                      color: AppColors.textWhite,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 로그인 설정
          _buildLoginSettings(),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 로그인 버튼
          CustomButton(
            text: _verificationId == null ? '인증번호 받기' : '인증번호 확인',
            onPressed: _isLoading ? null : _handlePhoneLogin,
            style: CustomButtonStyle.gradient,
            size: CustomButtonSize.large,
            width: double.infinity,
          ),
          
          // SMS 코드 입력 (인증번호 발송 후 표시)
          if (_verificationId != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            TextField(
              controller: _smsCodeController,
              style: AppTextStyles.inputText,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '인증번호 6자리를 입력해주세요',
                hintStyle: AppTextStyles.inputHint,
                prefixIcon: const Icon(
                  CupertinoIcons.number,
                  color: AppColors.textWhite,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                counterText: '',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 에러 메시지
          if (_errorMessage != null) _buildErrorMessage(),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 로그인 설정
          _buildLoginSettings(),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          // 구글 로그인 버튼 (Google 브랜딩 가이드 준수)
          _buildGoogleLoginButton(),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // 카카오 로그인 버튼 (카카오 브랜딩 가이드 준수)
          _buildKakaoLoginButton(),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // 네이버 로그인 버튼 (네이버 브랜딩 가이드 준수)
          _buildNaverLoginButton(),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _loginWithGoogle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/google.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 20,
                  );
                },
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                'Google로 로그인',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoLoginButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE500),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _loginWithKakao,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/kakao.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.chat_bubble,
                    color: Color(0xFF3C1E1E),
                    size: 20,
                  );
                },
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                '카카오로 로그인',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: const Color(0xFF3C1E1E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNaverLoginButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF03C75A),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _loginWithNaver,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                             Image.asset(
                 'assets/icons/naver.png',
                 width: 20,
                 height: 20,
                 errorBuilder: (context, error, stackTrace) {
                   return const Icon(
                     Icons.account_circle,
                     color: Colors.white,
                     size: 20,
                   );
                 },
               ),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                '네이버로 로그인',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSettings() {
    return Column(
      children: [
        // 로그인 상태 유지
        Row(
          children: [
            Checkbox(
              value: _rememberLogin,
              onChanged: (value) {
                setState(() {
                  _rememberLogin = value ?? false;
                });
                _saveLoginPreferences();
              },
              activeColor: AppColors.primary,
            ),
            Text(
              '로그인 상태 유지',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        
        // 생체 인증 (사용 가능한 경우에만 표시)
        if (_isBiometricAvailable) ...[
          Row(
            children: [
              Checkbox(
                value: _useBiometric,
                onChanged: (value) {
                  setState(() {
                    _useBiometric = value ?? false;
                  });
                  _saveLoginPreferences();
                },
                activeColor: AppColors.primary,
              ),
              Text(
                '생체 인증 사용',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.red,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: const Icon(
              CupertinoIcons.xmark,
              color: Colors.red,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
          
          const SizedBox(height: AppDimensions.spacing8),
          
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

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // 로그인 처리 메서드들
  Future<void> _loginWithIdPassword() async {
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '아이디와 비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithCredentials(
        _idController.text,
        _passwordController.text,
      );

      if (result.isSuccess) {
        await _handleSuccessfulLogin(result);
      } else {
        setState(() {
          _errorMessage = result.error ?? '로그인에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = '전화번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      
      if (_verificationId == null) {
        // SMS 인증번호 발송
        final result = await _authService.signInWithPhoneNumber(phoneNumber);
        
        if (result.success) {
          setState(() {
            _verificationId = result.user?.userId;
          });
        } else if (result.isSuccess) {
          await _handleSuccessfulLogin(result);
        } else {
          setState(() {
            _errorMessage = result.error ?? '인증번호 발송에 실패했습니다.';
          });
        }
      } else {
        // SMS 인증번호 확인
        if (_smsCodeController.text.isEmpty) {
          setState(() {
            _errorMessage = '인증번호를 입력해주세요.';
          });
          return;
        }

        final result = await _authService.verifyPhoneCode(
          _verificationId!,
          _smsCodeController.text,
        );

        if (result.isSuccess) {
          await _handleSuccessfulLogin(result);
        } else {
          setState(() {
            _errorMessage = result.error ?? '인증번호가 올바르지 않습니다.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '전화번호 인증 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();
      
      if (result.isSuccess) {
        await _handleSuccessfulLogin(result);
      } else {
        setState(() {
          _errorMessage = result.error ?? '구글 로그인에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '구글 로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithKakao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithKakao();
      
      if (result.isSuccess) {
        await _handleSuccessfulLogin(result);
      } else {
        setState(() {
          _errorMessage = result.error ?? '카카오 로그인에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '카카오 로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithNaver() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithNaver();
      
      if (result.isSuccess) {
        await _handleSuccessfulLogin(result);
      } else {
        setState(() {
          _errorMessage = result.error ?? '네이버 로그인에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네이버 로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSuccessfulLogin(AuthResult result) async {
    // 생체 인증 설정이 되어 있다면 생체 인증 시도
    if (_useBiometric && _isBiometricAvailable) {
      final authenticated = await _authenticateWithBiometric();
      if (!authenticated) {
        setState(() {
          _errorMessage = '생체 인증에 실패했습니다.';
        });
        return;
      }
    }

    // 로그인 성공 처리
    await _saveLoginPreferences();
    
    // TODO: 서버에서 첫 로그인 여부 확인 구현 필요
    // 현재는 프로필 설정 여부로 판단
    bool isFirstLogin = await _checkIfFirstLogin();
    
    if (mounted) {
      if (isFirstLogin) {
        context.go(RouteNames.onboardingTutorial);
      } else {
        context.go(RouteNames.home);
      }
    }
  }

  Future<bool> _checkIfFirstLogin() async {
    try {
      // 실제 AWS에서 프로필 존재 여부 확인
      final multiAuthService = MultiAuthService();
      final currentUser = await multiAuthService.getCurrentUser();
      
      if (currentUser?.user?.userId != null) {
        final profileService = AWSProfileService();
        final profile = await profileService.getProfileByUserId(currentUser!.user!.userId);
        
        // 프로필이 없으면 첫 로그인으로 판단
        return profile == null;
      }
      
      // 사용자 정보가 없으면 SharedPreferences로 대체 확인
      final prefs = await SharedPreferences.getInstance();
      final profileCreated = prefs.getBool('profile_created') ?? false;
      return !profileCreated;
      
    } catch (e) {
      print('프로필 존재 여부 확인 중 오류: $e');
      
      // 오류 발생 시 SharedPreferences로 대체 확인
      try {
        final prefs = await SharedPreferences.getInstance();
        final profileCreated = prefs.getBool('profile_created') ?? false;
        return !profileCreated;
      } catch (prefsError) {
        // 모든 방법이 실패하면 첫 로그인으로 처리
        return true;
      }
    }
  }

  Future<bool> _authenticateWithBiometric() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: '로그인을 위해 생체 인증을 진행합니다.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('생체 인증 오류: $e');
      return false;
    }
  }

  void _goToSignup() {
    context.push(RouteNames.signup);
  }

  void _findIdPassword() {
    // TODO: ID/PW 찾기 화면으로 이동
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(
        title: 'ID/PW 찾기',
        message: 'ID/PW 찾기 기능은 준비 중입니다.',
      ),
    );
  }
} 