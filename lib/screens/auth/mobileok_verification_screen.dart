import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/mobileok_verification_service.dart';
import '../../routes/route_names.dart';

class MobileOKVerificationScreen extends ConsumerStatefulWidget {
  final String purpose;
  final String? userId;
  final Map<String, dynamic>? additionalData;

  const MobileOKVerificationScreen({
    super.key,
    required this.purpose,
    this.userId,
    this.additionalData,
  });

  @override
  ConsumerState<MobileOKVerificationScreen> createState() => _MobileOKVerificationScreenState();
}

class _MobileOKVerificationScreenState extends ConsumerState<MobileOKVerificationScreen>
    with TickerProviderStateMixin {
  final MobileOKVerificationService _mobileOKService = MobileOKVerificationService();
  
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _errorMessage;
  MobileOKVerificationResult? _verificationResult;
  
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
    if (_isVerifying) return;

    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _mobileOKService.startVerification(
        purpose: widget.purpose,
        context: context,
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

  Future<void> _startSimulatedVerification() async {
    if (_isVerifying) return;

    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _mobileOKService.simulateSuccess(
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

  void _handleVerificationSuccess(MobileOKVerificationResult result) {
    // 인증 정보 저장
    if (widget.userId != null) {
      _mobileOKService.storeVerificationResult(widget.userId!, result);
    }

    // 성공 메시지 표시 후 다음 단계로 이동
    _showSuccessDialog(result);
  }

  void _showSuccessDialog(MobileOKVerificationResult result) {
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
                  if (result.additionalData?['simulation'] == true)
                    _buildInfoRow('모드', '시뮬레이션'),
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

  void _navigateToNextStep(MobileOKVerificationResult result) {
    // 목적에 따라 다음 단계로 이동
    switch (widget.purpose) {
      case '회원가입':
        // 일반 회원가입: MobileOK 인증 후 → 아이디/비밀번호 생성 페이지로
        context.go(
          RouteNames.signup,
          extra: {
            'mobileOKVerification': result.toJson(),
            'additionalData': widget.additionalData,
          },
        );
        break;
      case '소셜로그인':
        // SNS 로그인: MobileOK 인증 후 → 바로 프로필 설정으로
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              // 바로 로그인 페이지로 이동
              context.go(RouteNames.login);
            },
          ),
          title: Text(
            'MobileOK 본인인증',
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // 드림시큐리티 MobileOK 로고 스타일
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // 로고 영역
              Container(
                width: 180,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066CC), // MobileOK 브랜드 색상
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Mobile OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '휴대폰 본인확인',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 인증 안내
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.smartphone,
                size: 48,
                color: const Color(0xFF0066CC),
              ),
              const SizedBox(height: 16),
              Text(
                _getPurposeDescription(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '본인 명의의 휴대폰으로\n안전하게 인증을 진행합니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 에러 메시지
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 24),
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
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0066CC)),
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
          ),
        
        // 인증 결과 표시 영역 (mok.html의 textarea 대응)
        if (_verificationResult != null && !_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text(
                  '인증이 완료되었습니다.',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 32),
        
        // 안내사항
        _buildNoticeBox(),
      ],
      ),
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
      '본인명의 휴대폰이 필요합니다.',
      '인증 정보는 안전하게 암호화되어 저장됩니다.',
      '타인의 정보로 인증 시 법적 제재를 받을 수 있습니다.',
      'MobileOK은 드림시큐리티에서 제공하는 본인인증 서비스입니다.',
    ];
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // mok.html의 버튼 스타일 적용
          Material(
            color: const Color(0xFF0066CC),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _isLoading ? null : _startVerification,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    _isLoading ? '인증 진행중...' : '본인확인 시작(팝업)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 개발용 시뮬레이션 버튼
          if (widget.additionalData?['enableSimulation'] == true || true) // 개발 중이므로 항상 표시
            Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _isLoading ? null : _startSimulatedVerification,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '시뮬레이션 (개발용)',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}