import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ReferralCodeScreen extends StatelessWidget {
  const ReferralCodeScreen({super.key});

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
          '추천인 코드 확인',
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
              const SizedBox(height: 20),
              
              // 안내 메시지
              const Text(
                '회원가입 시 친구 추천 코드를 입력하시면',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              
              // 메인 타이틀과 동전 아이콘
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(text: '본인과 친구 모두에게\n'),
                              TextSpan(text: '약 '),
                              TextSpan(
                                text: '6천원',
                                style: TextStyle(color: Color(0xFFFF357B)),
                              ),
                              TextSpan(text: ' 상당의 '),
                              TextSpan(
                                text: '60P',
                                style: TextStyle(color: Color(0xFFFF357B)),
                              ),
                              TextSpan(text: '를\n적립해 드립니다!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/icons/coins.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          CupertinoIcons.money_dollar_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 추천인 코드 박스
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFB347),
                      Color(0xFFFF8C00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 내 추천인 코드 제목
                    Container(
                      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
                      child: const Text(
                        '내 추천인 코드',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // 코드 입력 박스
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'HX5EQ2',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context, 'HX5EQ2'),
                            child: const Text(
                              '복사하기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 친구에게 카카오톡 공유하기 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _shareToKakaoTalk(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '친구에게 카카오톡 공유하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3C1E1E),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chat_bubble_fill,
                            color: Color(0xFFFEE500),
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 참여방법 섹션
              const Text(
                '참여방법',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildMethodStep('1', '친구에게 초대 링크를 공유하세요.'),
              _buildMethodStep('2', '친구가 초대 링크를 누르고 이벤트 다운 받습니다.'),
              _buildMethodStep('3', '회원가입시 받은 추천인 코드를 입력하면 가입완료 되면서 지급됩니다.'),
              
              const SizedBox(height: 32),
              
              // 안내사항 섹션
              const Text(
                '안내사항',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildNoticeItem('1', '기입시 초대프로를 입력하지 못했을 경우 프로필 정보 수정에서 입력이 가능합니다.'),
              _buildNoticeItem('2', '한번 입력한 초대한 코드는 수정이 불가능합니다.'),
              _buildNoticeItem('3', '비정상적인 방법으로 가입을 활용한 경우 획득한 포인트는 전체 회수되며 계정 영구 정지가 될 수 있습니다.'),
              _buildNoticeItem('4', '친구 초대 이벤트는 당사의 사정에 따라 사전 고지 없이 변경 또는 종료될 수 있습니다.'),
              _buildNoticeItem('5', '초대로 가입한 친구가 사용별 서비스에 가입하였을 때는 친구 추천 적립이 되지 않습니다.'),
              _buildNoticeItem('6', '만 40세 미만의 연구는 참여할 수 없습니다.'),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodStep(String number, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String number, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('추천인 코드가 클립보드에 복사되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareToKakaoTalk(BuildContext context) {
    // TODO: 카카오톡 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('카카오톡 공유 기능이 곧 추가될 예정입니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}