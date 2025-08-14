import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_names.dart';

class SignupCompleteInfoScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? signupData;
  
  const SignupCompleteInfoScreen({
    super.key,
    this.signupData,
  });

  @override
  ConsumerState<SignupCompleteInfoScreen> createState() => _SignupCompleteInfoScreenState();
}

class _SignupCompleteInfoScreenState extends ConsumerState<SignupCompleteInfoScreen> {
  
  void _goToProfileSetup() {
    context.pushReplacement(
      RouteNames.profileSetup,
      extra: widget.signupData,
    );
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // 로고 이미지
                  Image.asset(
                    'assets/icons/logo.png',
                    width: 360,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  
                  // 제목 (간격 없음)
                  const Text(
                    '회원가입 완료!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 설명 텍스트
                  const Text(
                    '회원가입이 완료되었습니다!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    '완벽한 MEET이용을 위하여',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    '본인 프로필 등록 후이용으로 이동합니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          // 하단 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _goToProfileSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '프로필 작성하기',
                    style: TextStyle(
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