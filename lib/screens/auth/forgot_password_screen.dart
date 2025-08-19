import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/pass_verification_service.dart';
import '../../providers/user_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _passVerified = false;
  String? _errorMessage;
  String? _successMessage;
  String? _verifiedUserId;
  String? _verifiedUserName;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
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
          '비밀번호 재설정',
          style: AppTextStyles.h6.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 컨텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // 제목
                  Text(
                    '본인 인증',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing16),
                  
                  // 설명
                  Text(
                    '비밀번호를 재설정하기 위해\n본인 인증이 필요해요.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing32),
                  
                  // 에러 메시지
                  if (_errorMessage != null) _buildErrorMessage(),
                  
                  // 성공 메시지
                  if (_successMessage != null) _buildSuccessMessage(),
                  
                  // 단계별 화면
                  if (!_passVerified) 
                    _buildPassVerificationStep()
                  else 
                    _buildPasswordResetStep(),
                    
                  // 로딩 표시
                  if (_isLoading) _buildLoadingIndicator(),
                ],
              ),
            ),
          ),
          
          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: SafeArea(
              child: CustomButton(
                text: _isLoading 
                    ? (_passVerified ? '비밀번호 변경 중...' : '본인 인증 중...') 
                    : (_passVerified ? '비밀번호 변경 완료' : '본인 인증 시작하기'),
                onPressed: _isLoading ? null : (_passVerified ? _resetPassword : _startPassVerification),
                style: CustomButtonStyle.primary,
                size: CustomButtonSize.large,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassVerificationStep() {
    return Container();
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            'PASS 본인인증을 진행하고 있습니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인증 완료 안내
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          margin: const EdgeInsets.only(bottom: AppDimensions.spacing24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Text(
                  '$_verifiedUserName님 본인인증이 완료되었습니다.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
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

  // PASS 본인인증 시작
  Future<void> _startPassVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final passService = PassVerificationService();
      final result = await passService.startDirectPassVerification(
        context: context,
        purpose: '비밀번호 재설정',
      );

      if (result.success) {
        // PASS 인증 성공
        final userName = result.name;
        if (userName != null) {
          // 사용자 이름으로 실제 ID를 찾아야 하지만, 현재는 시뮬레이션
          final userId = await _findUserIdByName(userName);
          if (userId != null) {
            setState(() {
              _isLoading = false;
              _passVerified = true;
              _verifiedUserName = userName;
              _verifiedUserId = userId;
            });
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = '$userName님으로 가입된 계정을 찾을 수 없습니다.';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = '본인인증에서 이름 정보를 가져올 수 없습니다.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? '본인인증에 실패했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '본인인증 중 오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  // 이름으로 사용자 ID 찾기 (실제 구현에서는 서버 API 호출)
  Future<String?> _findUserIdByName(String userName) async {
    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 1));
      
      // 테스트용 더미 데이터
      final Map<String, String> userNameToId = {
        '테스트사용자': 'test_user123',
        '홍길동': 'hong_gildong',
        '김철수': 'kim_chulsoo',
        '이영희': 'lee_younghee',
      };
      
      return userNameToId[userName];
    } catch (e) {
      print('사용자 ID 찾기 오류: $e');
      return null;
    }
  }

  // 비밀번호 재설정
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
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
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 2));
      
      // 시뮬레이션: 항상 성공
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
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '비밀번호 변경 중 오류가 발생했습니다. 다시 시도해주세요.';
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
}