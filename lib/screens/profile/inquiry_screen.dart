import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InquiryScreen extends StatelessWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_left,
            color: Colors.black,
            size: 28,
          ),
        ),
        title: const Text(
          '문의하기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 로고 섹션
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    // 로고 이미지
                    Image.asset(
                      'assets/icons/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'LOGO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // 이메일 입력 섹션
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.mail,
                      color: Color(0xFF666666),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'meet@meet.io',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 이메일 섹션
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '이메일',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '• 제목: [문의 유형] 간략한 내용으로 표기 부탁드립니다\n• 답변: 접수 후 영업일 기준 5~7일내 순차적으로\n  답변드리고 있습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 유의사항 섹션
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '유의사항',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '• 개인정보(비밀번호 등)는 절대 요청하지 않습니다.\n• 이메일 답변이 스팸으로 분류될 있는 폴더에\n  확인해 주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}