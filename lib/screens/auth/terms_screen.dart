import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/constants/app_constants.dart';

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
  bool _agreeMarketing = false; // 선택 약관

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
    TermsItem(
      id: 'marketing',
      title: '마케팅 정보 수신',
      isRequired: false,
      description: '이벤트 및 혜택 정보 수신에 대한 동의입니다',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VIP Banner
                    _buildVipBanner(),
                    
                    const SizedBox(height: AppDimensions.spacing32),
                    
                    // Title
                    Text(
                      '이용약관 동의',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    Text(
                      '서비스 이용을 위해 약관 동의가 필요합니다',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing32),
                    
                    // Master Agreement
                    _buildMasterAgreement(),
                    
                    const SizedBox(height: AppDimensions.spacing20),
                    
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacing12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              CupertinoIcons.back,
              color: AppColors.textPrimary,
              size: AppDimensions.iconM,
            ),
          ),
          
          Expanded(
            child: Text(
              '이용약관 동의',
              style: AppTextStyles.appBarTitle,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: AppDimensions.iconM + 16),
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
              CupertinoIcons.heart_fill,
              color: AppColors.textWhite,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterAgreement() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: _agreeAll ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: _agreeAll ? AppColors.primary : AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: Row(
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: _toggleMasterAgreement,
            child: Container(
              width: AppDimensions.checkboxSize + 4,
              height: AppDimensions.checkboxSize + 4,
              decoration: BoxDecoration(
                color: _agreeAll ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: _agreeAll ? AppColors.primary : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: _agreeAll
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: AppColors.textWhite,
                      size: 16,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전체 약관에 동의합니다',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _agreeAll ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  '필수 및 선택 약관을 모두 확인하였으며 동의합니다',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsItem(TermsItem item) {
    final isChecked = _getTermsAgreement(item.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleTermsAgreement(item.id),
            child: Container(
              width: AppDimensions.checkboxSize,
              height: AppDimensions.checkboxSize,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: AppColors.textWhite,
                      size: 14,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Required/Optional Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: item.isRequired ? AppColors.primary : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                      ),
                      child: Text(
                        item.isRequired ? '필수' : '선택',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppDimensions.spacing8),
                    
                    // Title
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.spacing4),
                
                // Description
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // View Details Button
          GestureDetector(
            onTap: () => _viewTermsDetail(item),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              child: const Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.textSecondary,
                size: AppDimensions.iconS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final requiredAgreed = _agreeTerms && _agreePrivacy && _agreeLocation;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderNormal,
          ),
        ),
      ),
      child: CustomButton(
        text: '다음으로',
        onPressed: _proceedNext,
        style: CustomButtonStyle.gradient,
        size: CustomButtonSize.large,
        width: double.infinity,
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
      case 'marketing':
        return _agreeMarketing;
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
        case 'marketing':
          _agreeMarketing = !_agreeMarketing;
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
      _agreeMarketing = _agreeAll;
    });
  }

  void _updateMasterAgreement() {
    final allRequired = _agreeTerms && _agreePrivacy && _agreeLocation;
    final allOptional = _agreeMarketing;
    
    setState(() {
      _agreeAll = allRequired && allOptional;
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
      
      case 'marketing':
        return '''
마케팅 정보 수신 동의

1. 수집하는 개인정보 항목
회사는 마케팅 정보 발송을 위해 다음과 같은 개인정보를 수집합니다:
- 이름, 휴대폰번호, 이메일주소
- 서비스 이용 기록, 관심사 정보

2. 개인정보의 수집 및 이용목적
- 이벤트 정보 및 참여 기회 제공
- 신규 서비스 및 상품 소식, 할인 혜택 안내
- 맞춤형 광고 및 마케팅 정보 제공
- 고객 만족도 조사 및 마케팅 분석

3. 개인정보의 보유 및 이용기간
마케팅 정보 수신 동의일로부터 회원 탈퇴 또는 수신 거부 의사를 밝힐 때까지 보유 및 이용합니다.

4. 동의 거부권 및 불이익
귀하는 마케팅 정보 수신 동의를 거부할 권리가 있으며, 동의 거부 시에도 회사가 제공하는 기본적인 서비스 이용에는 제한이 없습니다. 다만, 마케팅 정보 제공과 관련된 서비스는 이용하실 수 없습니다.

5. 수신 거부 방법
- 앱 내 설정 메뉴에서 수신 거부 설정
- 고객센터 전화: 1588-0000
- 이메일: unsubscribe@saranghae.com

마케팅 정보 수신에 동의하시겠습니까?
        ''';
      
      default:
        return '약관 내용을 불러올 수 없습니다.';
    }
  }

  void _proceedNext() {
    // 약관 동의 완료 후 다음 단계로 이동
    final agreedTerms = {
      'terms': _agreeTerms,
      'privacy': _agreePrivacy,
      'location': _agreeLocation,
      'marketing': _agreeMarketing,
    };
    
    // 성공 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '약관 동의가 완료되었습니다',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    );
    
    // 다음 화면으로 이동 (본인인증 또는 프로필 작성)
    Navigator.pop(context, agreedTerms);
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