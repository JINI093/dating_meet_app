import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/points_provider.dart';
import '../../providers/vip_provider.dart';
import '../../models/vip_model.dart';

enum VipTier { gold, silver, bronze }

class VipPurchaseScreen extends ConsumerStatefulWidget {
  const VipPurchaseScreen({super.key});

  @override
  ConsumerState<VipPurchaseScreen> createState() => _VipPurchaseScreenState();
}

class _VipPurchaseScreenState extends ConsumerState<VipPurchaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VipTier selectedTier = VipTier.gold;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTier = VipTier.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'VIP 이용권',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 탭 메뉴 (좌우 여백 삭제)
          Container(
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.h4,
              tabs: const [
                Tab(text: 'GOLD'),
                Tab(text: 'SILVER'),
                Tab(text: 'BRONZE'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTierContent(VipTier.gold),
                _buildTierContent(VipTier.silver),
                _buildTierContent(VipTier.bronze),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierContent(VipTier tier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // VIP 프레임 이미지
          _buildVipFrame(tier),
          
          const SizedBox(height: 30),
          
          // 티어 선택 버튼
          _buildTierSelector(tier),
          
          const SizedBox(height: 30),
          
          // 상품 카드들
          _buildProductCards(tier),
        ],
      ),
    );
  }

  Widget _buildVipFrame(VipTier tier) {
    String flameAsset;
    String tierText;
    
    switch (tier) {
      case VipTier.gold:
        flameAsset = 'assets/vip/Gold_flame.png';
        tierText = 'VIP GOLD';
        break;
      case VipTier.silver:
        flameAsset = 'assets/vip/Silver_flame.png';
        tierText = 'VIP SILVER';
        break;
      case VipTier.bronze:
        flameAsset = 'assets/vip/Bronze_flame.png';
        tierText = 'VIP BRONZE';
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          flameAsset,
          width: 300,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: _getTierColor(tier).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getTierColor(tier), width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tierText,
                      style: AppTextStyles.h2.copyWith(
                        color: _getTierColor(tier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '15일 남음',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _getTierColor(tier),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTierSelector(VipTier tier) {
    final isSelected = selectedTier == tier;
    String buttonAsset;
    
    switch (tier) {
      case VipTier.gold:
        buttonAsset = isSelected ? 'assets/vip/BS_gold.png' : 'assets/vip/B_gold.png';
        break;
      case VipTier.silver:
        buttonAsset = isSelected ? 'assets/vip/BS_silver.png' : 'assets/vip/B_silver.png';
        break;
      case VipTier.bronze:
        buttonAsset = isSelected ? 'assets/vip/BS_bronze.png' : 'assets/vip/B_bronze.png';
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTier = tier;
        });
        _tabController.animateTo(tier.index);
      },
      child: Image.asset(
        buttonAsset,
        width: 120,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? _getTierColor(tier) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _getTierColor(tier), width: 2),
            ),
            child: Center(
              child: Text(
                tier.name.toUpperCase(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? Colors.white : _getTierColor(tier),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCards(VipTier tier) {
    final products = _getProductsForTier(tier);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(tier, products[index]);
      },
    );
  }

  Widget _buildProductCard(VipTier tier, Map<String, dynamic> product) {
    String cardAsset;
    final days = product['days'] as int;
    
    switch (tier) {
      case VipTier.gold:
        cardAsset = 'assets/vip/G$days.png';
        break;
      case VipTier.silver:
        cardAsset = 'assets/vip/S$days.png';
        break;
      case VipTier.bronze:
        cardAsset = 'assets/vip/B$days.png';
        break;
    }

    return GestureDetector(
      onTap: () => _onProductSelected(tier, product),
      child: Image.asset(
        cardAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: _getTierColor(tier).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getTierColor(tier), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 40,
                  color: _getTierColor(tier),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product['days']}일',
                  style: AppTextStyles.h4.copyWith(
                    color: _getTierColor(tier),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product['points']}P',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getTierColor(tier),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getTierColor(VipTier tier) {
    switch (tier) {
      case VipTier.gold:
        return const Color(0xFFFFD700);
      case VipTier.silver:
        return const Color(0xFFC0C0C0);
      case VipTier.bronze:
        return const Color(0xFFCD7F32);
    }
  }

  List<Map<String, dynamic>> _getProductsForTier(VipTier tier) {
    switch (tier) {
      case VipTier.gold:
        return [
          {'days': 7, 'points': 990},
          {'days': 15, 'points': 1990},
          {'days': 30, 'points': 3990},
          {'days': 90, 'points': 9990},
        ];
      case VipTier.silver:
        return [
          {'days': 7, 'points': 790},
          {'days': 15, 'points': 1590},
          {'days': 30, 'points': 2990},
          {'days': 90, 'points': 7990},
        ];
      case VipTier.bronze:
        return [
          {'days': 7, 'points': 490},
          {'days': 15, 'points': 990},
          {'days': 30, 'points': 1990},
          {'days': 90, 'points': 4990},
        ];
    }
  }

  void _onProductSelected(VipTier tier, Map<String, dynamic> product) {
    final pointsState = ref.read(pointsProvider);
    final requiredPoints = product['points'] as int;
    final days = product['days'] as int;

    // 포인트 부족 확인
    if (!pointsState.canSpend(requiredPoints)) {
      _showInsufficientPointsDialog(requiredPoints, pointsState.currentPoints);
      return;
    }

    // VIP 구매 확인 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(
          'VIP ${tier.name.toUpperCase()} ${days}일',
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: _getTierColor(tier),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIP ${tier.name.toUpperCase()} 멤버십 ${days}일을 구매하시겠습니까?',
              style: AppTextStyles.bodyMedium,
            ),
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
              _processPurchase(tier, days, requiredPoints);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
              '포인트가 부족합니다.',
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

  Future<void> _processPurchase(VipTier tier, int days, int points) async {
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text('VIP 구매 중...', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );

    try {
      // 포인트 차감 및 VIP 활성화
      final success = await ref.read(pointsProvider.notifier).spendForVip(
        points,
        tier.name.toUpperCase(),
      );

      if (success) {
        // VIP 활성화 (VIP Provider 사용)
        final vipPlan = VipPlan(
          id: '${tier.name.toLowerCase()}_${days}d',
          name: 'VIP ${tier.name.toUpperCase()}',
          description: 'VIP ${tier.name.toUpperCase()} ${days}일 멤버십',
          durationDays: days,
          originalPrice: points,
          discountPrice: points, // 이미 포인트로 결제됨
          discountPercent: 0,
          features: [
            '무제한 좋아요',
            '프로필 노출 증가',
            '읽음 확인',
            '나를 좋아요한 사람 확인',
          ],
          type: days >= 30 ? VipPlanType.monthly : VipPlanType.weekly,
        );
        
        await ref.read(vipProvider.notifier).purchaseVipPlan(vipPlan);

        if (!mounted) return;
        
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        // 성공 다이얼로그
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
                Icon(
                  Icons.workspace_premium,
                  color: _getTierColor(tier),
                  size: 64,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'VIP ${tier.name.toUpperCase()} 구매 완료!',
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTierColor(tier),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  '${days}일간 VIP 혜택을 누려보세요!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // VIP 구매 화면도 닫기
                    },
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
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        // 실패 다이얼로그
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
              'VIP 구매에 실패했습니다. 잠시 후 다시 시도해주세요.',
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
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      
      // 에러 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Text(
            '오류 발생',
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          content: Text(
            e.toString(),
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
}