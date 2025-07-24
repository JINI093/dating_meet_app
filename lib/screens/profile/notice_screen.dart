import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

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
              // 첫 번째 공지사항
              _buildNoticeItem(
                '[중요] 고객 상담 운영 시간 안내',
                '''안녕하세요, 고객님!

항상 저희 서비스를 이용해 주셔서 감사합니다. 😊
상담 운영 시간은 아래와 같이 진행됩니다:

• 운영 시간: 평일 오전 9시 ~ 오후 6시
• 휴무 안내: 주말 및 공휴일에는 상담이 제한되며, 접수된 문의는 익일 업무 시간에 순차적으로 답변드립니다.

상담 채널
• 카카오톡: 친구 추가 후 메시지 남기기
• 이메일: support@example.com

문의할 종류 시 답변이 다소 지연될 수 있는 점 양해 부탁드립니다. 항상 빠르고 정확한 답변을 드리기 위해 최선을 다하겠습니다.

감사합니다! 😊''',
              ),
              
              const SizedBox(height: 16),
              
              // 나머지 공지사항들
              _buildNoticeItem('상담 서비스 이용 가이드'),
              const SizedBox(height: 16),
              _buildNoticeItem('카카오톡 상담 지원 안내 (공휴일 포함)'),
              const SizedBox(height: 16),
              _buildNoticeItem('[신규] 제휴 및 협업 문의 전용 이메일 안내'),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String title, [String? content]) {
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