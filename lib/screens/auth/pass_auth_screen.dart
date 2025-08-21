import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../services/pass_verification_service.dart';

class PassAuthScreen extends ConsumerStatefulWidget {
  final String purpose;
  final Map<String, dynamic>? additionalData;

  const PassAuthScreen({
    super.key,
    required this.purpose,
    this.additionalData,
  });

  @override
  ConsumerState<PassAuthScreen> createState() => _PassAuthScreenState();
}

class _PassAuthScreenState extends ConsumerState<PassAuthScreen> {
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

  void _toggleAgreement(String agreementId) {
    setState(() {
      if (agreementId == 'all') {
        _allAgreed = !_allAgreed;
        // 전체 동의 시 모든 약관 동의
        _agreementStates.forEach((key, value) {
          _agreementStates[key] = _allAgreed;
        });
      } else {
        _agreementStates[agreementId] = !(_agreementStates[agreementId] ?? false);
        // 개별 약관 상태에 따라 전체 동의 업데이트
        _updateAllAgreedState();
      }
    });
  }

  void _updateAllAgreedState() {
    bool allChecked = true;
    _agreementStates.forEach((key, value) {
      if (!value) allChecked = false;
    });
    setState(() {
      _allAgreed = allChecked;
    });
  }

  bool _canProceed() {
    if (_selectedTelecom == null) return false;
    
    // 필수 약관이 모두 동의되었는지 확인
    for (var agreement in _agreements) {
      if (agreement['required'] == true && agreement['id'] != 'all') {
        if (!(_agreementStates[agreement['id']] ?? false)) {
          return false;
        }
      }
    }
    return true;
  }

  void _startPassAuth() async {
    if (!_canProceed()) {
      _showErrorDialog('통신사를 선택하고 필수 약관에 동의해주세요.');
      return;
    }

    try {
      _showLoadingDialog();
      
      // 웹뷰 기반 PASS 인증 시작
      final passService = PassVerificationService();
      await passService.initialize();
      
      Navigator.of(context).pop(); // 로딩 닫기
      
      // 실제 기기에서는 PASS 앱 직접 호출, 개발환경에서는 시뮬레이션
      final result = await passService.startDirectPassVerification(
        context: context,
        purpose: widget.purpose,
        additionalParams: widget.additionalData,
      );

      if (result.success) {
        _handleAuthSuccess(result);
      } else {
        _showAuthFailureDialog(result.error ?? '인증에 실패했습니다.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 닫기
      print('PASS 인증 오류: $e');
      _showAuthFailureDialog('인증 중 오류가 발생했습니다. 다시 시도하거나 건너뛸 수 있습니다.');
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

  void _handleAuthSuccess(PassVerificationResult passResult) {
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

  void _showAuthFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('PASS 인증 실패'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'PASS 인증 없이도 회원가입을 진행할 수 있습니다.\n단, 일부 기능 이용에 제한이 있을 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startPassAuth(); // 다시 시도
            },
            child: const Text('다시 시도'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedWithoutPass(); // PASS 인증 없이 진행
            },
            child: const Text(
              '건너뛰기',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedWithoutPass() {
    // PASS 인증 없이 회원가입 진행
    final result = {
      'success': false, // PASS 인증은 실패
      'skipAuth': true, // 인증을 건너뛴다는 플래그
      'telecom': _selectedTelecom,
      'message': 'PASS 인증을 건너뛰었습니다',
    };

    // 프로필 설정으로 이동 (PASS 데이터 없이)
    context.pushReplacement(
      RouteNames.profileSetup,
      extra: {
        'passAuth': result,
        'purpose': widget.purpose,
        'skipPassAuth': true, // 인증을 건너뛰었음을 표시
        ...?widget.additionalData,
      },
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PASS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이용중이신 통신사를 선택해주세요.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 통신사 선택
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _telecoms.length,
                    itemBuilder: (context, index) {
                      final telecom = _telecoms[index];
                      final isSelected = _selectedTelecom == telecom['id'];
                      
                      return GestureDetector(
                        onTap: () => _selectTelecom(telecom['id']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 로고 대신 텍스트 표시 (실제로는 이미지 사용)
                              Text(
                                telecom['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primary : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 약관 동의
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _agreements.map((agreement) {
                        final isAll = agreement['id'] == 'all';
                        final isChecked = isAll ? _allAgreed : (_agreementStates[agreement['id']] ?? false);
                        
                        return InkWell(
                          onTap: () => _toggleAgreement(agreement['id']),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isChecked ? AppColors.primary : Colors.grey,
                                    ),
                                    color: isChecked ? AppColors.primary : Colors.white,
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  agreement['text'],
                                  style: TextStyle(
                                    fontSize: isAll ? 16 : 14,
                                    fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 안내 문구
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '이용문의 : 개인정보처리방침',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomButton(
                  text: 'PASS로 인증하기',
                  onPressed: _canProceed() ? _startPassAuth : null,
                  style: CustomButtonStyle.gradient,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '문자(SMS)로 인증하기',
                  onPressed: _canProceed() ? _startSmsAuth : null,
                  style: CustomButtonStyle.outline,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '인증 없이 회원가입 계속하기',
                  onPressed: _canProceed() ? _proceedWithoutPass : null,
                  style: CustomButtonStyle.text,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}