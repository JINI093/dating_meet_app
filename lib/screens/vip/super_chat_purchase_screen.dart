import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/points_provider.dart';

class SuperChatPurchaseScreen extends ConsumerStatefulWidget {
  const SuperChatPurchaseScreen({super.key});

  @override
  ConsumerState<SuperChatPurchaseScreen> createState() => _SuperChatPurchaseScreenState();
}

class _SuperChatPurchaseScreenState extends ConsumerState<SuperChatPurchaseScreen> {
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
            '슈퍼챗',
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
          colors: [Color(0xFF3FE37F), Color(0xFF1CB5E0)],
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
              CupertinoIcons.paperplane_fill,
              color: Color(0xFF3FE37F),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '슈퍼챗 구매',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '특별한 메시지로 상대방의 관심을 끌어보세요',
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
      {'count': '10', 'price': 9900, 'bonus': 0, 'bonusPercent': 0},
      {'count': '30', 'price': 27900, 'bonus': 5, 'bonusPercent': 17},
      {'count': '50', 'price': 44900, 'bonus': 10, 'bonusPercent': 20},
      {'count': '100', 'price': 79900, 'bonus': 25, 'bonusPercent': 25},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return _buildPackageCard(
            count: package['count'] as String,
            price: package['price'] as int,
            bonus: package['bonus'] as int,
            bonusPercent: package['bonusPercent'] as int,
          );
        },
      ),
    );
  }

  Widget _buildPackageCard({
    required String count,
    required int price,
    required int bonus,
    required int bonusPercent,
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
                color: isSelected ? const Color(0xFF3FE37F) : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF3FE37F).withValues(alpha: 0.3),
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
                      colors: [Color(0xFF3FE37F), Color(0xFF1CB5E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.chat_bubble_2_fill,
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
                if (bonus > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3FE37F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+$bonus개 보너스',
                      style: const TextStyle(
                        color: Color(0xFF3FE37F),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    color: Color(0xFF3FE37F),
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (bonusPercent > 0)
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
                '$bonusPercent%',
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
            '슈퍼챗 특징',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: CupertinoIcons.star_circle_fill,
            title: '우선 전달',
            description: '일반 메시지보다 먼저 상대방에게 전달됩니다',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.eye_fill,
            title: '읽음 확인',
            description: '상대방이 메시지를 읽었는지 확인할 수 있습니다',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.heart_fill,
            title: '관심 어필',
            description: '진심이 담긴 메시지로 관심을 어필하세요',
          ),
          _buildBenefitItem(
            icon: CupertinoIcons.chart_bar_circle_fill,
            title: '응답률 증가',
            description: '일반 메시지보다 3배 높은 응답률을 보여줍니다',
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
              color: const Color(0xFF3FE37F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3FE37F),
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
            backgroundColor: const Color(0xFF3FE37F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            '${selectedPackageData['points']}P로 구매하기',
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
        return {'count': 10, 'points': 90, 'bonus': 0};
      case '30':
        return {'count': 30, 'points': 250, 'bonus': 5};
      case '50':
        return {'count': 50, 'points': 400, 'bonus': 10};
      case '100':
        return {'count': 100, 'points': 750, 'bonus': 25};
      default:
        return {'count': 10, 'points': 90, 'bonus': 0};
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
    final pointsState = ref.read(pointsProvider);
    final requiredPoints = packageData['points'] as int;
    final chatCount = packageData['count'] as int;
    final bonusPercent = packageData['bonus'] as int;

    // 포인트 부족 확인
    if (!pointsState.canSpend(requiredPoints)) {
      _showInsufficientPointsDialog(requiredPoints, pointsState.currentPoints);
      return;
    }

    // 슈퍼챗 구매 확인 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(
          '슈퍼챗 ${chatCount}개 구매',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3FE37F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '슈퍼챗 ${chatCount}개를 구매하시겠습니까?',
              style: AppTextStyles.bodyMedium,
            ),
            if (bonusPercent > 0) ...[
              const SizedBox(height: 8),
              Text(
                '보너스 ${bonusPercent}% 추가 제공!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF3FE37F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('필요 포인트:', style: AppTextStyles.bodyMedium),
                Text('${requiredPoints}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보유 포인트:', style: AppTextStyles.bodyMedium),
                Text('${pointsState.currentPoints}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('구매 후 잔액:', style: AppTextStyles.bodyMedium),
                Text('${pointsState.currentPoints - requiredPoints}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.textSecondary,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processSuperChatPurchase(chatCount, requiredPoints, bonusPercent);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3FE37F),
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Text('구매', style: AppTextStyles.buttonMedium.copyWith(
              fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  void _showInsufficientPointsDialog(int required, int current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(
          '포인트 부족',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '슈퍼챗 구매를 위한 포인트가 부족합니다.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('필요 포인트:', style: AppTextStyles.bodyMedium),
                Text('${required}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보유 포인트:', style: AppTextStyles.bodyMedium),
                Text('${current}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('부족 포인트:', style: AppTextStyles.bodyMedium),
                Text('${required - current}P', style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.textSecondary,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 포인트 상점으로 이동
              Navigator.of(context).pushNamed('/point-shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Text('포인트 구매', style: AppTextStyles.buttonMedium.copyWith(
              fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  Future<void> _processSuperChatPurchase(int chatCount, int points, int bonusPercent) async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3FE37F)),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text('슈퍼챗 구매 중...', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );

    try {
      // 포인트 차감
      final success = await ref.read(pointsProvider.notifier).spendForSuperchat(points);

      if (success) {
        // 슈퍼챗 추가 (보너스 포함) - 기존 SuperChat 시스템 연동
        final totalChats = chatCount + (chatCount * bonusPercent ~/ 100);
        // await ref.read(superChatProvider.notifier).addSuperChats(totalChats);

        if (!mounted) return;
        
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        // 성공 다이얼로그
        _showPurchaseSuccess(totalChats, points);
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        _showPurchaseError('슈퍼챗 구매에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      _showPurchaseError(e.toString());
    }
  }

  void _showPurchaseSuccess(int totalChats, int points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF3FE37F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.paperplane_fill,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '슈퍼챗 구매 완료!',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3FE37F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalChats}개의 슈퍼챗을 받았습니다.',
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // 슈퍼챗 구매 화면도 닫기
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FE37F),
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
          ],
        ),
      ),
    );
  }

  void _showPurchaseError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(
          '구매 실패',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}