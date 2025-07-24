import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

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
          '자주 묻는 질문',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ 항목들
              _buildFaqItem(
                '회원가입 방법',
                '''회원가입은 앱 메인에서 [회원가입] 버튼을 클릭하고 필수 정보를 입력하여 간단한 인증 절차를 수 있습니다.''',
              ),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('매칭 추천 인원'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('매칭 연결 문제'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('구독 취소 방법'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('메시지 읽음 확인 기능'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('개인정보 보호'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('매칭 추천 초기화'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('부적절한 사용자 신고 방법'),
              
              const SizedBox(height: 16),
              
              _buildFaqItem('문의 방법'),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String title, [String? content]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_down,
                color: Color(0xFF666666),
                size: 20,
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}