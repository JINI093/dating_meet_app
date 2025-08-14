import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});
  
  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // 각 공지사항의 열림/닫힘 상태를 관리
  final Map<int, bool> _expandedStates = {};
  
  // 공지사항 데이터
  final List<Map<String, String>> notices = [
    {
      'title': '[중요] 고객 상담 운영 시간 안내',
      'content': '''안녕하세요, 고객님!

항상 저희 서비스를 이용해 주셔서 감사합니다. 😊
상담 운영 시간은 아래와 같이 진행됩니다:

• 운영 시간: 평일 오전 9시 ~ 오후 6시
• 휴무 안내: 주말 및 공휴일에는 상담이 제한되며, 접수된 문의는 익일 업무 시간에 순차적으로 답변드립니다.

상담 채널
• 카카오톡: 친구 추가 후 메시지 남기기
• 이메일: support@example.com

문의할 종류 시 답변이 다소 지연될 수 있는 점 양해 부탁드립니다. 항상 빠르고 정확한 답변을 드리기 위해 최선을 다하겠습니다.

감사합니다! 😊''',
    },
    {
      'title': '상담 서비스 이용 가이드',
      'content': '''상담 서비스를 이용하실 때 참고하실 사항입니다.

1. 상담 전 준비사항
• 회원 ID 또는 등록된 전화번호
• 문의 내용을 구체적으로 정리

2. 자주 묻는 질문
• 결제 관련: 결제 내역, 환불 절차
• 계정 관련: 비밀번호 찾기, 계정 복구
• 서비스 관련: 이용 방법, 오류 해결

3. 빠른 답변을 위한 팁
• 스크린샷 첨부하기
• 오류 발생 시간 명시하기
• 구체적인 상황 설명하기''',
    },
    {
      'title': '카카오톡 상담 지원 안내 (공휴일 포함)',
      'content': '''카카오톡 상담 채널이 개설되었습니다!

카카오톡 친구 추가 방법:
1. 카카오톡 실행
2. 친구 검색에서 "서비스명" 검색
3. 플러스 친구 추가
4. 1:1 채팅으로 문의

장점:
• 실시간 상담 가능
• 이미지 첨부 편리
• 대화 내역 보관

운영 시간:
• 평일: 09:00 ~ 18:00
• 주말/공휴일: 휴무 (자동 응답 안내)''',
    },
    {
      'title': '[신규] 제휴 및 협업 문의 전용 이메일 안내',
      'content': '''비즈니스 제휴 및 협업 문의를 위한 전용 채널을 안내드립니다.

제휴 문의: partnership@example.com

문의 시 포함 내용:
• 회사/단체명
• 담당자 성함 및 연락처
• 제휴 제안 내용
• 기대 효과

처리 절차:
1. 이메일 접수
2. 내부 검토 (영업일 기준 3-5일)
3. 담당자 배정 및 연락
4. 상세 협의 진행

일반 고객 문의는 support@example.com으로 보내주시기 바랍니다.''',
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
          '공지사항',
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
              // 공지사항 목록을 동적으로 생성
              ...notices.asMap().entries.map((entry) {
                final index = entry.key;
                final notice = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNoticeItem(
                    index,
                    notice['title']!,
                    notice['content']!,
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

  Widget _buildNoticeItem(int index, String title, String content) {
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