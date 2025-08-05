import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../point/ticket_shop_screen.dart';

/// VIP 소개 및 구매 안내 화면
/// 비VIP 사용자가 VIP 아이콘을 눌렀을 때 표시되는 화면
class VipIntroScreen extends ConsumerWidget {
  const VipIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'VIP 멤버십',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // VIP 로고
              Image.asset(
                'assets/icons/VIP Frame.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.white,
                      size: 60,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'VIP 멤버십으로\n특별한 만남을 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // VIP 혜택 리스트
              _buildBenefitItem(
                icon: CupertinoIcons.eye_fill,
                title: 'VIP 전용 프로필 열람',
                description: '프리미엄 회원들과의 특별한 만남',
                color: const Color(0xFFFFD700),
              ),
              
              const SizedBox(height: 20),
              
              _buildBenefitItem(
                icon: CupertinoIcons.star_circle_fill,
                title: '프로필 우선 노출',
                description: '상대방 추천 목록 상단에 우선 표시',
                color: const Color(0xFF4CAF50),
              ),
              
              const SizedBox(height: 20),
              
              _buildBenefitItem(
                icon: CupertinoIcons.heart_fill,
                title: '무제한 좋아요',
                description: '하루 제한 없이 마음껏 좋아요 전송',
                color: const Color(0xFFE91E63),
              ),
              
              const SizedBox(height: 20),
              
              _buildBenefitItem(
                icon: CupertinoIcons.chat_bubble_fill,
                title: '슈퍼챗 할인',
                description: 'VIP 회원 전용 슈퍼챗 할인 혜택',
                color: const Color(0xFF2196F3),
              ),
              
              const SizedBox(height: 60),
              
              // 구매 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _goToVipPurchase(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VIP 멤버십 시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 부가 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle_fill,
                          color: Color(0xFF666666),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'VIP 멤버십 안내',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• VIP 멤버십은 구매 후 즉시 적용됩니다.\n'
                      '• 모든 혜택은 구매한 기간 내에만 유효합니다.\n'
                      '• 자동 갱신 설정을 통해 편리하게 이용하세요.',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToVipPurchase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TicketShopScreen(initialTabIndex: 4),
      ),
    );
  }
}