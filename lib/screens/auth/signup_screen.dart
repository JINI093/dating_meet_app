import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../models/signup_data.dart';
import '../../utils/auth_validators.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'terms_screen.dart';
import 'phone_verification_screen.dart';

enum SignupStep {
  terms,
  idInput,
  passwordInput,
  phoneVerification,
  complete,
}

class SignupScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? mobileOKVerification;
  final Map<String, dynamic>? additionalData;
  
  const SignupScreen({
    super.key,
    this.mobileOKVerification,
    this.additionalData,
  });

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  SignupStep currentStep = SignupStep.terms;
  PageController pageController = PageController();
  
  // Form controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Validation states
  String? _idError;
  String? _passwordError;
  bool _isIdValid = false;
  bool _isPasswordValid = false;
  bool _canProceedToPassword = false;
  bool isLoading = false;
  
  
  // MobileOK verification data
  Map<String, dynamic>? _mobileOKData;

  @override
  void initState() {
    super.initState();
    
    // 새로운 회원가입 플로우: 약관 동의 → PASS 인증 → 아이디/비밀번호 입력
    if (widget.additionalData != null) {
      final passResult = widget.additionalData!['passResult'];
      final agreedTerms = widget.additionalData!['agreedTerms'];
      
      if (passResult != null) {
        // PASS 인증 결과를 mobileOKData로 저장
        _mobileOKData = {
          'name': passResult.name,
          'phoneNumber': passResult.phoneNumber,
          'birthDate': passResult.birthDate,
          'gender': passResult.gender,
          'ci': passResult.ci,
          'di': passResult.di,
          'agreedTerms': agreedTerms,
        };
        
        // 바로 아이디 입력 단계부터 시작
        currentStep = SignupStep.idInput;
        
        // PASS 인증 데이터로 필드 미리 채우기
        if (passResult.name != null) {
          _nameController.text = passResult.name!;
        }
        if (passResult.phoneNumber != null) {
          _phoneController.text = passResult.phoneNumber!;
        }
      }
    }
    // 기존 MobileOK 인증 데이터가 있으면 바로 아이디 입력 단계부터 시작 (이전 버전 호환성)
    else if (widget.mobileOKVerification != null) {
      _mobileOKData = widget.mobileOKVerification;
      currentStep = SignupStep.idInput;
      
      // MobileOK 인증 데이터로 필드 미리 채우기
      if (_mobileOKData!['name'] != null) {
        _nameController.text = _mobileOKData!['name'];
      }
      if (_mobileOKData!['phoneNumber'] != null) {
        _phoneController.text = _mobileOKData!['phoneNumber'];
      }
    }
    
    // 텍스트 컨트롤러에 리스너 추가
    _idController.addListener(_updateCanProceedToPassword);
    _nameController.addListener(_updateCanProceedToPassword);
    _phoneController.addListener(_updateCanProceedToPassword);
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: _handleBackPressed,
          ),
          title: Text(
            _mobileOKData != null ? '계정 생성' : '회원가입',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildIdInputScreen(),
              _buildPasswordInputScreen(),
              _buildCompleteScreen(),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleBackPressed() {
    // 항상 로그인 페이지로 이동
    context.go(RouteNames.login);
  }

  Widget _buildTermsScreen() {
    return Column(
      children: [
        // Header
        _buildHeader('이용약관 동의'),
        
        // Terms Button
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacing8),
                          child: const Icon(
                            CupertinoIcons.heart_fill,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        ),
                        Positioned(
                          top: -8,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              CupertinoIcons.heart_fill,
                              color: AppColors.textWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: AppDimensions.spacing12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing16,
                        vertical: AppDimensions.spacing8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      ),
                      child: Text(
                        '사랑해',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.spacing48),
                
                Text(
                  '서비스 이용을 위해\n약관 동의가 필요합니다',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppDimensions.spacing16),
                
                Text(
                  '안전하고 신뢰할 수 있는 서비스를 위해\n필요한 약관들을 확인해주세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Button
        _buildBottomButton(
          text: '약관 확인하기',
          isEnabled: true,
          onPressed: _handleTermsAgreement,
        ),
      ],
    );
  }

  Widget _buildIdInputScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              IconButton(onPressed: _goBack, icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: AppDimensions.iconM,)),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VIP Banner
                _buildVipBanner(),
                
                const SizedBox(height: AppDimensions.spacing32),
                
                // Title
                Text(
                  '아이디 입력',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing8),
                
                // Subtitle
                Text(
                  '로그인에 필요한 아이디를 입력해주세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing32),
                
                // Name Input Section
                Text(
                  '이름',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                CustomTextField(
                  controller: _nameController,
                  hintText: '이름을 입력해주세요',
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: AppDimensions.spacing24),
                
                // ID Input Section
                Text(
                  '아이디 (이메일)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                CustomTextField(
                  controller: _idController,
                  hintText: '이메일을 입력해주세요',
                  errorText: _idError,
                  onChanged: _validateId,
                  textInputAction: TextInputAction.next,
                ),
                
                if (_idError != null) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    _idError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                
                const SizedBox(height: AppDimensions.spacing24),
                
                // Phone Number Input Section
                Text(
                  '전화번호',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                CustomTextField(
                  controller: _phoneController,
                  hintText: '010-1234-5678',
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
        
        // Bottom Button
        _buildBottomButton(
          text: '다음',
          isEnabled: _canProceedToPassword,
          onPressed: _canProceedToPassword ? _goToPasswordInput : null,
        ),
      ],
    );
  }

  Widget _buildPasswordInputScreen() {
    return Column(
      children: [
        // Header
        _buildHeader('비밀번호 입력'),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VIP Banner
                _buildVipBanner(),
                
                const SizedBox(height: AppDimensions.spacing32),
                
                // Title
                Text(
                  '비밀번호 입력',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing8),
                
                // Subtitle
                Text(
                  '이용에 필요한 계정 비밀번호를 입력해주세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing8),
                
                // Password requirements hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비밀번호 요구사항:',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• 8자 이상\n• 영문 대문자 포함 (A-Z)\n• 영문 소문자 포함 (a-z)\n• 숫자 포함 (0-9)\n• 특수문자 포함 (!@#\$%^&*)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '예시: Password123!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing32),
                
                // Password Input Section
                Text(
                  '비밀번호 입력',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                CustomTextField(
                  controller: _passwordController,
                  hintText: '영문 대소문자+숫자+특수문자 포함 8자 이상',
                  type: CustomTextFieldType.password,
                  onChanged: _validatePassword,
                  textInputAction: TextInputAction.next,
                  errorText: _passwordError,
                ),
                
                const SizedBox(height: AppDimensions.spacing12),
                
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: '비밀번호 확인',
                  type: CustomTextFieldType.password,
                  onChanged: _validatePasswordConfirm,
                  textInputAction: TextInputAction.done,
                ),
                
                if (_passwordError != null) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    _passwordError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                
                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
        
        // Bottom Button
        _buildBottomButton(
          text: '회원가입 완료',
          isEnabled: _isPasswordValid,
          onPressed: _isPasswordValid ? _completeSignup : null,
        ),
      ],
    );
  }

  Widget _buildCompleteScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Row(
            children: [
              IconButton(onPressed: _goBack, icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: AppDimensions.iconM,)),
            ],
          ),
        ),
        // Content
        Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  ],
                ),
                // Title
                Text(
                  '회원가입 완료!',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacing16),
                
                // Description
                Column(
                  children: [
                    Text(
                      '회원가입이 완료되었습니다!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '완벽한 MEET이용을 위하여',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '본인 프로필 등록 화면으로 이동합니다',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        // Bottom Button
        _buildBottomButton(
          text: '프로필 작성하기',
          isEnabled: true,
          onPressed: _goToProfileSetup,
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacing12,
      ),
      child: Row(
        children: [
          if (currentStep != SignupStep.complete && currentStep != SignupStep.terms)
            IconButton(
              onPressed: _goBack,
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
                size: AppDimensions.iconM,
              ),
            ),
          if (currentStep == SignupStep.complete || currentStep == SignupStep.terms)
            const SizedBox(width: AppDimensions.iconM + 16),
          
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.appBarTitle,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: AppDimensions.iconM + 16),
        ],
      ),
    );
  }

