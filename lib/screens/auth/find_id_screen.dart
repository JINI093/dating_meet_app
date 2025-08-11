import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/aws_cognito_service.dart';

class FindIdScreen extends ConsumerStatefulWidget {
  const FindIdScreen({super.key});

  @override
  ConsumerState<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends ConsumerState<FindIdScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _errorMessage;
  String? _successMessage;
  String? _foundId;
  
  // AWS Cognito Service
  final AWSCognitoService _cognitoService = AWSCognitoService();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
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
          '아이디 찾기',
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
              '휴대폰 번호 인증',
              style: AppTextStyles.h4.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing8),
            
            // 설명
            Text(
              '회원가입 시 등록한 휴대폰 번호를 입력해주세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing32),
            
            // 에러 메시지
            if (_errorMessage != null) _buildErrorMessage(),
            
            // 성공 메시지
            if (_successMessage != null) _buildSuccessMessage(),
            
            // 찾은 아이디 표시
            if (_foundId != null) _buildFoundIdCard(),
            
            // 단계별 화면
            if (!_codeSent) 
              _buildPhoneStep()
            else 
              _buildVerificationStep(),
            
            const SizedBox(height: AppDimensions.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 휴대폰 번호 레이블
        Text(
          '휴대폰 번호',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        // 휴대폰 번호 입력
        TextField(
          controller: _phoneController,
          enabled: !_isLoading,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '010-1234-5678',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              CupertinoIcons.phone,
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
          text: _isLoading ? '전송 중...' : '인증번호 받기',
          onPressed: _isLoading ? null : _sendVerificationCode,
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
                  '회원가입 시 등록한 휴대폰 번호로만 찾을 수 있습니다.',
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

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인증번호 레이블
        Text(
          '인증번호',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        // 인증번호 입력
        TextField(
          controller: _codeController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: '6자리 인증번호를 입력하세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              CupertinoIcons.number,
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
            counterText: '',
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing16),
        
        // 재전송 버튼
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _resendVerificationCode,
            child: Text(
              '인증번호 재전송',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacing16),
        
        // 확인 버튼
        CustomButton(
          text: _isLoading ? '확인 중...' : '아이디 찾기',
          onPressed: _isLoading ? null : _verifyCode,
          style: CustomButtonStyle.dark,
          size: CustomButtonSize.large,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildFoundIdCard() {
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
            '아이디를 찾았습니다!',
            style: AppTextStyles.h6.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Text(
              _foundId!,
              style: AppTextStyles.h6.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomButton(
                  text: '로그인하기',
                  onPressed: () => context.pop(),
                  style: CustomButtonStyle.primary,
                  size: CustomButtonSize.medium,
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing12),
              
              Expanded(
                child: CustomButton(
                  text: '비밀번호 찾기',
                  onPressed: () => context.pushReplacement('/reset-password'),
                  style: CustomButtonStyle.outline,
                  size: CustomButtonSize.medium,
                ),
              ),
            ],
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

  // 인증번호 발송
  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = '휴대폰 번호를 입력해주세요.';
      });
      return;
    }
    
    if (!_isValidPhoneNumber(phone)) {
      setState(() {
        _errorMessage = '올바른 휴대폰 번호 형식을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _cognitoService.sendSMSForIdRecovery(phone);
      
      if (result.success) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
          _successMessage = '인증번호가 발송되었습니다.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? '인증번호 발송에 실패했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '인증번호 발송에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  // 인증번호 재전송
  Future<void> _resendVerificationCode() async {
    await _sendVerificationCode();
  }

  // 인증번호 확인 및 아이디 찾기
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '인증번호를 입력해주세요.';
      });
      return;
    }
    
    if (code.length != 6) {
      setState(() {
        _errorMessage = '6자리 인증번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final phone = _phoneController.text.trim();
      final result = await _cognitoService.findUserIdByPhone(
        phoneNumber: phone,
        verificationCode: code,
      );
      
      if (result.success) {
        final foundUserId = result.metadata?['foundUserId'] as String?;
        if (foundUserId != null) {
          setState(() {
            _isLoading = false;
            _foundId = foundUserId;
            _successMessage = '아이디를 찾았습니다.';
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = '아이디를 찾을 수 없습니다. 입력 정보를 확인해주세요.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? '아이디를 찾을 수 없습니다. 입력 정보를 확인해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '아이디를 찾을 수 없습니다. 입력 정보를 확인해주세요.';
      });
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // 한국 휴대폰 번호 형식 검증
    final RegExp phoneRegex = RegExp(r'^01[0-9]-?[0-9]{4}-?[0-9]{4}$');
    return phoneRegex.hasMatch(phone.replaceAll('-', ''));
  }
}