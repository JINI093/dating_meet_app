import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../services/java_pass_service.dart';

class JavaPassAuthScreen extends ConsumerStatefulWidget {
  final String purpose;
  final Map<String, dynamic>? additionalData;

  const JavaPassAuthScreen({
    super.key,
    required this.purpose,
    this.additionalData,
  });

  @override
  ConsumerState<JavaPassAuthScreen> createState() => _JavaPassAuthScreenState();
}

class _JavaPassAuthScreenState extends ConsumerState<JavaPassAuthScreen> {
  String? _selectedTelecom;
  String? _selectedAuthType;
  bool _allAgreed = false;
  
  final List<Map<String, dynamic>> _telecoms = [
    {'id': 'SKT', 'name': 'SK telecom', 'logo': 'assets/icons/skt.png'},
    {'id': 'KT', 'name': 'kt', 'logo': 'assets/icons/kt.png'},
    {'id': 'LGU', 'name': 'LG U+', 'logo': 'assets/icons/lgu.png'},
    {'id': 'MVNO', 'name': '알뜰폰', 'logo': 'assets/icons/mvno.png'},
  ];

  final List<Map<String, dynamic>> _agreements = [
    {'id': 'all', 'text': '전체 동의하기', 'required': true},
    {'id': 'personal', 'text': '개인정보이용동의', 'required': true},
    {'id': 'unique', 'text': '고유식별정보처리동의', 'required': true},
    {'id': 'service', 'text': '서비스이용약관동의', 'required': true},
    {'id': 'telecom', 'text': '통신사이용약관동의', 'required': true},
  ];

  Map<String, bool> _agreementStates = {};

  @override
  void initState() {
    super.initState();
    // 약관 동의 상태 초기화
    for (var agreement in _agreements) {
      if (agreement['id'] != 'all') {
        _agreementStates[agreement['id']] = false;
      }
    }
  }

  void _selectTelecom(String telecomId) {
    setState(() {
      _selectedTelecom = telecomId;
    });
  }

  void _selectAuthType(String authType) {
    setState(() {
      _selectedAuthType = authType;
    });
  }

  void _toggleAgreement(String agreementId) {
    setState(() {
      if (agreementId == 'all') {
        _allAgreed = !_allAgreed;
        for (var agreement in _agreements) {
          if (agreement['id'] != 'all') {
            _agreementStates[agreement['id']] = _allAgreed;
          }
        }
      } else {
        _agreementStates[agreementId] = !(_agreementStates[agreementId] ?? false);
        
        // 개별 동의 상태에 따라 전체 동의 상태 업데이트
        bool allChecked = true;
        for (var agreement in _agreements) {
          if (agreement['id'] != 'all' && !(_agreementStates[agreement['id']] ?? false)) {
            allChecked = false;
            break;
          }
        }
        _allAgreed = allChecked;
      }
    });
  }

  bool _canProceed() {
    if (_selectedTelecom == null) return false;
    
    for (var agreement in _agreements) {
      if (agreement['required'] == true && agreement['id'] != 'all') {
        if (!(_agreementStates[agreement['id']] ?? false)) {
          return false;
        }
      }
    }
    return true;
  }

  void _startJavaPassAuth() async {
    if (!_canProceed()) {
      _showErrorDialog('통신사를 선택하고 필수 약관에 동의해주세요.');
      return;
    }

    try {
      _showLoadingDialog();
      
      // Java PASS 인증 시작
      final passService = JavaPassService();
      await passService.initialize();
      
      Navigator.of(context).pop(); // 로딩 닫기
      
      final result = await passService.startVerification(
        context: context,
        purpose: widget.purpose,
        additionalParams: widget.additionalData,
      );

      if (result.success) {
        _handleAuthSuccess(result);
      } else {
        _showErrorDialog(result.error ?? '인증에 실패했습니다.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 닫기
      print('Java PASS 인증 오류: $e');
      _showErrorDialog('인증 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _startSmsAuth() {
    if (!_canProceed()) {
      _showErrorDialog('통신사를 선택하고 필수 약관에 동의해주세요.');
      return;
    }

    // SMS 인증으로 이동
    context.push(
      '/phone-verification',
      extra: {
        'telecom': _selectedTelecom,
        'purpose': widget.purpose,
        ...?widget.additionalData,
      },
    );
  }

  void _handleAuthSuccess(JavaPassVerificationResult passResult) {
    // 인증 성공 처리
    final result = {
      'success': true,
      'telecom': _selectedTelecom,
      'name': passResult.name, // 실제 인증 결과
      'phone': passResult.phoneNumber,
      'birthDate': passResult.birthDate,
      'gender': passResult.gender,
      'ci': passResult.ci,
      'di': passResult.di,
      'txId': passResult.txId,
    };

    // 다음 화면으로 이동
    context.pushReplacement(
      RouteNames.profileSetup,
      extra: {
        'passAuth': result,
        'purpose': widget.purpose,
        ...?widget.additionalData,
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('PASS 인증 중...'),
          ],
        ),
      ),
    );
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          '본인인증',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '본인인증 방법을\n선택해주세요',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // 통신사 선택
              Text(
                '통신사 선택',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              
              // 통신사 버튼들
              Wrap(
                spacing: AppDimensions.spacing8,
                runSpacing: AppDimensions.spacing8,
                children: _telecoms.map((telecom) {
                  final isSelected = _selectedTelecom == telecom['id'];
                  return GestureDetector(
                    onTap: () => _selectTelecom(telecom['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            telecom['logo'],
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            telecom['name'],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // 인증 방법 선택
              Text(
                '인증 방법',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),

              // PASS 인증 버튼
              GestureDetector(
                onTap: () => _selectAuthType('PASS'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: _selectedAuthType == 'PASS' ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: _selectedAuthType == 'PASS' ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: _selectedAuthType == 'PASS' ? Colors.white : AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PASS 본인인증',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedAuthType == 'PASS' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'PASS 앱을 통한 간편 본인인증',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _selectedAuthType == 'PASS' ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAuthType == 'PASS')
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing16),

              // SMS 인증 버튼
              GestureDetector(
                onTap: () => _selectAuthType('SMS'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: _selectedAuthType == 'SMS' ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: _selectedAuthType == 'SMS' ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sms,
                        color: _selectedAuthType == 'SMS' ? Colors.white : AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMS 인증',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedAuthType == 'SMS' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'SMS 인증번호를 통한 본인인증',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _selectedAuthType == 'SMS' ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAuthType == 'SMS')
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // 약관 동의
              Text(
                '약관 동의',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),

              // 약관 목록
              ..._agreements.map((agreement) {
                final isRequired = agreement['required'] == true;
                final isChecked = agreement['id'] == 'all' 
                    ? _allAgreed 
                    : (_agreementStates[agreement['id']] ?? false);
                
                return GestureDetector(
                  onTap: () => _toggleAgreement(agreement['id']),
                                      child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingS,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isChecked ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Expanded(
                            child: Text(
                              agreement['text'],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isRequired)
                            Text(
                              '(필수)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const Spacer(),

              // 하단 버튼들
              if (_selectedAuthType == 'PASS')
                CustomButton(
                  text: 'PASS 인증 시작',
                  onPressed: _canProceed() ? _startJavaPassAuth : null,
                )
              else if (_selectedAuthType == 'SMS')
                CustomButton(
                  text: 'SMS 인증 시작',
                  onPressed: _canProceed() ? _startSmsAuth : null,
                )
              else
                CustomButton(
                  text: '인증 방법을 선택해주세요',
                  onPressed: null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
