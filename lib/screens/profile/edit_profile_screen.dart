import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/dialogs/region_selector_bottom_sheet.dart';
import '../../providers/current_user_profile_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../services/aws_profile_service.dart';
import '../../utils/logger.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AWSProfileService _profileService = AWSProfileService();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bodyTypeController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  
  // Profile images (6 slots)
  final List<File?> _profileImages = List.filled(6, null);
  final List<String?> _existingImageUrls = List.filled(6, null);
  
  // Selected values
  String? _selectedGender;
  String? _selectedSmoking;
  String? _selectedDrinking;
  String? _selectedReligion;
  String? _selectedMbti;
  // Date of birth
  DateTime? _selectedBirthDate;
  
  // Hobbies
  final Set<String> _selectedHobbies = <String>{};
  
  String? _selectedSido;
  String? _selectedGugun;

  // Profile ID for updating existing profile
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _nameController.dispose();
    _introController.dispose();
    _jobController.dispose();
    _locationController.dispose();
    _heightController.dispose();
    _bodyTypeController.dispose();
    _educationController.dispose();
    _ageController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (authState.currentUser?.user?.userId != null) {
        final userId = authState.currentUser!.user!.userId;
        final profile = await _profileService.getProfileByUserId(userId);
        
        if (profile != null && mounted) {
          _profileId = profile.id;
          
          setState(() {
            _usernameController.text = authState.currentUser!.user!.username;
            _nameController.text = profile.name;
            _nicknameController.text = profile.name;
            _ageController.text = profile.age.toString();
            // 나이에서 대략적인 생년 계산 (생년월일이 없어서 임시)
            final estimatedBirthYear = DateTime.now().year - profile.age;
            _selectedBirthDate = DateTime(estimatedBirthYear, 1, 1);
            _birthDateController.text = '${estimatedBirthYear}년 01월 01일';
            // _selectedGender = profile.gender; // Gender not in ProfileModel
            _locationController.text = profile.location;
            _jobController.text = profile.occupation ?? '';
            _introController.text = profile.bio ?? '';
            _educationController.text = profile.education ?? '';
            _heightController.text = profile.height?.toString() ?? '';
            _bodyTypeController.text = profile.bodyType ?? '';
            _selectedSmoking = profile.smoking;
            _selectedDrinking = profile.drinking;
            _selectedReligion = profile.religion;
            _selectedMbti = profile.mbti;
            
            // Load existing images
            for (int i = 0; i < profile.profileImages.length && i < 6; i++) {
              _existingImageUrls[i] = profile.profileImages[i];
            }
            
            // Load hobbies
            _selectedHobbies.addAll(profile.hobbies);
          });
        }
      }
    } catch (e) {
      Logger.error('프로필 로드 실패', error: e, name: 'EditProfileScreen');
      _showErrorSnackBar('프로필 정보를 불러오는데 실패했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('프로필 편집', style: AppTextStyles.headingMedium),
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(CupertinoIcons.chevron_left),
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveProfile : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '저장',
                    style: TextStyle(
                      color: _hasChanges ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildDetailInfoSection(),
                    const SizedBox(height: 24),
                    _buildLifestyleSection(),
                    const SizedBox(height: 24),
                    _buildHobbiesSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('프로필 사진', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        const Text(
          '최대 6장까지 추가할 수 있습니다. 첫 번째 사진이 대표 사진으로 사용됩니다.',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => _buildPhotoSlot(index),
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index) {
    final hasImage = _profileImages[index] != null || _existingImageUrls[index] != null;
    
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.border,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium - 1),
                    child: _profileImages[index] != null
                        ? Image.file(
                            _profileImages[index]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _existingImageUrls[index]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.error, color: AppColors.textSecondary),
                            ),
                          ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '대표',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
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
                  Icon(
                    CupertinoIcons.camera,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '사진 추가',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('기본 정보', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _usernameController,
          label: '아이디',
          onChanged: (_) => _markChanged(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '아이디를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _nameController,
          label: '이름',
          onChanged: (_) => _markChanged(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이름을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _ageController,
          label: '나이',
          type: CustomTextFieldType.number,
          onChanged: (_) => _markChanged(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '나이를 입력해주세요';
            }
            final age = int.tryParse(value);
            if (age == null || age < 40 || age > 100) {
              return '40세 이상 100세 이하로 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _birthDateController,
          label: '생년월일',
          readOnly: true,
          onTap: _selectBirthDate,
          suffixIcon: CupertinoIcons.calendar,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '생년월일을 선택해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: '성별',
          value: _selectedGender,
          items: ['남성', '여성'],
          onChanged: (value) {
            setState(() => _selectedGender = value);
            _markChanged();
          },
          validator: (value) => value == null ? '성별을 선택해주세요' : null,
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _locationController,
          label: '지역',
          onChanged: (_) => _markChanged(),
          onTap: _selectLocation,
          readOnly: true,
          suffixIcon: CupertinoIcons.chevron_right,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '지역을 선택해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDetailInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('상세 정보', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _jobController,
          label: '직업',
          onChanged: (_) => _markChanged(),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _educationController,
          label: '학력',
          onChanged: (_) => _markChanged(),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _heightController,
          label: '키 (cm)',
          type: CustomTextFieldType.number,
          onChanged: (_) => _markChanged(),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _bodyTypeController,
          label: '체형',
          onChanged: (_) => _markChanged(),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _introController,
          label: '자기소개',
          maxLines: 4,
          onChanged: (_) => _markChanged(),
          validator: (value) {
            if (value != null && value.length > 500) {
              return '자기소개는 500자 이내로 작성해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('라이프스타일', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: '흡연',
          value: _selectedSmoking,
          items: ['비흡연', '가끔', '자주'],
          onChanged: (value) {
            setState(() => _selectedSmoking = value);
            _markChanged();
          },
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: '음주',
          value: _selectedDrinking,
          items: ['안마심', '가끔', '자주'],
          onChanged: (value) {
            setState(() => _selectedDrinking = value);
            _markChanged();
          },
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: '종교',
          value: _selectedReligion,
          items: ['무교', '기독교', '천주교', '불교', '기타'],
          onChanged: (value) {
            setState(() => _selectedReligion = value);
            _markChanged();
          },
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'MBTI',
          value: _selectedMbti,
          items: [
            'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
            'ISTP', 'ISFP', 'INFP', 'INTP',
            'ESTP', 'ESFP', 'ENFP', 'ENTP',
            'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ'
          ],
          onChanged: (value) {
            setState(() => _selectedMbti = value);
            _markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildHobbiesSection() {
    final availableHobbies = [
      '운동', '독서', '영화감상', '음악감상', '여행', '요리',
      '게임', '사진', '그림', '춤', '노래', '악기연주',
      '등산', '낚시', '골프', '테니스', '수영', '사이클링',
      '카페', '맛집탐방', '와인', '커피', '반려동물', '원예'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('취미', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        const Text(
          '최대 5개까지 선택할 수 있습니다.',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableHobbies.map((hobby) {
            final isSelected = _selectedHobbies.contains(hobby);
            return GestureDetector(
              onTap: () => _toggleHobby(hobby),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  hobby,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  void _pickImage(int index) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image != null) {
        setState(() {
          _profileImages[index] = File(image.path);
          _existingImageUrls[index] = null; // Clear existing URL when new image is picked
        });
        _markChanged();
      }
    } catch (e) {
      _showErrorSnackBar('이미지를 선택할 수 없습니다.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _profileImages[index] = null;
      _existingImageUrls[index] = null;
    });
    _markChanged();
  }

  void _selectBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1980, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18세 이상
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
        _birthDateController.text = 
            '${pickedDate.year}년 ${pickedDate.month.toString().padLeft(2, '0')}월 ${pickedDate.day.toString().padLeft(2, '0')}일';
        // 나이 자동 계산
        final age = DateTime.now().year - pickedDate.year;
        _ageController.text = age.toString();
      });
      _markChanged();
    }
  }

  void _selectLocation() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegionSelectorBottomSheet(
        onSelected: (sido, gugun) {
          setState(() {
            _selectedSido = sido;
            _selectedGugun = gugun;
            _locationController.text = '$sido $gugun';
          });
          _markChanged();
          Navigator.pop(context); // Close the bottom sheet
        },
      ),
    );
  }

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else if (_selectedHobbies.length < 5) {
        _selectedHobbies.add(hobby);
      } else {
        _showErrorSnackBar('취미는 최대 5개까지 선택할 수 있습니다.');
        return;
      }
    });
    _markChanged();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _handleBack() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('변경사항이 있습니다'),
          content: const Text('저장하지 않고 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('나가기'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final userId = authState.currentUser!.user!.userId;

      // Prepare new images (filter out nulls)
      final newImages = _profileImages.where((img) => img != null).cast<File>().toList();
      
      // Prepare existing image URLs (filter out nulls)
      final existingUrls = _existingImageUrls.where((url) => url != null).cast<String>().toList();

      final age = int.tryParse(_ageController.text);
      if (age == null) {
        throw Exception('올바른 나이를 입력해주세요.');
      }

      if (_profileId != null) {
        // Update existing profile
        final updatedProfile = await _profileService.updateProfile(
          profileId: _profileId!,
          name: _nameController.text,
          age: age,
          location: _locationController.text,
          newProfileImages: newImages.isNotEmpty ? newImages : null,
          existingImageUrls: existingUrls.isNotEmpty ? existingUrls : null,
          bio: _introController.text.isNotEmpty ? _introController.text : null,
          occupation: _jobController.text.isNotEmpty ? _jobController.text : null,
          education: _educationController.text.isNotEmpty ? _educationController.text : null,
          height: int.tryParse(_heightController.text),
          bodyType: _bodyTypeController.text.isNotEmpty ? _bodyTypeController.text : null,
          smoking: _selectedSmoking,
          drinking: _selectedDrinking,
          religion: _selectedReligion,
          mbti: _selectedMbti,
          hobbies: _selectedHobbies.isNotEmpty ? _selectedHobbies.toList() : null,
        );

        if (updatedProfile != null) {
          _showSuccessSnackBar('프로필이 성공적으로 업데이트되었습니다.');
          setState(() => _hasChanges = false);
          
          // Refresh the profile provider
          ref.read(currentUserProfileProvider.notifier).refreshProfile();
        } else {
          throw Exception('프로필 업데이트에 실패했습니다.');
        }
      } else {
        // Create new profile (fallback)
        if (newImages.isEmpty && existingUrls.isEmpty) {
          throw Exception('최소 1장 이상의 프로필 사진이 필요합니다.');
        }

        final allImages = [...newImages];
        if (allImages.isEmpty) {
          throw Exception('프로필 사진을 추가해주세요.');
        }

        final newProfile = await _profileService.createProfile(
          userId: userId,
          name: _nameController.text,
          age: age,
          gender: _selectedGender ?? '남성', // Default to 남성 if not selected
          location: _locationController.text,
          profileImages: allImages,
          bio: _introController.text.isNotEmpty ? _introController.text : null,
          occupation: _jobController.text.isNotEmpty ? _jobController.text : null,
          education: _educationController.text.isNotEmpty ? _educationController.text : null,
          height: int.tryParse(_heightController.text),
          bodyType: _bodyTypeController.text.isNotEmpty ? _bodyTypeController.text : null,
          smoking: _selectedSmoking,
          drinking: _selectedDrinking,
          religion: _selectedReligion,
          mbti: _selectedMbti,
          hobbies: _selectedHobbies.toList(),
        );

        if (newProfile != null) {
          _profileId = newProfile.id;
          _showSuccessSnackBar('프로필이 성공적으로 생성되었습니다.');
          setState(() => _hasChanges = false);
          
          // Refresh the profile provider
          ref.read(currentUserProfileProvider.notifier).refreshProfile();
        } else {
          throw Exception('프로필 생성에 실패했습니다.');
        }
      }
    } catch (e) {
      Logger.error('프로필 저장 실패', error: e, name: 'EditProfileScreen');
      _showErrorSnackBar(e.toString().contains('Exception:') 
          ? e.toString().replaceAll('Exception:', '').trim()
          : '프로필 저장에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}