Widget _buildVipBanner() {
  return Container(
    padding: const EdgeInsets.all(AppDimensions.paddingM),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF000000), Color(0xFF666666)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 그라데이션 텍스트
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFD900), Color(0xFFFC9E05)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  '설레는 만남의 시작 사귈래',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white, // 실제 색상은 shader로 대체됨
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing8),
              
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '사귈래는 ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                      ),
                    ),
                    TextSpan(
                      text: '철저한 본인인증',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '으로',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing4),
              
              Text(
                '믿을 수 있는 서비스를 제공해 드리고 있습니다.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        Image.asset(
          'assets/icons/certi 1.png',
          width: 48,
          height: 48,
        ),
      ],
    ),
  );
}

  Widget _buildBottomButton({
    required String text,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: CustomButton(
        text: text,
        onPressed: onPressed,
        style: CustomButtonStyle.primary,
        size: CustomButtonSize.large,
        width: double.infinity,
      ),
    );
  }

  // Validation Methods
  void _validateId(String value) {
    setState(() {
      if (value.isEmpty) {
        _idError = '아이디를 입력해주세요';
        _isIdValid = false;
      } else if (value.length < 4) {
        _idError = '아이디는 4자 이상이어야 합니다';
        _isIdValid = false;
      } else if (value == '이미 사용중인 아이디입니다') {
        _idError = '이미 사용중인 아이디입니다';
        _isIdValid = false;
      } else {
        _idError = null;
        _isIdValid = true;
      }
      _updateCanProceedToPassword();
    });
  }
  
  void _updateCanProceedToPassword() {
    setState(() {
      _canProceedToPassword = _isIdValid && 
                             _nameController.text.isNotEmpty && 
                             _phoneController.text.isNotEmpty;
    });
  }

  void _validatePassword(String value) {
    _validatePasswordMatch();
  }

  void _validatePasswordConfirm(String value) {
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      
      if (password.isEmpty) {
        _passwordError = '비밀번호를 입력해주세요';
        _isPasswordValid = false;
      } else {
        // AuthValidators를 사용하여 비밀번호 검증
        final validationResult = AuthValidators.validatePassword(password);
        
        if (!validationResult.isValid) {
          // 검증 실패한 요구사항들을 사용자 친화적으로 표시
          if (validationResult.details.isNotEmpty) {
            _passwordError = '필요사항: ${validationResult.details.join(', ')}';
          } else {
            _passwordError = validationResult.message;
          }
          _isPasswordValid = false;
        } else if (confirmPassword.isNotEmpty && password != confirmPassword) {
          _passwordError = '비밀번호가 일치하지 않습니다';
          _isPasswordValid = false;
        } else if (confirmPassword.isNotEmpty && password == confirmPassword) {
          _passwordError = null;
          _isPasswordValid = true;
        } else {
          _passwordError = null;
          _isPasswordValid = true; // 비밀번호만으로도 유효성 확인 완료
        }
      }
    });
  }

  bool _hasLetterAndNumber(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  // Navigation Methods
  void _goBack() {
    if (currentStep == SignupStep.idInput) {
      setState(() {
        currentStep = SignupStep.terms;
      });
      pageController.previousPage(
        duration: AppConstants.normalAnimation,
        curve: Curves.easeInOut,
      );
    } else if (currentStep == SignupStep.passwordInput) {
      setState(() {
        currentStep = SignupStep.idInput;
      });
      pageController.previousPage(
        duration: AppConstants.normalAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToIdInput() {
    setState(() {
      currentStep = SignupStep.idInput;
    });
    pageController.nextPage(
      duration: AppConstants.normalAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _goToPasswordInput() {
    setState(() {
      currentStep = SignupStep.passwordInput;
    });
    pageController.nextPage(
      duration: AppConstants.normalAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _completeSignup() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Amplify는 이제 앱 시작 시 동기적으로 초기화되므로 확인만 함
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다. 앱을 다시 시작해주세요.');
      }
      
      // 실제 사용자 입력 데이터
      final testEmail = _idController.text.trim();
      final testPassword = _passwordController.text;
      final testName = _nameController.text.trim();
      
      print('=== 회원가입 디버깅 정보 ===');
      print('이메일: $testEmail');
      print('비밀번호 길이: ${testPassword.length}');
      print('이름: $testName');
      print('===========================');
      
      // Enhanced Auth Provider를 사용하여 실제 AWS 사용자 생성
      final testPhone = _phoneController.text.trim();
      
      // MobileOK 데이터가 있으면 우선 사용, 없으면 입력값 사용
      final finalName = _mobileOKData?['name'] ?? testName;
      final finalPhone = _mobileOKData?['phoneNumber'] ?? testPhone;
      
      final signupData = SignupData(
        username: testName, // 사용자명으로 이름 사용
        email: testEmail,
        password: testPassword,
        name: finalName,
        phoneNumber: finalPhone.isNotEmpty ? finalPhone : null,
      );
      
      final success = await ref.read(enhancedAuthProvider.notifier).signUp(signupData);
      print('회원가입 최종 결과: $success');
      
      if (success) {
        setState(() {
          currentStep = SignupStep.complete;
          isLoading = false;
        });
        
        // 이메일 인증이 필요한 경우 사용자에게 알림
        final authState = ref.read(enhancedAuthProvider);
        if (authState.error != null && authState.error!.contains('이메일 인증')) {
          _showSuccessDialog('회원가입이 완료되었습니다!', authState.error!);
        } else {
          // 회원가입 완료 후 바로 프로필 설정으로 이동
          final signupData = {
            'username': _idController.text.trim(),
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'mobileOKVerification': _mobileOKData, // MobileOK 인증 데이터 포함
          };
          
          if (mounted) {
            context.go(RouteNames.profileSetup, extra: signupData);
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // Enhanced Auth Provider의 에러 메시지 사용
        final authState = ref.read(enhancedAuthProvider);
        final errorMessage = authState.error ?? '회원가입에 실패했습니다. 다시 시도해주세요.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('회원가입 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  bool _validateAllFields() {
    if (_idController.text.isEmpty) {
      _showErrorDialog('이메일을 입력해주세요.');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorDialog('비밀번호를 입력해주세요.');
      return false;
    }
    if (_nameController.text.isEmpty) {
      _showErrorDialog('이름을 입력해주세요.');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showErrorDialog('전화번호를 입력해주세요.');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 완료 화면으로 이동
              pageController.nextPage(
                duration: AppConstants.normalAnimation,
                curve: Curves.easeInOut,
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }


  void _goToProfileSetup() {
    // 회원가입 시 입력한 데이터를 프로필 설정으로 전달
    final signupData = {
      'username': _idController.text.trim(),
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };
    
    context.go(RouteNames.profileSetup, extra: signupData);
  }

  // Terms Agreement Handler
  void _handleTermsAgreement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsScreen(),
      ),
    );

    if (result != null && result is Map<String, bool>) {
      _goToIdInput();
    }
  }
}