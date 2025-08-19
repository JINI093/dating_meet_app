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

class FindIdScreen extends ConsumerStatefulWidget {
  const FindIdScreen({super.key});

  @override
  ConsumerState<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends ConsumerState<FindIdScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _foundId;
  String? _foundUserName;
  bool _isResettingPassword = false;
  
  // 비밀번호 재설정 필드
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
          'ID/PW 찾기',
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
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
                    '아이디와 비밀번호를 찾기 위해\n본인 인증이 필요해요.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing32),
                  
                  // 에러 메시지
                  if (_errorMessage != null) _buildErrorMessage(),
                  
                  // 찾은 계정 정보 표시 또는 비밀번호 재설정 폼
                  if (_foundId != null) 
                    _isResettingPassword ? _buildPasswordResetForm() : _buildFoundAccountCard(),
                  
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
              child: _buildBottomButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    if (_foundId != null) {
      if (_isResettingPassword) {
        return CustomButton(
          text: _isLoading ? '비밀번호 변경 중...' : '비밀번호 변경 완료',
          onPressed: _isLoading ? null : _completePasswordReset,
          style: CustomButtonStyle.primary,
          size: CustomButtonSize.large,
          width: double.infinity,
        );
      } else {
        return Column(
          children: [
            CustomButton(
              text: '비밀번호 재설정',
              onPressed: _resetPassword,
              style: CustomButtonStyle.outline,
              size: CustomButtonSize.large,
              width: double.infinity,
            ),
            const SizedBox(height: AppDimensions.spacing12),
            CustomButton(
              text: '로그인하기',
              onPressed: () => context.pop(),
              style: CustomButtonStyle.primary,
              size: CustomButtonSize.large,
              width: double.infinity,
            ),
          ],
        );
      }
    } else {
      return CustomButton(
        text: _isLoading ? '본인 인증 중...' : '본인 인증 시작하기',
        onPressed: _isLoading ? null : _startPassVerification,
        style: CustomButtonStyle.primary,
        size: CustomButtonSize.large,
        width: double.infinity,
      );
    }
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

  Widget _buildFoundAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: Colors.green[600],
            size: 48,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          Text(
            '$_foundUserName님의 계정 정보',
            style: AppTextStyles.h6.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing12),
          
          // 아이디 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아이디',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  _foundId!,
                  style: AppTextStyles.h5.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetForm() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                CupertinoIcons.lock_shield_fill,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Text(
                '$_foundUserName님의 비밀번호 재설정',
                style: AppTextStyles.h6.copyWith(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing20),
          
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
          
          const SizedBox(height: AppDimensions.spacing12),
          
          // 취소 버튼
          TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _isResettingPassword = false;
                _errorMessage = null;
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              });
            },
            child: Text(
              '취소',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
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

  // PASS 본인인증 시작
  Future<void> _startPassVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundId = null;
      _foundUserName = null;
    });

    try {
      final passService = PassVerificationService();
      final result = await passService.startDirectPassVerification(
        context: context,
        purpose: 'ID/PW 찾기',
      );

      if (result.success) {
        // PASS 인증 성공 - 사용자 이름으로 아이디 찾기
        final userName = result.name;
        if (userName != null) {
          final foundUserId = await _findUserIdByName(userName);
          if (foundUserId != null) {
            setState(() {
              _isLoading = false;
              _foundUserName = userName;
              _foundId = foundUserId;
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
      // 현재는 시뮬레이션
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

  // 비밀번호 재설정 시작
  void _resetPassword() {
    setState(() {
      _isResettingPassword = true;
      _errorMessage = null;
    });
  }

  // 비밀번호 재설정 완료
  Future<void> _completePasswordReset() async {
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
    });

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 2));
      
      // 시뮬레이션: 항상 성공
      setState(() {
        _isLoading = false;
        _isResettingPassword = false;
        _errorMessage = null;
      });
      
      // 성공 메시지 표시 후 로그인 화면으로 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 성공적으로 변경되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      }
      
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