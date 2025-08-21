import 'package:dating_app_40s/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/points_provider.dart';
import '../../providers/purchase_provider.dart';

class PointShopScreen extends ConsumerStatefulWidget {
  const PointShopScreen({super.key});

  @override
  ConsumerState<PointShopScreen> createState() => _PointShopScreenState();
}

class _PointShopScreenState extends ConsumerState<PointShopScreen> {
  PageController? _pageController;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Force refresh points when entering point shop
        ref.read(pointsProvider.notifier).refreshPoints();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointsState = ref.watch(pointsProvider);
    final currentPoints = pointsState.currentPoints;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(),
              _buildPointsHeader(currentPoints),
              _buildPointsIntro(),
              _buildPointPackages(),
            ],
          ),
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.home);
              }
            },
            icon: const Icon(
              CupertinoIcons.chevron_left,
              color: Colors.black,
              size: 24,
            ),
          ),
          const Spacer(),
          const Text(
            '포인트 상점',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance space
        ],
      ),
    );
  }

  Widget _buildPointsHeader(int currentPoints) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '포인트',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              Image.asset(
                'assets/icons/coin.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '●',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '$currentPoints',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFA726),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsIntro() {
    final bannerData = [
      {
        'emoji': '👀',
        'title': '이용권을 맘껏 열람하세요!',
        'subtitle': '회원님은 프로필을 마음껏 확인할 수 있습니다.',
      },
      {
        'emoji': '💝',
        'title': '특별한 혜택을 누리세요!',
        'subtitle': '포인트로 다양한 기능을 이용해보세요.',
      },
      {
        'emoji': '✨',
        'title': '더 많은 매칭 기회를!',
        'subtitle': '포인트로 더 많은 사람들과 만나보세요.',
      },
      {
        'emoji': '🎁',
        'title': '보너스 포인트까지!',
        'subtitle': '패키지 구매시 추가 포인트를 받으세요.',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '구매혜택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController ?? PageController(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: bannerData.length,
              itemBuilder: (context, index) {
                final banner = bannerData[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        banner['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
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
              },
            ),
          ),
          const SizedBox(height: 16),
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(bannerData.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? const Color(0xFFFF357B) 
                      : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPointPackages() {
    final packageList = [
      {'points': 50, 'price': 5000,},
      {'points': 100,'price': 10000,},
      {'points': 300, 'bonusPoints': 6, 'price': 30000, 'bonusPercent': 2},
      {'points': 500, 'bonusPoints': 25, 'price': 50000, 'bonusPercent': 5},
      {'points': 1000, 'bonusPoints': 80, 'price': 100000, 'bonusPercent': 8},
      {'points': 1500, 'bonusPoints': 150, 'price': 150000, 'bonusPercent': 10},
      {'points': 2000, 'bonusPoints': 240, 'price': 200000, 'bonusPercent': 12},
      {'points': 3000, 'bonusPoints': 450, 'price': 300000, 'bonusPercent': 15},
      {'points': 5000, 'bonusPoints': 900, 'price': 500000, 'bonusPercent': 18},
      {'points': 8000, 'bonusPoints': 1600, 'price': 800000, 'bonusPercent': 20},
      {'points': 10000, 'bonusPoints': 2500, 'price': 1000000, 'bonusPercent': 25},
      {'points': 20000, 'bonusPoints': 6000, 'price': 2000000, 'bonusPercent': 30},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          for (int i = 0; i < packageList.length; i += 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int j = 0; j < 3 && i + j < packageList.length; j++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: j == 1 ? 8 : 4),
                        child: _buildPointPackage(
                          points: packageList[i + j]['points'] as int,
                          bonusPoints: packageList[i + j]['bonusPoints'] as int? ?? 0,
                          price: packageList[i + j]['price'] as int,
                          bonusPercent: packageList[i + j]['bonusPercent'] as int? ?? 0,
                          imagePath: 'assets/point/${i + j + 1}.png',
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPointPackage({
    required int points,
    required int bonusPoints,
    required int price,
    required int bonusPercent,
    required String imagePath,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _showPurchaseConfirmation(points, bonusPoints, price, bonusPercent),
          child: Container(
            height: 160, // 모든 박스의 높이를 통일
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단 이미지 영역
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    imagePath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: Color(0xFFFFA726),
                      size: 48,
                    ),
                  ),
                ),
                // 포인트 표시
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+${points}P',
                          style: const TextStyle(
                            color: Color(0xFFFF357B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (bonusPoints > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF357B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${bonusPoints}P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // 하단 가격 영역
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF357B),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Text(
                    '${_formatPriceWithComma(price)}원',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 추가 증정 라벨
        if (bonusPercent > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF357B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$bonusPercent% 추가 증정',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatPriceWithComma(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match.group(1)},',
    );
  }

  void _showPurchaseConfirmation(int points, int bonusPoints, int price, int bonusPercent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Points display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${points}P',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (bonusPoints > 0) ...[
                  const SizedBox(width: AppDimensions.spacing8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing8,
                      vertical: AppDimensions.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '+${bonusPoints}P',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: AppDimensions.spacing16),
            
            Text(
              '구매하시겠습니까?',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing24),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.textHint,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      ),
                    ),
                    child: Text(
                      '아니요',
                      style: AppTextStyles.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop(); // 다이얼로그만 닫기
                      // 인앱결제로 바로 연결
                      _purchasePointsWithInApp(points, bonusPoints, price);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      ),
                    ),
                    child: Text(
                      '예',
                      style: AppTextStyles.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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

  /// 인앱결제로 포인트 구매
  Future<void> _purchasePointsWithInApp(int points, int bonusPoints, int price) async {
    // 인앱결제용 제품 ID 생성 (포인트 수량 기준으로)
    String productId;
    if (points <= 100) {
      productId = 'dating_points_100';
    } else if (points <= 500) {
      productId = 'dating_points_500'; 
    } else if (points <= 1000) {
      productId = 'dating_points_1000';
    } else if (points <= 3000) {
      productId = 'dating_points_3000';
    } else {
      productId = 'dating_points_5000';
    }

    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text('결제 처리 중...', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );

      // PurchaseProvider를 통해 인앱결제 시작
      final success = await ref.read(purchaseProvider.notifier).purchaseProduct(productId);
      
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // 구매 성공 - PurchaseProvider에서 자동으로 포인트가 추가됨
        if (mounted) {
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
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '구매 완료!',
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${points + bonusPoints}P가 추가되었습니다.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        // 구매 실패
        if (mounted) {
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
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '구매 실패',
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '결제를 완료할 수 없습니다.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      // 오류 처리
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
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
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류 발생',
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '결제 처리 중 오류가 발생했습니다.\n$e',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

}