import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import 'phone_verification_screen.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  // 약관 동의 상태
  bool _agreeAll = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeLocation = false;

  // 약관 데이터
  final List<TermsItem> _termsItems = [
    TermsItem(
      id: 'terms',
      title: '이용약관',
      isRequired: true,
      description: '서비스 이용에 필요한 기본 약관입니다',
    ),
    TermsItem(
      id: 'privacy',
      title: '개인정보 취급 방침',
      isRequired: true,
      description: '개인정보 수집 및 이용에 대한 동의입니다',
    ),
    TermsItem(
      id: 'location',
      title: '위치기반 서비스 이용약관',
      isRequired: true,
      description: '매칭 서비스를 위한 위치정보 이용 동의입니다',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with just back button
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Banner Image
                    _buildTopBanner(),
                    
                    const SizedBox(height: 32),
                    
                    // Master Agreement
                    _buildMasterAgreement(),
                    
                    const SizedBox(height: 16),
                    
                    // Individual Terms
                    ...(_termsItems.map((item) => _buildTermsItem(item))),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/join.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the original banner if image fails to load
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '설레는 만남의 시작 사귈래',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '사귈래는 철저한 본인인증으로',
                          style: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '믿을 수 있는 서비스를 제공해 드리고 있습니다.',
                          style: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 12,
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
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMasterAgreement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: _toggleMasterAgreement,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _agreeAll ? const Color(0xFFE91E63) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2,
                ),
              ),
              child: _agreeAll
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          const Text(
            '전체 약관에 동의합니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsItem(TermsItem item) {
    final isChecked = _getTermsAgreement(item.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleTermsAgreement(item.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFFE91E63) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Text(
              '${item.title} (${item.isRequired ? '필수' : '선택'})',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          
          // View Details Button
          GestureDetector(
            onTap: () => _viewTermsDetail(item),
            child: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _proceedNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '다음으로',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  bool _getTermsAgreement(String id) {
    switch (id) {
      case 'terms':
        return _agreeTerms;
      case 'privacy':
        return _agreePrivacy;
      case 'location':
        return _agreeLocation;
      default:
        return false;
    }
  }

  void _toggleTermsAgreement(String id) {
    setState(() {
      switch (id) {
        case 'terms':
          _agreeTerms = !_agreeTerms;
          break;
        case 'privacy':
          _agreePrivacy = !_agreePrivacy;
          break;
        case 'location':
          _agreeLocation = !_agreeLocation;
          break;
      }
      
      // Update master agreement
      _updateMasterAgreement();
    });
  }

  void _toggleMasterAgreement() {
    setState(() {
      _agreeAll = !_agreeAll;
      
      // Update all individual agreements
      _agreeTerms = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeLocation = _agreeAll;
    });
  }

  void _updateMasterAgreement() {
    setState(() {
      _agreeAll = _agreeTerms && _agreePrivacy && _agreeLocation;
    });
  }

  void _viewTermsDetail(TermsItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTermsDetailModal(item),
    );
  }

  Widget _buildTermsDetailModal(TermsItem item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacing12),
            width: AppDimensions.bottomSheetHandleWidth,
            height: AppDimensions.bottomSheetHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(
                AppDimensions.bottomSheetHandleHeight / 2,
              ),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: Row(
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconM,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.bottomSheetPadding,
              ),
              child: Text(
                _getTermsContent(item.id),
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
            ),
          ),
          
          // Close Button
          Container(
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: CustomButton(
              text: '확인',
              onPressed: () => Navigator.pop(context),
              style: CustomButtonStyle.primary,
              size: CustomButtonSize.medium,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  String _getTermsContent(String id) {
    switch (id) {
      case 'terms':
        return '''
제1조 (목적)
이 약관은 사랑해(이하 "회사")가 제공하는 모바일 애플리케이션 서비스(이하 "서비스")의 이용조건 및 절차, 회사와 회원 간의 권리, 의무, 책임사항 등을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"라 함은 회사가 제공하는 데이팅 매칭 서비스를 의미합니다.
2. "회원"이라 함은 회사의 서비스에 접속하여 이 약관에 따라 회사와 이용계약을 체결하고 회사가 제공하는 서비스를 이용하는 고객을 말합니다.

제3조 (약관의 효력 및 변경)
1. 이 약관은 서비스를 이용하고자 하는 모든 회원에 대하여 그 효력을 발생합니다.
2. 회사는 합리적인 사유가 발생할 경우에는 이 약관을 변경할 수 있으며, 약관이 변경되는 경우 지체 없이 공지합니다.

제4조 (서비스의 제공 및 변경)
1. 회사는 다음과 같은 업무를 수행합니다:
   - 데이팅 매칭 서비스
   - 채팅 서비스
   - 프로필 관리 서비스
   - 기타 회사가 정하는 업무

제5조 (서비스 이용계약의 성립)
1. 서비스 이용계약은 이용고객이 약관의 내용에 대하여 동의를 한 다음 서비스 이용 신청을 하고 회사가 이러한 신청에 대하여 승낙함으로써 성립합니다.
        ''';
      
      case 'privacy':
        return '''
개인정보 취급방침

사랑해(이하 "회사")는 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 이용자의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.

1. 개인정보의 처리 목적
회사는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며 이용 목적이 변경되는 경우에는 개인정보보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

가. 회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지, 만14세 미만 아동 개인정보 수집 시 법정대리인 동의여부 확인 목적으로 개인정보를 처리합니다.

나. 서비스 제공에 관한 계약 이행 및 서비스 제공에 따른 요금정산, 콘텐츠 제공 목적으로 개인정보를 처리합니다.

2. 개인정보의 처리 및 보유 기간
① 회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.
- 회원 가입 및 관리: 서비스 이용계약 또는 회원가입 해지시까지
- 재화 또는 서비스 제공: 재화·서비스 공급완료 및 요금결제·정산 완료시까지

3. 처리하는 개인정보의 항목
회사는 다음의 개인정보 항목을 처리하고 있습니다.
- 필수항목: 이름, 생년월일, 성별, 휴대폰번호, 이메일주소
- 선택항목: 프로필 사진, 직업, 학력, 종교, 흡연여부
        ''';
      
      case 'location':
        return '''
위치기반서비스 이용약관

제1조 (목적)
이 약관은 사랑해(이하 "회사")가 제공하는 위치기반서비스에 대해 회사와 개인위치정보주체와의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (약관의 효력 및 변경)
① 이 약관은 서비스를 이용하고자 하는 개인위치정보주체가 동의함으로써 효력이 발생됩니다.
② 회사는 위치정보의 보호 및 이용 등에 관한 법률, 정보통신망 이용촉진 및 정보보호 등에 관한 법률 등 관련 법령을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다.

제3조 (서비스 내용 및 요금)
① 회사는 개인위치정보를 이용하여 다음과 같은 위치기반서비스를 제공합니다.
1. 근거리 이용자 찾기 서비스: 이용자 간의 거리 측정 및 근거리 이용자 검색
2. 위치 기반 매칭 서비스: 위치정보를 활용한 매칭 추천

② 제1항의 위치기반서비스는 무료로 제공됩니다. 단, 데이터 통신료는 이용자가 부담합니다.

제4조 (개인위치정보주체의 권리)
① 개인위치정보주체는 개인위치정보 수집, 이용, 제공에 대한 동의를 언제든지 철회할 수 있습니다.
② 개인위치정보주체는 언제든지 개인위치정보의 수집, 이용, 제공의 일시정지를 요구할 수 있습니다.

제5조 (위치정보 이용, 제공)
① 회사는 개인위치정보를 이용하여 서비스를 제공하고자 하는 경우에는 미리 개인위치정보주체에게 동의를 받습니다.
② 회사는 개인위치정보주체의 동의 없이는 당해 개인위치정보를 제3자에게 제공하지 않습니다.
        ''';
      
      
      default:
        return '약관 내용을 불러올 수 없습니다.';
    }
  }

  void _proceedNext() {
    // 필수 약관 동의 확인
    if (!_agreeTerms || !_agreePrivacy || !_agreeLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '필수 약관에 모두 동의해주세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
      );
      return;
    }
    
    // 약관 동의 완료 후 휴대폰 번호 인증 페이지로 이동
    _goToPhoneVerification();
  }
  
  void _goToPhoneVerification() {
    // 약관 동의 데이터를 휴대폰 인증 페이지로 전달
    final agreedTerms = {
      'terms': _agreeTerms,
      'privacy': _agreePrivacy,
      'location': _agreeLocation,
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneVerificationScreen(
          agreedTerms: agreedTerms,
        ),
      ),
    );
  }
}

class TermsItem {
  final String id;
  final String title;
  final bool isRequired;
  final String description;

  TermsItem({
    required this.id,
    required this.title,
    required this.isRequired,
    required this.description,
  });
}