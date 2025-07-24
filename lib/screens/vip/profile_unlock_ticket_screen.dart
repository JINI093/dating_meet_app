import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class ProfileUnlockTicketScreen extends ConsumerStatefulWidget {
  const ProfileUnlockTicketScreen({super.key});

  @override
  ConsumerState<ProfileUnlockTicketScreen> createState() => _ProfileUnlockTicketScreenState();
}

class _ProfileUnlockTicketScreenState extends ConsumerState<ProfileUnlockTicketScreen> {
  String _selectedPackage = '10';
  
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
                    _buildPackageGrid(),
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
            '프로필 해제',
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
          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.eye_slash_fill,
              color: Color(0xFFFF5F6D),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '프로필 해제권',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '궁금한 상대방의 프로필을 자유롭게 확인하세요',
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

  Widget _buildPackageGrid() {
    final packages = [
      {'count': '10', 'price': 19900, 'discount': 0, 'originalPrice': 19900},
      {'count': '30', 'price': 49900, 'discount': 25, 'originalPrice': 59900},
      {'count': '50', 'price': 79900, 'discount': 20, 'originalPrice': 99900},
      {'count': '100', 'price': 149900, 'discount': 25, 'originalPrice': 199900},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return _buildPackageCard(
            count: package['count'] as String,
            price: package['price'] as int,
            discount: package['discount'] as int,
            originalPrice: package['originalPrice'] as int,
          );
        },
      ),
    );
  }

  Widget _buildPackageCard({
    required String count,
    required int price,
    required int discount,
    required int originalPrice,
  }) {
    final bool isSelected = _selectedPackage == count;
    
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedPackage = count),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF5F6D) : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFFFF5F6D).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.eye_slash_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        count,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (discount > 0) ...[
                  Text(
                    '${_formatPrice(originalPrice)}원',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${_formatPrice(price)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF357B),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: Color(0xFFFF5F6D),
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (discount > 0)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF357B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$discount%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
            '프로필 해제권 특징',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: CupertinoIcons.eye_fill,
            title: '프로필 전체 확인',
            description: '모든 사진과 정보를 자유롭게 확인할 수 있습니다',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.heart_fill,
            title: '매칭 확률 증가',
            description: '상대방을 더 잘 알고 접근할 수 있습니다',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.info_circle_fill,
            title: '상세 정보 열람',
            description: '취미, 관심사, 직업 등 상세 정보를 확인하세요',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.time,
            title: '즉시 사용 가능',
            description: '구매 후 바로 사용할 수 있습니다',
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
              color: const Color(0xFFFF5F6D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF5F6D),
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
    final selectedPackageData = _getPackageData(_selectedPackage);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _processPurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5F6D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            '${_formatPrice(selectedPackageData['price'])}원 결제하기',
            style: AppTextStyles.buttonLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPackageData(String count) {
    switch (count) {
      case '10':
        return {'count': '10', 'price': 19900, 'discount': 0};
      case '30':
        return {'count': '30', 'price': 49900, 'discount': 25};
      case '50':
        return {'count': '50', 'price': 79900, 'discount': 20};
      case '100':
        return {'count': '100', 'price': 149900, 'discount': 25};
      default:
        return {'count': '10', 'price': 19900, 'discount': 0};
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match.group(1)},',
    );
  }

  void _processPurchase() {
    final packageData = _getPackageData(_selectedPackage);
    
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
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5F6D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.eye_slash_fill,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '프로필 해제권 ${packageData['count']}개 구매',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${packageData['count']}개의 프로필 해제권을 구매하시겠습니까?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (packageData['discount'] > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${packageData['discount']}% 할인 적용!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFFF5F6D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                      backgroundColor: const Color(0xFFFF5F6D),
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
    final packageData = _getPackageData(_selectedPackage);
    
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
              '프로필 해제권 ${packageData['count']}개가\n성공적으로 구매되었습니다.',
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
                  backgroundColor: const Color(0xFFFF5F6D),
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