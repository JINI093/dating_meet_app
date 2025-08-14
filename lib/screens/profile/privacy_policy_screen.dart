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
    • 맞춤형 서비스 제공
    • 서비스 개선 및 통계 분석''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 2
              _buildSection(
                '[수집하는 개인정보의 항목]',
                '''1. 필수 정보:
    • 이름, 연락처(이메일/전화번호)
    • 아이디, 비밀번호
    • 생년월일, 성별
    • 프로필 사진 및 자기소개

2. 선택 정보:
    • 서비스 이용 기록
    • 관심사 및 취향 정보
    • 기기 정보 및 접속 로그''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 3
              _buildSection(
                '[개인정보의 보유 및 이용 기간]',
                '''1. 회원 탈퇴 시:
    • 즉시 삭제 원칙
    • 단, 법령에 따라 보존 필요 시 법정 기간 동안 보관

2. 법정 보관 기간:
    • 계약 또는 청약철회 기록: 5년
    • 대금결제 및 재화 공급 기록: 5년
    • 소비자 불만 또는 분쟁처리 기록: 3년
    • 표시/광고 기록: 6개월''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 4
              _buildSection(
                '[개인정보의 제3자 제공]',
                '''원칙:
    • 고객님의 동의 없이 개인정보를 제3자에게 제공하지 않습니다.

예외 사항:
    • 법령에 의해 요구되는 경우
    • 수사기관의 수사목적으로 법령에 정해진 절차에 따라 요구받는 경우
    • 기타 법에 의해 요구되는 경우

제공 시 안내:
    • 제공받는 자 및 제공 목적
    • 제공하는 개인정보 항목
    • 보유 및 이용 기간''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 5
              _buildSection(
                '[개인정보 보호를 위한 노력]',
                '''1. 기술적 보안 조치:
    • 개인정보 암호화 저장 및 전송
    • 방화벽 및 침입탐지시스템 운영
    • 접근권한 관리 및 접근통제시스템 운영
    • 개인정보 취급시스템 접근기록 보관

2. 관리적 보안 조치:
    • 개인정보 보호정책 수립 및 시행
    • 직원 대상 개인정보 보호 교육
    • 개인정보 접근권한의 최소화
    • 개인정보 처리 현황 점검 및 감사''',
              ),
              
              const SizedBox(height: 24),
              
              // 섹션 6
              _buildSection(
                '[고객의 권리]',
                '''고객님은 언제든지 다음과 같은 권리를 행사하실 수 있습니다:

1. 개인정보 처리 현황에 대한 열람 요구
2. 오류 등이 있을 경우 정정·삭제 요구
3. 처리정지 요구

권리 행사 방법:
    • 온라인: 서비스 내 개인정보 관리 메뉴
    • 이메일: privacy@example.com
    • 전화: 1234-5678 (평일 9시~18시)

처리 기간:
    • 요청 접수 후 10일 이내 처리
    • 부득이한 사유 시 10일 연장 가능 (사전 통지)''',
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
                      '    • 이메일: privacy@example.com\n    • 전화: 1234-5678 (평일 9시~18시)\n    • 주소: 서울특별시 강남구 테헤란로 123',
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