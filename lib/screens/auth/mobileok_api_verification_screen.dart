import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/mobileok_api_service.dart';
import '../../routes/route_names.dart';

class MobileOKAPIVerificationScreen extends ConsumerStatefulWidget {
  final String purpose;
  final String? userId;
  final Map<String, dynamic>? additionalData;

  const MobileOKAPIVerificationScreen({
    super.key,
    required this.purpose,
    this.userId,
    this.additionalData,
  });

  @override
  ConsumerState<MobileOKAPIVerificationScreen> createState() => _MobileOKAPIVerificationScreenState();
}

class _MobileOKAPIVerificationScreenState extends ConsumerState<MobileOKAPIVerificationScreen>
    with TickerProviderStateMixin {
  final MobileOKAPIService _mobileOKService = MobileOKAPIService();
  
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _errorMessage;
  MobileOKAPIResult? _verificationResult;
  bool _hasStartedVerification = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeService();
    // 화면 진입 시 바로 PASS 인증 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVerification();
    });
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
      await _mobileOKService.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'MobileOK 서비스 초기화에 실패했습니다.';
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
    if (_isVerifying || _hasStartedVerification) return;
    
    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
      _hasStartedVerification = true;
    });

    try {
      // PASS 인증 시작 (실제로는 PASS 앱으로 이동)
      // 시뮬레이션 모드에서는 가상의 사용자 정보를 생성
      final result = await _mobileOKService.startVerification(
        purpose: widget.purpose,
        userName: '', // PASS에서 자동으로 가져옴
        phoneNumber: '', // PASS에서 자동으로 가져옴
        birthDate: '', // PASS에서 자동으로 가져옴
        gender: '', // PASS에서 자동으로 가져옴
        provider: '', // PASS에서 자동으로 가져옴
        authType: 'PASS', // PASS 앱 인증
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
            _errorMessage = _mobileOKService.getErrorMessage(result.error);
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

  void _handleVerificationSuccess(MobileOKAPIResult result) {
    // 성공 메시지 표시 후 다음 단계로 이동
    _showSuccessDialog(result);
  }

  void _showSuccessDialog(MobileOKAPIResult result) {
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
              'MobileOK 본인인증이 성공적으로 완료되었습니다.',
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
                  _buildInfoRow('국적', result.nation ?? ''),
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

  void _navigateToNextStep(MobileOKAPIResult result) {
    // 목적에 따라 다음 단계로 이동
    switch (widget.purpose) {
      case '회원가입':
        // 새로운 회원가입 플로우: 아이디 입력 페이지로 이동
        context.go(
          RouteNames.signupIdInput,
          extra: {
            'mobileOKVerification': result.toJson(),
            'additionalData': widget.additionalData,
          },
        );
        break;
      case '소셜로그인':
        context.go(
          RouteNames.profileSetup,
          extra: {
            'mobileOKVerification': result.toJson(),
            'socialLoginData': widget.additionalData,
          },
        );
        break;
      default:
        context.pop(result);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
          onPressed: () {
            context.go(RouteNames.login);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PASS 본인확인',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
                    child: SingleChildScrollView(
                      child: _buildContent(),
                    ),
                  ),
                  _buildBottomButton(),
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
      children: [
        // PASS 브랜딩
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // PASS 로고 영역
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A90E2),
                      Color(0xFF357ABD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'PASS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PASS 본인확인',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '간편하고 안전한 본인인증',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // 인증 진행 중 표시
              if (_hasStartedVerification && _errorMessage == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: const Color(0xFF4A90E2),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PASS 앱으로 이동 중...',
                        style: TextStyle(
                          color: const Color(0xFF4A90E2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 인증 진행 상태 또는 에러 메시지
        if (_isVerifying || _hasStartedVerification)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  const Color(0xFF357ABD).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                // 진행 애니메이션
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A90E2),
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'PASS 앱에서 본인확인을 진행해주세요',
                  style: TextStyle(
                    color: const Color(0xFF4A90E2),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '휴대폰에서 PASS 알림을 확인하여\n본인확인을 완료해주세요',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
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
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // 안내사항
        _buildNoticeBox(),
      ],
    );
  }

  Widget _buildNoticeBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A90E2).withValues(alpha: 0.05),
            const Color(0xFF357ABD).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A90E2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PASS 본인인증 안내',
                style: TextStyle(
                  color: const Color(0xFF4A90E2),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            {'icon': Icons.smartphone, 'text': 'PASS 앱이 설치되어 있어야 합니다'},
            {'icon': Icons.person_outline, 'text': '본인명의 휴대폰이 필요합니다'},
            {'icon': Icons.security, 'text': '인증 정보는 안전하게 암호화됩니다'},
            {'icon': Icons.verified_user, 'text': '간편하고 빠른 본인확인 서비스'},
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: const Color(0xFF4A90E2),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['text'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PASS 로고가 있는 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_isLoading || _hasStartedVerification) ? null : _startVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isLoading || _hasStartedVerification) ? Colors.grey.shade400 : const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                elevation: (_isLoading || _hasStartedVerification) ? 0 : 3,
                shadowColor: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: (_isLoading || _hasStartedVerification)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PASS 인증 대기중...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PASS로 본인확인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 부가 안내 텍스트
          if (!_isLoading && !_hasStartedVerification)
            Text(
              '터치하면 PASS 앱이 실행되어 본인확인을 진행합니다',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          if (_hasStartedVerification && _errorMessage == null)
            Text(
              'PASS 앱에서 본인확인을 진행해주세요',
              style: TextStyle(
                color: const Color(0xFF4A90E2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}