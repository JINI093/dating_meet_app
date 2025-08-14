import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/route_names.dart';
import '../../utils/auth_validators.dart';

class SignupIdInputScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? mobileOKVerification;
  final Map<String, dynamic>? additionalData;
  
  const SignupIdInputScreen({
    super.key,
    this.mobileOKVerification,
    this.additionalData,
  });

  @override
  ConsumerState<SignupIdInputScreen> createState() => _SignupIdInputScreenState();
}

class _SignupIdInputScreenState extends ConsumerState<SignupIdInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _debounceTimer;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _isChecking = false;
  bool _isValidId = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _idController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _validateAndNext() {
    if (_isValidId && (_formKey.currentState?.validate() ?? false)) {
      final signupData = {
        'mobileOKVerification': widget.mobileOKVerification,
        'additionalData': widget.additionalData,
        'userId': _idController.text.trim(),
      };
      
      context.push(
        RouteNames.signupPasswordInput,
        extra: signupData,
      );
    }
  }

  Future<void> _checkIdAvailability(String id) async {
    if (id.isEmpty) {
      setState(() {
        _isValidId = false;
        _errorMessage = null;
        _successMessage = null;
      });
      return;
    }

    // 이메일 형식 검증 먼저
    final emailValidation = AuthValidators.validateEmail(id);
    if (!emailValidation.isValid) {
      setState(() {
        _isValidId = false;
        _errorMessage = emailValidation.message;
        _successMessage = null;
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final isAvailable = await AuthValidators.checkEmailAvailability(id);
      
      if (mounted) {
        setState(() {
          _isChecking = false;
          if (isAvailable) {
            _isValidId = true;
            _successMessage = '사용 가능한 아이디입니다.';
            _errorMessage = null;
          } else {
            _isValidId = false;
            _errorMessage = '이미 사용 중인 아이디입니다.';
            _successMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isValidId = false;
          _errorMessage = '중복 확인 중 오류가 발생했습니다.';
          _successMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 상단 검정 배너
          _buildTopBanner(),
          
          // 메인 컨텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // 제목
                  const Text(
                    '아이디 입력',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 설명
                  const Text(
                    '로그인에 필요한 아이디를 입력해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 입력 폼
                  _buildInputForm(),
                  
                  const Spacer(),
                  
                  // 하단 버튼
                  _buildBottomButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/join.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '아이디',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _idController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: '아이디를 입력해주세요',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => null, // 실시간 검사로 처리
            onChanged: (value) {
              // 500ms 지연 후 중복 검사
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                _checkIdAvailability(value);
              });
            },
          ),
          if (_isChecking) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '중복 확인 중...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ] else if (_successMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _successMessage!,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ] else if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _validateAndNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isValidId ? Colors.blue : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '다음',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}