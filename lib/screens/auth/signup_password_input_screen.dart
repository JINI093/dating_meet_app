import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../utils/auth_validators.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../models/signup_data.dart';

class SignupPasswordInputScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? signupData;
  
  const SignupPasswordInputScreen({
    super.key,
    this.signupData,
  });

  @override
  ConsumerState<SignupPasswordInputScreen> createState() => _SignupPasswordInputScreenState();
}

class _SignupPasswordInputScreenState extends ConsumerState<SignupPasswordInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isValidPassword = false;
  bool _isPasswordMatch = false;
  String? _errorMessage;
  PasswordStrengthResult? _passwordStrength;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String password) {
    setState(() {
      _passwordStrength = AuthValidators.validatePassword(password);
      _errorMessage = null;
    });
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (confirmPassword.isNotEmpty) {
      _isPasswordMatch = password == confirmPassword;
      if (!_isPasswordMatch) {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      } else if (_isValidPassword) {
        _errorMessage = null;
      }
    } else {
      _isPasswordMatch = false;
    }
  }

  Future<void> _createAccount() async {
    if (!_isValidPassword || !_isPasswordMatch) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signupData = widget.signupData ?? {};
      final userId = signupData['userId'] as String;
      final password = _passwordController.text.trim();
      final mobileOKVerification = signupData['mobileOKVerification'] as Map<String, dynamic>?;
      
      // PASS 인증 정보에서 전화번호와 이름 추출
      String? phoneNumber = mobileOKVerification?['phoneNumber'];
      String? name = mobileOKVerification?['name'];
      
      // 전화번호 형식 정리
      if (phoneNumber != null) {
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
        if (phoneNumber.length == 11 && phoneNumber.startsWith('010')) {
          phoneNumber = '+82${phoneNumber.substring(1)}';
        }
      }

      // AWS Cognito 회원가입
      final authNotifier = ref.read(enhancedAuthProvider.notifier);
      
      // SignupData 생성
      DateTime? birthDate;
      if (mobileOKVerification?['birthDate'] != null) {
        final birthDateStr = mobileOKVerification!['birthDate'] as String;
        if (birthDateStr.length == 8) {
          final year = int.parse(birthDateStr.substring(0, 4));
          final month = int.parse(birthDateStr.substring(4, 6));
          final day = int.parse(birthDateStr.substring(6, 8));
          birthDate = DateTime(year, month, day);
        }
      }
      
      final signupDataModel = SignupData(
        username: userId,
        email: userId,
        password: password,
        name: name ?? '',
        phoneNumber: phoneNumber ?? '',
        birthDate: birthDate,
        gender: mobileOKVerification?['gender'] ?? '',
        additionalInfo: {
          'mobileok_ci': mobileOKVerification?['ci'] ?? '',
          'mobileok_di': mobileOKVerification?['di'] ?? '',
          'mobileok_nation': mobileOKVerification?['nation'] ?? '',
        },
      );
      
      final result = await authNotifier.signUp(signupDataModel);

      if (result && mounted) {
        // 회원가입 성공 - 완료 안내 페이지로 이동
        final completeSignupData = {
          ...signupData,
          'password': password,
          'phoneNumber': phoneNumber,
          'name': name,
        };
        
        context.pushReplacement(
          RouteNames.signupCompleteInfo,
          extra: completeSignupData,
        );
      } else {
        // 회원가입 실패
        final authState = ref.read(enhancedAuthProvider);
        setState(() {
          _errorMessage = _getErrorMessage(authState.error);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String? error) {
    if (error == null) return '회원가입 중 오류가 발생했습니다.';
    
    if (error.contains('UsernameExistsException')) {
      return '이미 사용 중인 아이디입니다.';
    } else if (error.contains('InvalidPasswordException')) {
      return '비밀번호 형식이 올바르지 않습니다.';
    } else if (error.contains('InvalidParameterException')) {
      return '입력 정보가 올바르지 않습니다.';
    } else {
      return '회원가입 중 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 상단 검정 배너
          _buildTopBanner(),
          
          // 메인 컨텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // 제목
                  const Text(
                    '비밀번호 입력',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 설명
                  const Text(
                    '안전에 필요한 계정 비밀번호를 입력해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 입력 폼
                  _buildInputForm(),
                  
                  const Spacer(),
                  
                  // 하단 버튼
                  _buildBottomButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/join.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '비밀번호 입력',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: '영문+숫자 포함 8자 이상',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              final result = AuthValidators.validatePassword(value ?? '');
              if (!result.isValid) {
                return null; // validator에서는 null 반환하고 별도 에러 메시지 표시
              }
              return null;
            },
            onChanged: (value) {
              final result = AuthValidators.validatePassword(value);
              setState(() {
                _passwordStrength = result;
                _isValidPassword = result.isValid;
                _errorMessage = result.isValid ? null : result.message;
                _checkPasswordMatch();
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '비밀번호 확인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: '비밀번호 확인',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return null; // validator에서는 null 반환하고 별도 에러 메시지 표시
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _checkPasswordMatch();
              });
            },
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordStrength == null) return const SizedBox.shrink();
    
    Color strengthColor;
    switch (_passwordStrength!.strength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: strengthColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _passwordStrength!.isValid ? Icons.check_circle : Icons.info_outline,
                color: strengthColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _passwordStrength!.message,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (_passwordStrength!.details.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...(_passwordStrength!.details.map((detail) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text(
                '• $detail',
                style: TextStyle(
                  color: strengthColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ))),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: (_isValidPassword && _isPasswordMatch) ? Colors.blue : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _isLoading ? '회원가입 중...' : '회원가입 완료',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}