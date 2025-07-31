import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';
import '../../providers/profile_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../widgets/dialogs/region_selector_bottom_sheet.dart';
import '../../services/api_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? signupData;
  
  const ProfileSetupScreen({super.key, this.signupData});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  
  // Date selection
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;
  
  // Dropdown selections
  String? _selectedJob;
  List<String> _selectedIdealTypes = [];
  List<String> _selectedHobbies = [];
  
  // Location
  String? _selectedSido;
  String? _selectedGugun;
  
  // Gender
  String? _selectedGender;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  
  // Profile images (9 slots)
  final List<File?> _profileImages = List.filled(9, null);
  
  // Options
  final List<String> jobOptions = [
    '회사원', '공무원', '전문직', '자영업', '프리랜서',
    '학생', '주부', '무직', '기타'
  ];
  
  final List<String> idealTypeOptions = [
    '성격 좋은', '유머러스한', '진중한', '활발한', '차분한',
    '로맨틱한', '현실적인', '감성적인', '이성적인', '자상한'
  ];
  
  final List<String> hobbyOptions = [
    '운동', '여행', '영화감상', '독서', '음악감상',
    '요리', '게임', '등산', '낚시', '카페투어'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    // 먼저 회원가입에서 전달된 데이터가 있으면 우선 사용
    if (widget.signupData != null) {
      setState(() {
        if (widget.signupData!['username'] != null) {
          _usernameController.text = widget.signupData!['username'];
        }
        if (widget.signupData!['name'] != null) {
          _nameController.text = widget.signupData!['name'];
        }
        // 전화번호도 있으면 참조용으로 사용 (필요한 경우)
        // if (widget.signupData!['phone'] != null) {
        //   // 전화번호 관련 필드가 있다면 여기서 설정
        // }
      });
      return; // signupData가 있으면 여기서 종료
    }
    
    // signupData가 없으면 기존 방식으로 AWS에서 정보 가져오기
    final authState = ref.read(enhancedAuthProvider);
    if (authState.currentUser?.user != null) {
      final user = authState.currentUser!.user!;
      
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (session.isSignedIn) {
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          
          setState(() {
            // 아이디 설정
            _usernameController.text = user.username;
            
            // 이름 설정
            final nameAttribute = userAttributes.firstWhere(
              (attr) => attr.userAttributeKey == AuthUserAttributeKey.name,
              orElse: () => AuthUserAttribute(
                userAttributeKey: AuthUserAttributeKey.name, 
                value: ''
              ),
            );
            if (nameAttribute.value.isNotEmpty) {
              _nameController.text = nameAttribute.value;
            }
          });
        }
      } catch (e) {
        print('사용자 정보 로딩 실패: $e');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _jobController.dispose();
    _introController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  // 프로필 완성도 계산
  double get _profileCompletion {
    double completion = 0.0;
    
    // 필수 사진 3장 (30%)
    int requiredPhotos = 0;
    for (int i = 0; i < 3; i++) {
      if (i < _profileImages.length && _profileImages[i] != null) {
        requiredPhotos++;
      }
    }
    completion += (requiredPhotos / 3) * 0.3;
    
    // 선택 사진 6장 (10%)
    int optionalPhotos = 0;
    for (int i = 3; i < 9; i++) {
      if (i < _profileImages.length && _profileImages[i] != null) {
        optionalPhotos++;
      }
    }
    completion += (optionalPhotos / 6) * 0.1;
    
    // 닉네임 (10%)
    if (_nicknameController.text.isNotEmpty) completion += 0.1;
    
    // 생년월일 (10%)
    if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) {
      completion += 0.1;
    }
    
    // 자기소개 (10%)
    if (_introController.text.isNotEmpty) completion += 0.1;
    
    // 성별 (5%)
    if (_selectedGender != null) completion += 0.05;
    
    // 지역 (10%)
    if (_selectedSido != null && _selectedGugun != null) completion += 0.1;
    
    // 직업 (5%)
    if (_selectedJob != null) completion += 0.05;
    
    // 이상형 (5%)
    if (_selectedIdealTypes.isNotEmpty) completion += 0.05;
    
    // 취미 (5%)
    if (_selectedHobbies.isNotEmpty) completion += 0.05;
    
    return completion;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileSetupProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          '프로필 등록',
          style: AppTextStyles.appBarTitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // 프로필 사진 섹션
            _buildPhotoSection(),
            
            const SizedBox(height: 32),
            
            // 프로필 완성도
            _buildCompletionSection(),
            
            const SizedBox(height: 32),
            
            // 아이디 섹션
            _buildFieldSection(
              '아이디',
              _usernameController,
              '수정불가',
              enabled: false,
            ),
            
            const SizedBox(height: 24),
            
            // 이름 섹션
            _buildFieldSection(
              '이름',
              _nameController,
              '수정불가',
              enabled: false,
            ),
            
            const SizedBox(height: 24),
            
            // 닉네임 섹션 (중복 검사)
            _buildNicknameSection(),
            
            const SizedBox(height: 24),
            
            // 생년월일 섹션
            _buildBirthDateSection(),
            
            const SizedBox(height: 24),
            
            // 자기소개 섹션
            _buildIntroSection(),
            
            const SizedBox(height: 24),
            
            // 성별 섹션
            _buildGenderSection(),
            
            const SizedBox(height: 24),
            
            // 사는 곳 섹션
            _buildLocationSection(),
            
            const SizedBox(height: 24),
            
            // 직업 섹션
            _buildJobSection(),
            
            const SizedBox(height: 24),
            
            // 이상형 섹션
            _buildIdealTypeSection(),
            
            const SizedBox(height: 24),
            
            // 취미 섹션
            _buildHobbySection(),
            
            const SizedBox(height: 24),
            
            // 추천인 코드 섹션
            _buildReferralSection(),
            
            const SizedBox(height: 40),
            
            // 저장완료 버튼
            _buildSaveButton(profileState),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 사진',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // 3x3 Grid Layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return _buildPhotoSlot(index);
          },
        ),
        
        const SizedBox(height: 12),
        
        Text(
          '프로필 사진 등록 가이드를 참고해주세요',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index) {
    final hasImage = index < _profileImages.length && _profileImages[index] != null;
    final isRequired = index < 3;
    
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRequired ? AppColors.primary : AppColors.divider,
            width: isRequired ? 2 : 1,
          ),
        ),
        child: hasImage
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _profileImages[index]!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isRequired ? '필수' : '선택',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isRequired ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isRequired ? AppColors.primary : AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: AppColors.textWhite,
                    size: 14,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildCompletionSection() {
    final completion = _profileCompletion;
    final percentage = (completion * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '프로필 완성도',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$percentage%',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completion,
          backgroundColor: AppColors.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
        const SizedBox(height: 8),
        Text(
          '프로필 정보를 많이 입력할수록 매칭률이 높아집니다!',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldSection(String label, TextEditingController controller, String placeholder, {String? errorText, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (!enabled)
              Text(
                '수정불가',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          enabled: enabled,
          style: AppTextStyles.bodyMedium.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            filled: true,
            fillColor: enabled ? AppColors.background : AppColors.surface,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '닉네임',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _checkNicknameDuplicate,
              child: Text(
                '중복확인',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nicknameController,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '닉네임을 입력해주세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생년월일',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 년도
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    hint: Text(
                      '년',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: List.generate(100, (index) {
                      final year = DateTime.now().year - 40 - index;
                      return DropdownMenuItem(
                        value: year.toString(),
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 월
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    hint: Text(
                      '월',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month.toString().padLeft(2, '0'),
                        child: Text('$month월'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 일
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    hint: Text(
                      '일',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: List.generate(31, (index) {
                      final day = index + 1;
                      return DropdownMenuItem(
                        value: day.toString().padLeft(2, '0'),
                        child: Text('$day일'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '자기소개',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '선택',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _introController,
          maxLines: 3,
          maxLength: 300,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '자기소개를 입력해주세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.background,
            counterText: '${_introController.text.length}/300',
            counterStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '성별',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '선택',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ['남성', '여성'].map((gender) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: gender == '남성' ? 0 : 4,
                  right: gender == '여성' ? 0 : 4,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedGender == gender 
                        ? AppColors.primary 
                        : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedGender == gender 
                          ? AppColors.primary 
                          : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _selectedGender == gender 
                          ? AppColors.textWhite 
                          : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '사는 곳',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '필수',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showLocationPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedSido != null && _selectedGugun != null
                      ? '$_selectedSido $_selectedGugun'
                      : '지역을 선택해주세요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedSido != null 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '직업',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '필수',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedJob,
              isExpanded: true,
              hint: Text(
                '직업을 선택해주세요',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              items: jobOptions.map((job) {
                return DropdownMenuItem(
                  value: job,
                  child: Text(job),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdealTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '이상형',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '선택',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 선택된 이상형들
        ..._selectedIdealTypes.map((type) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    type,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIdealTypes.remove(type);
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
        
        // 추가 버튼
        GestureDetector(
          onTap: _showIdealTypePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: AppColors.textWhite,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHobbySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '취미',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '선택',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 선택된 취미들
        ..._selectedHobbies.map((hobby) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hobby,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHobbies.remove(hobby);
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
        
        // 추가 버튼
        GestureDetector(
          onTap: _showHobbyPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: AppColors.textWhite,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '추천인 코드',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '선택',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _referralCodeController,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '추천인 코드를 입력해주세요',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileSetupState profileState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: profileState.isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.textWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: profileState.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.textWhite,
                strokeWidth: 2,
              ),
            )
          : Text(
              '저장완료',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
      ),
    );
  }

  // Helper methods
  Future<void> _pickImage(int index) async {
    try {
      // ProfileProvider를 통해 이미지 선택
      await ref.read(profileSetupProvider.notifier).pickImage(index);
      
      // Provider 상태에서 로컬 상태로 동기화
      final profileState = ref.read(profileSetupProvider);
      if (index < profileState.profileImages.length && profileState.profileImages[index] != null) {
        setState(() {
          // Ensure local array has enough slots
          while (_profileImages.length <= index) {
            _profileImages.add(null);
          }
          _profileImages[index] = profileState.profileImages[index];
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  void _removeImage(int index) {
    // ProfileProvider를 통해 이미지 제거
    ref.read(profileSetupProvider.notifier).removeImage(index);
    
    // 로컬 상태 동기화
    setState(() {
      if (index < _profileImages.length) {
        _profileImages[index] = null;
      }
    });
  }

  void _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();
    
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 기본적인 닉네임 유효성 검사
    if (nickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 2글자 이상이어야 합니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (nickname.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 12글자 이하여야 합니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/users/check-nickname', 
        queryParameters: {'nickname': nickname});
      
      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        if (data['available'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사용 가능한 닉네임입니다.'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미 사용 중인 닉네임입니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      print('닉네임 중복 확인 실패: $e');
      
      // API 오류 시 임시로 성공으로 처리 (개발 중이므로)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임 "$nickname"을(를) 사용할 수 있습니다. (API 연결 대기 중)'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showLocationPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegionSelectorBottomSheet(
        initialSido: _selectedSido,
        initialGugun: _selectedGugun,
        onSelected: (sido, gugun) {
          setState(() {
            _selectedSido = sido;
            _selectedGugun = gugun;
          });
        },
      ),
    );
  }

  void _showIdealTypePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '이상형 선택',
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: idealTypeOptions.where((type) => !_selectedIdealTypes.contains(type)).map((type) {
                      return ListTile(
                        title: Text(type),
                        onTap: () {
                          setState(() {
                            _selectedIdealTypes.add(type);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showHobbyPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '취미 선택',
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: hobbyOptions.where((hobby) => !_selectedHobbies.contains(hobby)).map((hobby) {
                      return ListTile(
                        title: Text(hobby),
                        onTap: () {
                          setState(() {
                            _selectedHobbies.add(hobby);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    // 필수 항목 검증
    int requiredPhotos = 0;
    for (int i = 0; i < 3; i++) {
      if (i < _profileImages.length && _profileImages[i] != null) {
        requiredPhotos++;
      }
    }
    
    if (requiredPhotos < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 사진 3장을 모두 등록해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 생년월일 검증
    if (_selectedYear == null || _selectedMonth == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 성별 검증
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('성별을 선택해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedSido == null || _selectedGugun == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지역을 선택해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedJob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('직업을 선택해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 닉네임 길이 검증
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 2글자 이상이어야 합니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (nickname.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 12글자 이하여야 합니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 나이 검증
    final birthDate = DateTime(
      int.parse(_selectedYear!),
      int.parse(_selectedMonth!),
      int.parse(_selectedDay!),
    );
    final age = DateTime.now().year - birthDate.year;
    
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('18세 이상만 가입할 수 있습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 생년월일을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final profileNotifier = ref.read(profileSetupProvider.notifier);
    
    // Update profile data
    profileNotifier.updateUsername(_usernameController.text);
    profileNotifier.updateNickname(nickname);
    profileNotifier.updateAge(age.toString());
    profileNotifier.updateGender(_selectedGender);
    profileNotifier.updateLocation('$_selectedSido $_selectedGugun');
    profileNotifier.updateJob(_selectedJob!);
    profileNotifier.updateIntroduction(_introController.text);
    profileNotifier.updateHobbies(_selectedHobbies);
    
    // 프로필 저장 시도
    final success = await profileNotifier.saveProfile();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다!'),
          backgroundColor: AppColors.primary,
        ),
      );
      
      // 프로필 저장 성공 시에만 홈으로 이동
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(RouteNames.home);
        }
      });
    } else {
      // 프로필 저장 실패 시 에러 메시지 표시
      final error = ref.read(profileSetupProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? '프로필 저장에 실패했습니다. 모든 필수 항목을 확인해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}