import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/pass_verification_service.dart';
import '../../routes/route_names.dart';

class PassVerificationScreen extends ConsumerStatefulWidget {
  final String purpose;
  final String? userId;
  final Map<String, dynamic>? additionalData;

  const PassVerificationScreen({
    super.key,
    required this.purpose,
    this.userId,
    this.additionalData,
  });

  @override
  ConsumerState<PassVerificationScreen> createState() => _PassVerificationScreenState();
}

class _PassVerificationScreenState extends ConsumerState<PassVerificationScreen>
    with TickerProviderStateMixin {
  final PassVerificationService _passService = PassVerificationService();
  
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _errorMessage;
  PassVerificationResult? _verificationResult;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeService();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _initializeService() async {
    try {
      await _passService.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'PASS 서비스 초기화에 실패했습니다.';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    if (_isVerifying) return;

    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _passService.startVerification(
        purpose: widget.purpose,
        additionalParams: widget.additionalData,
      );

      if (mounted) {
        setState(() {
          _verificationResult = result;
          _isLoading = false;
          _isVerifying = false;
        });

        if (result.success) {
          _handleVerificationSuccess(result);
        } else {
          setState(() {
            _errorMessage = _passService.getErrorMessage(result.error);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
          _errorMessage = '본인인증 중 오류가 발생했습니다.';
        });
      }
    }
  }

  Future<void> _startSimulatedVerification() async {
    if (_isVerifying) return;

    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _passService.simulateSuccess(
        purpose: widget.purpose,
      );

      if (mounted) {
        setState(() {
          _verificationResult = result;
          _isLoading = false;
          _isVerifying = false;
        });

        _handleVerificationSuccess(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
          _errorMessage = '시뮬레이션 중 오류가 발생했습니다.';
        });
      }
    }
  }

  void _handleVerificationSuccess(PassVerificationResult result) {
    // 인증 정보 저장
    if (widget.userId != null) {
      _passService.storeVerificationResult(widget.userId!, result);
    }

    // 성공 메시지 표시 후 다음 단계로 이동
    _showSuccessDialog(result);
  }

  void _showSuccessDialog(PassVerificationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              Icons.verified_user,
              color: AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '본인인증 완료',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '본인인증이 성공적으로 완료되었습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                children: [
                  _buildInfoRow('이름', result.name ?? ''),
                  _buildInfoRow('생년월일', _formatBirthDate(result.birthDate)),
                  _buildInfoRow('성별', _formatGender(result.gender)),
                  _buildInfoRow('휴대폰', _formatPhoneNumber(result.phoneNumber)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: '확인',
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToNextStep(result);
            },
            style: CustomButtonStyle.gradient,
            size: CustomButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.length != 8) return '';
    return '${birthDate.substring(0, 4)}.${birthDate.substring(4, 6)}.${birthDate.substring(6, 8)}';
  }

  String _formatGender(String? gender) {
    switch (gender) {
      case 'M':
        return '남성';
      case 'F':
        return '여성';
      default:
        return '';
    }
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.length != 11) return phoneNumber ?? '';
    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7, 11)}';
  }

  void _navigateToNextStep(PassVerificationResult result) {
    // 목적에 따라 다음 단계로 이동
    switch (widget.purpose) {
      case '회원가입':
        context.pushReplacement(
          RouteNames.profileSetup,
          extra: {
            'passVerification': result.toJson(),
            'additionalData': widget.additionalData,
          },
        );
        break;
      case '소셜로그인':
        context.pushReplacement(
          RouteNames.profileSetup,
          extra: {
            'passVerification': result.toJson(),
            'socialLoginData': widget.additionalData,
          },
        );
        break;
      default:
        context.pop(result);
        break;
    }
  }

  void _goBack() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: _goBack,
        ),
        title: Text(
          'PASS 본인인증',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(),
                  ),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // PASS 로고 및 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 제목
        Text(
          'PASS 본인인증',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 설명
        Text(
          _getPurposeDescription(),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'PASS 앱을 통해 간편하고 안전하게 본인인증을 진행합니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // 에러 메시지
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // 로딩 인디케이터
        if (_isLoading)
          Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                '본인인증을 진행중입니다...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 40),
        
        // 안내사항
        _buildNoticeBox(),
      ],
    );
  }

  Widget _buildNoticeBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '안내사항',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getNoticeItems().map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _getPurposeDescription() {
    switch (widget.purpose) {
      case '회원가입':
        return '회원가입을 위해 본인인증이 필요합니다.';
      case '소셜로그인':
        return '소셜 로그인 후 본인인증을 진행합니다.';
      default:
        return '서비스 이용을 위해 본인인증이 필요합니다.';
    }
  }

  List<String> _getNoticeItems() {
    return [
      'PASS 앱이 설치되어 있어야 합니다.',
      '본인명의 휴대폰이 필요합니다.',
      '인증 정보는 안전하게 암호화되어 저장됩니다.',
      '타인의 정보로 인증 시 법적 제재를 받을 수 있습니다.',
    ];
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        CustomButton(
          text: _isLoading ? '인증 진행중...' : 'PASS 본인인증 시작',
          onPressed: _isLoading ? null : _startVerification,
          style: CustomButtonStyle.gradient,
          size: CustomButtonSize.large,
          width: double.infinity,
        ),
        
        const SizedBox(height: 12),
        
        // 개발용 시뮬레이션 버튼 (실제 배포시에는 제거)
        if (widget.additionalData?['enableSimulation'] == true)
          CustomButton(
            text: '시뮬레이션 (개발용)',
            onPressed: _isLoading ? null : _startSimulatedVerification,
            style: CustomButtonStyle.outline,
            size: CustomButtonSize.large,
            width: double.infinity,
          ),
      ],
    );
  }
}