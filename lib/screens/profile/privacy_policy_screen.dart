import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          '개인정보취급방침',
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
              // 섹션 1
              _buildSection(
                '[개인정보의 수집 및 이용 목적]',
                '''저희는 서비스 제공과 고객 문의 응대를 위해 최소한의 개인정보를 수집합니다. 수집된 정보는 아래 목적으로만 사용됩니다:
• 회원 가입 및 관리
• 고객 문의 처리 및 공지사항 전달
• 맞춤형 서비스 제공''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 2
              _buildSection(
                '[수집하는 개인정보의 항목]',
                '''• 필수 정보: 이름, 연락처(이메일/전화번호), 아이디
• 선택 정보: 서비스 이용 기록, 관심사''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 3
              _buildSection(
                '[개인정보의 보유 및 이용 기간]',
                '''• 서비스 이용 중단 후 즉시 회원 탈퇴 시 즉시 삭제하나, 단 법령에 따라 보존 필요 시 법정 기간 동안 보관합니다.''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 4
              _buildSection(
                '[개인정보의 제3자 제공]',
                '''고객님의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 단, 법령에 의해 요구되는 경우는 예외입니다.''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 5
              _buildSection(
                '[개인정보 보호를 위한 노력]',
                '''• 개인정보를 안전하게 보호하기 위해 암호화 및 접근 제한 조치 시행합니다.
• 개인정보 보안 정책과 직원 교육을 통해 인적요소 관리합니다.''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 6
              _buildSection(
                '[고객의 권리]',
                '''• 개인정보 조회, 수정, 삭제 요청 가능
• 개인정보 처리 문의: privacy@example.com''',
              ),
              
              const SizedBox(height: 24),
              
              // 연락처 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '저희는 고객님의 개인정보를 소중히 관리하며, 신뢰할 수 있는 서비스 제공을 위해 최선을 다하겠습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '[문의처]',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 이메일: privacy@example.com\n• 전화: 1234-5678',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}