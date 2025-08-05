import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../providers/vip_provider.dart';
import '../../providers/user_provider.dart';

enum VipTier { gold, silver, bronze }

class VipMembershipScreen extends ConsumerStatefulWidget {
  const VipMembershipScreen({super.key});

  @override
  ConsumerState<VipMembershipScreen> createState() => _VipMembershipScreenState();
}

class _VipMembershipScreenState extends ConsumerState<VipMembershipScreen> 
    with SingleTickerProviderStateMixin {
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
    final vipState = ref.watch(vipProvider);
    final userState = ref.watch(userProvider);
    
    // Get current user's VIP tier
    String? currentVipTier = userState.vipTier;
    
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
          // 상단 탭 메뉴 - 등급별 버튼 표시 조건
          _buildTierTabs(currentVipTier),
          
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

  Widget _buildTierTabs(String? currentVipTier) {
    List<Widget> tabs = [];
    
    // Gold 등급: Gold 탭만 표시
    if (currentVipTier == 'GOLD') {
      tabs = [
        Tab(text: 'GOLD'),
      ];
      _tabController = TabController(length: 1, vsync: this);
    }
    // Silver 등급: Silver + VIP 구매 탭 표시
    else if (currentVipTier == 'SILVER') {
      tabs = [
        Tab(text: 'SILVER'),
        Tab(text: 'VIP 구매'),
      ];
      _tabController = TabController(length: 2, vsync: this);
    }
    // Bronze 등급: Bronze + VIP 구매 탭 표시
    else if (currentVipTier == 'BRONZE') {
      tabs = [
        Tab(text: 'BRONZE'),
        Tab(text: 'VIP 구매'),
      ];
      _tabController = TabController(length: 2, vsync: this);
    }
    // 일반 사용자: 모든 탭 표시
    else {
      tabs = [
        Tab(text: 'GOLD'),
        Tab(text: 'SILVER'),
        Tab(text: 'BRONZE'),
      ];
      _tabController = TabController(length: 3, vsync: this);
    }
    
    return SizedBox(
      width: double.infinity,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.h4,
        tabs: tabs,
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
                color: _getTierColor(tier).withValues(alpha: 0.1),
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
        buttonAsset = isSelected ? 'assets/vip/BS_sliver.png' : 'assets/vip/B_silver.png';
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
              color: _getTierColor(tier).withValues(alpha: 0.1),
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
                  '${product['price']}원',
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
          {'days': 7, 'price': 9900},
          {'days': 15, 'price': 19900},
          {'days': 30, 'price': 39900},
          {'days': 90, 'price': 99900},
        ];
      case VipTier.silver:
        return [
          {'days': 7, 'price': 7900},
          {'days': 15, 'price': 15900},
          {'days': 30, 'price': 29900},
          {'days': 90, 'price': 79900},
        ];
      case VipTier.bronze:
        return [
          {'days': 7, 'price': 4900},
          {'days': 15, 'price': 9900},
          {'days': 30, 'price': 19900},
          {'days': 90, 'price': 49900},
        ];
    }
  }

  void _onProductSelected(VipTier tier, Map<String, dynamic> product) {
    // 결제 탭으로 이동하는 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tier.name.toUpperCase()} ${product['days']}일'),
        content: Text('${product['price']}원 상품을 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 결제 화면으로 이동
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}