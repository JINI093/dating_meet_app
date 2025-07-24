import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class VipMembershipScreen extends ConsumerStatefulWidget {
  const VipMembershipScreen({super.key});

  @override
  ConsumerState<VipMembershipScreen> createState() => _VipMembershipScreenState();
}

class _VipMembershipScreenState extends ConsumerState<VipMembershipScreen> {
  String _selectedTier = 'GOLD';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildVipTiers(),
                    const SizedBox(height: 32),
                    _buildBenefits(),
                    const SizedBox(height: 32),
                    _buildPurchaseButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: AppDimensions.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              CupertinoIcons.chevron_left,
              color: AppColors.textPrimary,
              size: AppDimensions.iconM,
            ),
          ),
          const Spacer(),
          Text(
            'VIP',
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/crown.png',
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) => const Icon(
              CupertinoIcons.star_circle_fill,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'VIP 멤버십',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '특별한 혜택과 함께 더 많은 만남을 경험하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVipTiers() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTierCard(
            tier: 'GOLD',
            title: '골드 멤버십',
            duration: '30일',
            originalPrice: 29900,
            discountPrice: 19900,
            discountPercent: 33,
            color: const Color(0xFFFFD700),
            isPopular: true,
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            tier: 'SILVER',
            title: '실버 멤버십',
            duration: '14일',
            originalPrice: 19900,
            discountPrice: 14900,
            discountPercent: 25,
            color: const Color(0xFFC0C0C0),
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            tier: 'BRONZE',
            title: '브론즈 멤버십',
            duration: '7일',
            originalPrice: 12900,
            discountPrice: 9900,
            discountPercent: 23,
            color: const Color(0xFFCD7F32),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String tier,
    required String title,
    required String duration,
    required int originalPrice,
    required int discountPrice,
    required int discountPercent,
    required Color color,
    bool isPopular = false,
  }) {
    final bool isSelected = _selectedTier == tier;
    
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedTier = tier),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: color,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$duration 이용권',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${_formatPrice(originalPrice)}원',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_formatPrice(discountPrice)}원',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF357B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: -8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF357B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '인기',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: -8,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$discountPercent% 할인',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIP 멤버십 혜택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: CupertinoIcons.eye,
            title: '무제한 프로필 열람',
            description: '모든 프로필을 자유롭게 확인하세요',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.heart_fill,
            title: '무제한 좋아요',
            description: '마음에 드는 상대에게 좋아요를 보내세요',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.paperplane_fill,
            title: '슈퍼챗 할인',
            description: '슈퍼챗 발송 시 30% 할인 혜택',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.star_circle_fill,
            title: '프로필 우선 노출',
            description: '상대방에게 먼저 보여집니다',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final selectedTierData = _getTierData(_selectedTier);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _processPurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF357B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            '${_formatPrice(selectedTierData['discountPrice'])}원 결제하기',
            style: AppTextStyles.buttonLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTierData(String tier) {
    switch (tier) {
      case 'GOLD':
        return {
          'title': '골드 멤버십',
          'duration': '30일',
          'originalPrice': 29900,
          'discountPrice': 19900,
          'discountPercent': 33,
        };
      case 'SILVER':
        return {
          'title': '실버 멤버십',
          'duration': '14일',
          'originalPrice': 19900,
          'discountPrice': 14900,
          'discountPercent': 25,
        };
      case 'BRONZE':
        return {
          'title': '브론즈 멤버십',
          'duration': '7일',
          'originalPrice': 12900,
          'discountPrice': 9900,
          'discountPercent': 23,
        };
      default:
        return {
          'title': '골드 멤버십',
          'duration': '30일',
          'originalPrice': 29900,
          'discountPrice': 19900,
          'discountPercent': 33,
        };
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match.group(1)},',
    );
  }

  void _processPurchase() {
    final tierData = _getTierData(_selectedTier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.star_circle_fill,
              color: Color(0xFFFFD700),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              '${tierData['title']} 구매',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${tierData['duration']} 이용권을 구매하시겠습니까?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPurchaseSuccess();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF357B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '구매',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseSuccess() {
    final tierData = _getTierData(_selectedTier);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppColors.success,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              '구매 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${tierData['title']} ${tierData['duration']} 이용권이\n성공적으로 구매되었습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF357B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}