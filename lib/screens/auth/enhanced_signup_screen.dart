import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/dialogs/info_dialog.dart';
import '../../routes/route_names.dart';
import '../../services/multi_signup_service.dart';

enum SignupType { email, phone, social }
enum SignupStep { selectType, idPw, personal, terms, verify, profile, complete }

class EnhancedSignupScreen extends ConsumerStatefulWidget {
  const EnhancedSignupScreen({super.key});
  @override
  ConsumerState<EnhancedSignupScreen> createState() => _EnhancedSignupScreenState();
}

class _EnhancedSignupScreenState extends ConsumerState<EnhancedSignupScreen> {
  SignupType _type = SignupType.email;
  SignupStep _step = SignupStep.selectType;

  // 입력 컨트롤러 및 상태
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  bool _isIdValid = false;
  bool _isIdUnique = true;
  bool _isEmailValid = false;
  bool _isEmailUnique = true;
  bool _isPhoneValid = false;
  bool _isPhoneUnique = true;
  bool _isPwStrong = false;
  bool _isPwMatch = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  XFile? _profileImage;

  // 약관 동의
  Map<String, bool> _terms = {
    'service': false,
    'privacy': false,
    'marketing': false,
  };

  // MultiSignupService
  final MultiSignupService _signupService = MultiSignupService();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildStepContent(),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case SignupStep.selectType:
        return _buildTypeSelector();
      case SignupStep.idPw:
        return _buildIdPwStep();
      case SignupStep.personal:
        return _buildPersonalStep();
      case SignupStep.terms:
        return _buildTermsStep();
      case SignupStep.verify:
        return _buildVerifyStep();
      case SignupStep.profile:
        return _buildProfileStep();
      case SignupStep.complete:
        return _buildCompleteStep();
    }
  }

  // 1. 회원가입 방식 선택
  Widget _buildTypeSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('회원가입 방식을 선택하세요', style: AppTextStyles.h5),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeButton(SignupType.email, '이메일'),
            const SizedBox(width: 16),
            _buildTypeButton(SignupType.phone, '전화번호'),
            const SizedBox(width: 16),
            _buildTypeButton(SignupType.social, '소셜'),
          ],
        ),
      ],
    );
  }
  Widget _buildTypeButton(SignupType type, String label) {
    final selected = _type == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.background,
        foregroundColor: selected ? Colors.white : AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      ),
      onPressed: () {
        setState(() {
          _type = type;
          _step = SignupStep.idPw;
        });
      },
      child: Text(label, style: AppTextStyles.buttonLarge),
    );
  }

  // 2. 기본 정보 입력 (아이디/비밀번호)
  Widget _buildIdPwStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('기본 정보 입력', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _idController,
            labelText: '아이디',
            onChanged: (v) async {
              setState(() { _isIdValid = v.length >= 4; });
              if (_isIdValid) {
                final unique = await _signupService.checkUsernameAvailability(v);
                setState(() { _isIdUnique = unique; });
              }
            },
            errorText: !_isIdUnique ? '이미 사용 중인 아이디입니다.' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pwController,
            labelText: '비밀번호',
            type: CustomTextFieldType.password,
            onChanged: (v) {
              setState(() { _isPwStrong = v.length >= 8; });
            },
            errorText: !_isPwStrong ? '8자 이상 입력하세요.' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pwConfirmController,
            labelText: '비밀번호 확인',
            type: CustomTextFieldType.password,
            onChanged: (v) {
              setState(() { _isPwMatch = v == _pwController.text; });
            },
            errorText: !_isPwMatch ? '비밀번호가 일치하지 않습니다.' : null,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: '다음',
            onPressed: _isIdValid && _isIdUnique && _isPwStrong && _isPwMatch
                ? () => setState(() => _step = SignupStep.personal)
                : null,
          ),
        ],
      ),
    );
  }

  // 3. 개인정보 입력
  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('개인정보 입력', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _nameController,
            labelText: '이름',
          ),
          const SizedBox(height: 16),
          if (_type == SignupType.email)
            CustomTextField(
              controller: _emailController,
              labelText: '이메일',
              onChanged: (v) async {
                setState(() { _isEmailValid = v.contains('@'); });
                if (_isEmailValid) {
                  final unique = await _signupService.checkEmailAvailability(v);
                  setState(() { _isEmailUnique = unique; });
                }
              },
              errorText: !_isEmailUnique ? '이미 사용 중인 이메일입니다.' : null,
            ),
          if (_type == SignupType.phone)
            CustomTextField(
              controller: _phoneController,
              labelText: '전화번호',
              onChanged: (v) async {
                setState(() { _isPhoneValid = v.length >= 10; });
                if (_isPhoneValid) {
                  final unique = await _signupService.checkPhoneNumberAvailability(v);
                  setState(() { _isPhoneUnique = unique; });
                }
              },
              errorText: !_isPhoneUnique ? '이미 사용 중인 번호입니다.' : null,
            ),
          if (_type == SignupType.phone)
            CustomTextField(
              controller: _birthController,
              labelText: '생년월일 (YYYYMMDD)',
            ),
          const SizedBox(height: 32),
          CustomButton(
            text: '다음',
            onPressed: _isPersonalValid() ? () => setState(() => _step = SignupStep.terms) : null,
          ),
        ],
      ),
    );
  }
  bool _isPersonalValid() {
    if (_type == SignupType.email) {
      return _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _isEmailValid && _isEmailUnique;
    } else if (_type == SignupType.phone) {
      return _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty && _isPhoneValid && _isPhoneUnique && _birthController.text.length == 8;
    }
    return true;
  }

  // 4. 약관 동의
  Widget _buildTermsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('약관 동의', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _terms['service'],
            onChanged: (v) => setState(() => _terms['service'] = v ?? false),
            title: const Text('[필수] 서비스 이용약관 동의'),
          ),
          CheckboxListTile(
            value: _terms['privacy'],
            onChanged: (v) => setState(() => _terms['privacy'] = v ?? false),
            title: const Text('[필수] 개인정보 처리방침 동의'),
          ),
          CustomButton(
            text: '다음',
            onPressed: _terms['service']! && _terms['privacy']!
                ? () => setState(() => _step = SignupStep.verify)
                : null,
          ),
        ],
      ),
    );
  }

  // 5. 이메일/SMS 인증
  Widget _buildVerifyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('인증', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          if (_type == SignupType.email)
            Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  labelText: '이메일',
                  enabled: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _smsCodeController,
                  labelText: '이메일 인증코드',
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: '인증코드 확인',
                  onPressed: _verifyEmailCode,
                ),
              ],
            ),
          if (_type == SignupType.phone)
            Column(
              children: [
                CustomTextField(
                  controller: _phoneController,
                  labelText: '전화번호',
                  enabled: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _smsCodeController,
                  labelText: 'SMS 인증코드',
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: '인증코드 확인',
                  onPressed: _verifyPhoneCode,
                ),
              ],
            ),
        ],
      ),
    );
  }
  Future<void> _verifyEmailCode() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await _signupService.confirmSignUp(
      username: _idController.text,
      confirmationCode: _smsCodeController.text,
    );
    setState(() { _isLoading = false; });
    if (result.isSuccess) {
      setState(() => _step = SignupStep.profile);
    } else {
      setState(() { _errorMessage = result.error; });
    }
  }
  Future<void> _verifyPhoneCode() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await _signupService.completePhoneSignup(
      verificationId: _verificationId!,
      smsCode: _smsCodeController.text,
      phoneNumber: _phoneController.text,
      additionalInfo: {
        'name': _nameController.text,
        'birth': _birthController.text,
        'agreedTerms': _terms.keys.where((k) => _terms[k]!).toList(),
      },
    );
    setState(() { _isLoading = false; });
    if (result.isSuccess) {
      setState(() => _step = SignupStep.profile);
    } else {
      setState(() { _errorMessage = result.error; });
    }
  }

  // 6. 프로필 설정 (선택)
  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('프로필 설정 (선택)', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: _profileImage != null ? FileImage(_profileImage!.path as dynamic) : null,
              child: _profileImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: '회원가입 완료',
            onPressed: _completeSignup,
          ),
        ],
      ),
    );
  }
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _profileImage = picked; });
    }
  }
  Future<void> _completeSignup() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    // 실제로는 추가 정보와 프로필 이미지 업로드
    setState(() { _isLoading = false; _step = SignupStep.complete; });
  }

  // 7. 완료 화면
  Widget _buildCompleteStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.primary, size: 80),
          const SizedBox(height: 24),
          Text('회원가입이 완료되었습니다!', style: AppTextStyles.h5),
          const SizedBox(height: 24),
          CustomButton(
            text: '로그인하러 가기',
            onPressed: () => context.go(RouteNames.login),
          ),
        ],
      ),
    );
  }
} 