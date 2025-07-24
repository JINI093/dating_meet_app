import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_text_field.dart';
// TODO: 실제 PASS 인증 서비스로 대체 필요
import '../../core/constants/app_constants.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCarrier = '';
  
  // State management
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _errorMessage;
  String? _txId;
  Timer? _statusCheckTimer;
  
  // Mock verification steps
  VerificationStep _currentStep = VerificationStep.input;
  
  // 지원되는 통신사 목록
  static const List<String> _supportedCarriers = [
    'SKT', 'KT', 'LG U+', 'SKT 알뜰폰', 'KT 알뜰폰', 'LG U+ 알뜰폰'
  ];
  
  // 통신사 이름 맵핑
  static const Map<String, String> _carrierNames = {
    'SKT': 'SKT',
    'KT': 'KT',
    'LG U+': 'LG U+',
    'SKT 알뜰폰': 'SKT 알뜰폰',
    'KT 알뜰폰': 'KT 알뜰폰',
    'LG U+ 알뜰폰': 'LG U+ 알뜰폰',
  };
  
  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(
            CupertinoIcons.back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'PASS 본인인증',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case VerificationStep.input:
        return _buildInputForm();
      case VerificationStep.processing:
        return _buildProcessingView();
      case VerificationStep.success:
        return _buildSuccessView();
      case VerificationStep.error:
        return _buildErrorView();
    }
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIP Banner
          _buildVipBanner(),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          // Title
          Text(
            '본인인증',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            '안전한 서비스 이용을 위해 본인인증을 진행합니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          // Progress Indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          // Form Fields
          CustomTextField(
            controller: _nameController,
            labelText: '이름',
            hintText: '실명을 입력해주세요',
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          CustomTextField(
            controller: _birthDateController,
            labelText: '생년월일',
            hintText: 'YYYYMMDD (예: 19801010)',
            type: CustomTextFieldType.number,
            maxLength: 8,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          CustomTextField(
            controller: _phoneController,
            labelText: '휴대폰 번호',
            hintText: '010-0000-0000',
            type: CustomTextFieldType.phone,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Carrier Selection
          Text(
            '통신사',
            style: AppTextStyles.inputLabel,
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          _buildCarrierSelector(),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: AppColors.error,
                    size: AppDimensions.iconM,
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppDimensions.spacing48),
          
          // Submit Button
          CustomButton(
            text: _isLoading ? '인증 요청 중...' : 'PASS 인증 시작',
            onPressed: _isLoading ? null : _startVerification,
            style: _isLoading 
                ? CustomButtonStyle.disabled 
                : CustomButtonStyle.gradient,
            size: CustomButtonSize.large,
            width: double.infinity,
            isLoading: _isLoading,
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Info Text
          Text(
            'PASS 앱이 설치되어 있지 않은 경우\n자동으로 앱 스토어로 이동합니다',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          // Loading Animation
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          Text(
            'PASS 인증 진행 중...',
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            '잠시만 기다려주세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          CustomButton(
            text: '취소',
            onPressed: _cancelVerification,
            style: CustomButtonStyle.outline,
            size: CustomButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.checkmark,
              color: AppColors.textWhite,
              size: 50,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          Text(
            '본인인증 완료',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            '인증이 성공적으로 완료되었습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          CustomButton(
            text: '확인',
            onPressed: () => Navigator.pop(context, true),
            style: CustomButtonStyle.gradient,
            size: CustomButtonSize.large,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          // Error Icon
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: AppDimensions.iconXXL * 1.5,
            color: AppColors.error,
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          Text(
            '본인인증 실패',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing12),
          
          Text(
            _errorMessage ?? '인증 중 오류가 발생했습니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.spacing48),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '다시 시도',
                  onPressed: () {
                    setState(() {
                      _currentStep = VerificationStep.input;
                      _errorMessage = null;
                    });
                  },
                  style: CustomButtonStyle.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: CustomButton(
                  text: '취소',
                  onPressed: () => Navigator.pop(context, false),
                  style: CustomButtonStyle.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVipBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '설레는 만남의 시작 사랑해',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '사랑해는 철저한 본인인증으로',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '믿을 수 있는 서비스를 제공해 드리고 있습니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.shield_fill,
              color: AppColors.textWhite,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStep(1, 'info', _currentStep.index >= 0),
        _buildStepConnector(_currentStep.index >= 1),
        _buildStep(2, 'auth', _currentStep.index >= 1),
        _buildStepConnector(_currentStep.index >= 2),
        _buildStep(3, 'done', _currentStep.index >= 2),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String stepType, bool isActive) {
    Color color = isActive ? AppColors.primary : AppColors.divider;
    IconData icon;
    
    switch (stepType) {
      case 'info':
        icon = CupertinoIcons.doc_text;
        break;
      case 'auth':
        icon = CupertinoIcons.shield;
        break;
      case 'done':
        icon = CupertinoIcons.checkmark;
        break;
      default:
        icon = CupertinoIcons.circle;
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.textWhite,
        size: 16,
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : AppColors.divider,
      ),
    );
  }

  Widget _buildCarrierSelector() {
    return Wrap(
      spacing: AppDimensions.spacing12,
      runSpacing: AppDimensions.spacing8,
      children: _supportedCarriers.map((carrier) {
        final isSelected = _selectedCarrier == carrier;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCarrier = carrier;
              _errorMessage = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: AppDimensions.borderNormal,
              ),
            ),
            child: Text(
              _carrierNames[carrier] ?? carrier,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Event Handlers
  Future<void> _startVerification() async {
    if (!_validateForm()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: 실제 PASS 인증 서비스 구현 필요
      // 현재는 임시로 실패 처리
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'PASS 인증 서비스 연동이 필요합니다.';
        _currentStep = VerificationStep.error;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '인증 서비스 연결에 실패했습니다.';
        _currentStep = VerificationStep.error;
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = '이름을 입력해주세요.');
      return false;
    }
    
    if (_birthDateController.text.trim().length != 8) {
      setState(() => _errorMessage = '생년월일 8자리를 정확히 입력해주세요.');
      return false;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = '휴대폰 번호를 입력해주세요.');
      return false;
    }
    
    if (_selectedCarrier.isEmpty) {
      setState(() => _errorMessage = '통신사를 선택해주세요.');
      return false;
    }
    
    return true;
  }

  void _startStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_txId == null) {
        timer.cancel();
        return;
      }
      
      try {
        // TODO: 실제 PASS 인증 상태 체크 구현 필요
        // 현재는 임시로 실패 처리
        timer.cancel();
        setState(() {
          _currentStep = VerificationStep.error;
          _errorMessage = 'PASS 인증 서비스 연동이 필요합니다.';
        });
      } catch (e) {
        timer.cancel();
        setState(() {
          _currentStep = VerificationStep.error;
          _errorMessage = '인증 상태 확인에 실패했습니다.';
        });
      }
    });
  }

  void _cancelVerification() {
    _statusCheckTimer?.cancel();
    
    if (_txId != null) {
      // TODO: 실제 PASS 인증 취소 구현 필요
    }
    
    setState(() {
      _currentStep = VerificationStep.input;
      _txId = null;
      _isVerifying = false;
    });
  }
}

enum VerificationStep {
  input,    // 정보 입력
  processing, // 인증 진행 중
  success,  // 인증 성공
  error,    // 인증 실패
}