import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/aws_cognito_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // AWS Cognito Service
  final AWSCognitoService _cognitoService = AWSCognitoService();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'ID/PW 찾기',
          style: AppTextStyles.h6.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacing24),
            
            // 제목
            Text(
              '비밀번호 재설정',
              style: AppTextStyles.h4.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing8),
            
            // 설명
            Text(
              '아이디를 입력하여 비밀번호를 재설정하세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing32),
            
            // 에러 메시지
            if (_errorMessage != null) _buildErrorMessage(),
            
            // 성공 메시지
            if (_successMessage != null) _buildSuccessMessage(),
            
            // 단계별 화면
            if (!_codeSent) 
              _buildEmailStep()
            else 
              _buildPasswordResetStep(),
            
            const SizedBox(height: AppDimensions.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이디 레이블
        Text(
          '아이디',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        // 아이디 입력 필드
        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '아이디를 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              CupertinoIcons.person,
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing32),
        
        // 인증번호 받기 버튼
        CustomButton(
          text: _isLoading ? '확인 중...' : '인증번호 받기',
          onPressed: _isLoading ? null : _sendResetCode,
          style: CustomButtonStyle.dark,
          size: CustomButtonSize.large,
          width: double.infinity,
        ),
        
        const SizedBox(height: AppDimensions.spacing16),
        
        // 안내 텍스트
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: Colors.blue[600],
                size: 16,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Expanded(
                child: Text(
                  '등록된 이메일로 인증번호가 발송됩니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인증 코드 입력
        Text(
          '인증 코드',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        TextField(
          controller: _codeController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '6자리 인증 코드를 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
            counterText: '',
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing24),
        
        // 새 비밀번호 입력
        Text(
          '새 비밀번호',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        TextField(
          controller: _newPasswordController,
          enabled: !_isLoading,
          obscureText: !_isNewPasswordVisible,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '새 비밀번호를 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
              icon: Icon(
                _isNewPasswordVisible
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                color: Colors.grey[600],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing16),
        
        // 비밀번호 확인
        Text(
          '비밀번호 확인',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        TextField(
          controller: _confirmPasswordController,
          enabled: !_isLoading,
          obscureText: !_isConfirmPasswordVisible,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '비밀번호를 다시 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              icon: Icon(
                _isConfirmPasswordVisible
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                color: Colors.grey[600],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing32),
        
        // 비밀번호 재설정 버튼
        CustomButton(
          text: _isLoading ? '변경 중...' : '비밀번호 변경 완료',
          onPressed: _isLoading ? null : _resetPassword,
          style: CustomButtonStyle.dark,
          size: CustomButtonSize.large,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
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

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Expanded(
            child: Text(
              _successMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.green,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _successMessage = null;
              });
            },
            icon: const Icon(
              CupertinoIcons.xmark,
              color: Colors.green,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // 비밀번호 재설정 코드 발송
  Future<void> _sendResetCode() async {
    final userId = _emailController.text.trim();
    
    if (userId.isEmpty) {
      setState(() {
        _errorMessage = '아이디를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _cognitoService.resetPassword(userId);
      
      if (result.success) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
          _successMessage = '인증 코드가 이메일로 발송되었습니다.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? '인증 코드 발송에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  // 비밀번호 재설정
  Future<void> _resetPassword() async {
    final userId = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '인증 코드를 입력해주세요.';
      });
      return;
    }
    
    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = '새 비밀번호를 입력해주세요.';
      });
      return;
    }
    
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }
    
    if (!_isValidPassword(newPassword)) {
      setState(() {
        _errorMessage = '비밀번호는 8자 이상, 대소문자, 숫자, 특수문자를 포함해야 합니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _cognitoService.confirmResetPassword(
        email: userId,
        confirmationCode: code,
        newPassword: newPassword,
      );
      
      if (result.success) {
        setState(() {
          _isLoading = false;
          _successMessage = '비밀번호가 성공적으로 변경되었습니다.';
        });
        
        // 2초 후 로그인 화면으로 이동
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? '비밀번호 변경에 실패했습니다.';
        });
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }


  bool _isValidPassword(String password) {
    // 8자 이상, 대문자, 소문자, 숫자, 특수문자 포함
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  String _getErrorMessage(String error) {
    if (error.contains('UserNotFoundException')) {
      return '등록되지 않은 이메일입니다.';
    } else if (error.contains('CodeMismatchException')) {
      return '인증 코드가 올바르지 않습니다.';
    } else if (error.contains('ExpiredCodeException')) {
      return '인증 코드가 만료되었습니다. 다시 시도해주세요.';
    } else if (error.contains('InvalidPasswordException')) {
      return '비밀번호가 정책에 맞지 않습니다.';
    } else if (error.contains('LimitExceededException')) {
      return '시도 횟수를 초과했습니다. 잠시 후 다시 시도해주세요.';
    } else {
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}