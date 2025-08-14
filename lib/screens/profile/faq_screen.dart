import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // 각 FAQ 항목의 열림/닫힘 상태를 관리
  final Map<int, bool> _expandedStates = {};
  
  // FAQ 데이터
  final List<Map<String, String>> faqs = [
    {
      'title': '회원가입 방법',
      'content': '''회원가입은 앱 메인에서 [회원가입] 버튼을 클릭하고 필수 정보를 입력하여 간단한 인증 절차를 거쳐 완료할 수 있습니다.

1. 앱 실행 후 회원가입 선택
2. 휴대폰 번호 입력 및 인증
3. 기본 프로필 정보 입력
4. 이용약관 동의
5. 회원가입 완료

회원가입 시 문제가 있으시면 고객센터로 문의해 주세요.''',
    },
    {
      'title': '매칭 추천 인원',
      'content': '''매칭 추천 인원은 사용자의 활동 및 설정에 따라 달라집니다.

기본 추천:
• 일일 추천: 10-20명
• 프리미엄 회원: 30-50명
• 지역 및 연령대별 맞춤 추천

추천 알고리즘:
• 위치 기반 매칭
• 관심사 및 취향 분석
• 활동 패턴 고려
• 상호 호감도 분석

더 많은 추천을 원하시면 프리미엄 서비스를 이용해 보세요.''',
    },
    {
      'title': '매칭 연결 문제',
      'content': '''매칭 연결에 문제가 있을 때 해결 방법을 안내드립니다.

일반적인 해결 방법:
1. 앱 재시작
2. 네트워크 상태 확인
3. 앱 업데이트 확인
4. 기기 재부팅

지속적인 문제 발생 시:
• 스크린샷과 함께 고객센터 문의
• 오류 발생 시간 및 상황 상세 기록
• 기기 정보 (OS 버전, 앱 버전) 확인

빠른 해결을 위해 구체적인 정보 제공을 부탁드립니다.''',
    },
    {
      'title': '구독 취소 방법',
      'content': '''구독 취소는 다음과 같이 진행할 수 있습니다.

iOS (App Store):
1. 설정 > [사용자 이름] > 구독
2. 해당 앱 선택
3. 구독 취소 선택

Android (Google Play):
1. Play 스토어 > 구독
2. 해당 앱 선택
3. 구독 취소 선택

앱 내에서:
• 설정 > 구독 관리
• 구독 취소 또는 변경

취소 후에도 구독 기간 종료까지는 서비스 이용이 가능합니다.''',
    },
    {
      'title': '메시지 읽음 확인 기능',
      'content': '''메시지 읽음 확인 기능에 대해 안내드립니다.

읽음 표시 기능:
• 상대방이 메시지를 읽으면 '읽음' 표시
• 실시간 읽음 상태 업데이트
• 읽지 않은 메시지 개수 표시

개인정보 설정:
• 읽음 표시 on/off 설정 가능
• 설정 > 개인정보 > 읽음 표시

주의사항:
• 네트워크 상태에 따라 지연될 수 있음
• 상대방이 오프라인일 경우 지연 가능
• 차단된 사용자의 메시지는 읽음 표시 안됨''',
    },
    {
      'title': '개인정보 보호',
      'content': '''개인정보 보호 정책 및 관리 방법을 안내드립니다.

보호 조치:
• 개인정보 암호화 저장
• 제3자 정보 제공 금지
• 정기적인 보안 점검
• HTTPS 보안 통신

사용자 관리:
• 프로필 공개 범위 설정
• 차단 및 신고 기능
• 개인정보 수정/삭제 권한
• 서비스 탈퇴 시 정보 완전 삭제

문의사항:
개인정보 관련 문의는 privacy@example.com으로 연락해 주세요.''',
    },
    {
      'title': '매칭 추천 초기화',
      'content': '''매칭 추천을 초기화하는 방법을 안내드립니다.

초기화 방법:
1. 설정 > 매칭 설정
2. '추천 초기화' 선택
3. 확인 버튼 클릭

초기화 효과:
• 기존 추천 기록 삭제
• 새로운 추천 알고리즘 적용
• 관심사 재설정 가능
• 지역 설정 업데이트

주의사항:
• 초기화 후 되돌릴 수 없음
• 기존 매칭 및 대화는 유지
• 24시간 후 새로운 추천 시작

신중하게 결정하시기 바랍니다.''',
    },
    {
      'title': '부적절한 사용자 신고 방법',
      'content': '''부적절한 사용자를 신고하는 방법을 안내드립니다.

신고 방법:
1. 해당 사용자 프로필 접속
2. 우상단 메뉴(⋯) 선택
3. '신고하기' 선택
4. 신고 사유 선택 및 상세 내용 작성

신고 사유:
• 허위 프로필 정보
• 부적절한 사진/내용
• 스팸 메시지
• 괴롭힘/위협
• 기타 부적절한 행동

처리 과정:
• 신고 접수 후 24시간 내 검토
• 필요시 추가 조사 진행
• 위반 확인 시 제재 조치
• 신고자에게 처리 결과 안내''',
    },
    {
      'title': '문의 방법',
      'content': '''다양한 방법으로 문의하실 수 있습니다.

문의 채널:
• 앱 내 고객센터 (24시간 접수)
• 이메일: support@example.com
• 카카오톡: @서비스명 (평일 9-18시)

빠른 답변을 위한 팁:
• 구체적인 문제 상황 설명
• 스크린샷 첨부
• 기기 정보 (OS, 앱 버전) 명시
• 회원 ID 또는 등록 전화번호 포함

운영 시간:
• 평일: 09:00 ~ 18:00
• 주말/공휴일: 휴무 (자동 접수)
• 긴급 문의는 이메일로 연락

친절하고 정확한 답변을 드리겠습니다.''',
    },
  ];

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
              // FAQ 목록을 동적으로 생성
              ...faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFaqItem(
                    index,
                    faq['title']!,
                    faq['content']!,
                  ),
                );
              }),
              
              const SizedBox(height: 84),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, String title, String content) {
    final isExpanded = _expandedStates[index] ?? false;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedStates[index] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    CupertinoIcons.chevron_down,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              ),
              crossFadeState: isExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}