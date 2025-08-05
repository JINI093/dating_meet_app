import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/vip_provider.dart';
import '../../models/vip_model.dart';

class TicketShopScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  
  const TicketShopScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<TicketShopScreen> createState() => _TicketShopScreenState();
}

class _TicketShopScreenState extends ConsumerState<TicketShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedVipTier = 'GOLD';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {});
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
          '이용권 구매',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 탭 바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0xFF999999),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: '하트'),
                Tab(text: '슈퍼챗'),
                Tab(text: '프로필 열람권'),
                Tab(text: '추천카드 더 보기'),
                Tab(text: 'VIP'),
              ],
            ),
          ),
          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHeartTab(),
                _buildSuperChatTab(),
                _buildProfileViewTab(),
                _buildRecommendCardTab(),
                _buildVipTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // 구매 처리
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '구매하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 아이콘
          Image.asset(
            'assets/icons/heart.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF357B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            '추천카드 더 보기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '아직 마음에 드는 이성을 찾지 못하셨나요?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '더욱 많은 이성이 여러분을 기다리고 있습니다!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 추천 카드는 매일 10장 무료로 확인할 보실 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추가로 매일 인기 회원 20장 무료로 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 내 주변 VIP 회원들은 언제든 언제든이 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추천 카드 더보기 상품으로 더욱 많은 이성을 확인해보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 아직 많은 이성이 여러분을 만나러 기다리고 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 많은 이벤트나 혜택 미리빗은 메모 없이 충돌, 빠질될 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 추천카드 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '보유 추천카드 이용권',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '0개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 상품 목록
          ..._buildRecommendCardPackages(),
        ],
      ),
    );
  }

  Widget _buildSuperChatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 아이콘
          Image.asset(
            'assets/icons/chat.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            '슈퍼챗',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '나를 픽한 이성은 누구?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '슈퍼챗으로 나를 픽한 이성의 정보를 확인해보세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 나를 픽한 이성이 누구인지 알고 싶은 프로필 열람권을 사용하여 확인해보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 슈퍼챗 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '보유 슈퍼챗 열람권',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '0개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 상품 목록
          ..._buildSuperChatPackages(),
        ],
      ),
    );
  }

  Widget _buildProfileViewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 아이콘
          Image.asset(
            'assets/icons/profile.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            '프로필 열람권',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '나를 픽한 이성은 누구?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '프로필 열람권으로 나를 픽한 이성의 정보를 확인해보세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 나를 픽한 이성이 누구인지 알고 싶은 프로필 열람권을 사용하여 확인해보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 프로필 열람권 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '보유 프로필 열람권',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '0개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 상품 목록
          ..._buildProfileViewPackages(),
        ],
      ),
    );
  }

  Widget _buildRecommendCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 아이콘
          Image.asset(
            'assets/icons/more.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            '추천카드 더 보기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '아직 마음에 드는 이성을 찾지 못하셨나요?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '더욱 많은 이성이 여러분을 기다리고 있습니다!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 추천 카드는 매일 10장 무료로 확인할 보실 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추가로 매일 인기 회원 20장 무료로 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 내 주변 VIP 회원들은 언제든 언제든이 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추천 카드 더보기 상품으로 더욱 많은 이성을 확인해보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 아직 많은 이성이 여러분을 만나러 기다리고 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 많은 이벤트나 혜택 미리빗은 메모 없이 충돌, 빠질될 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 추천카드 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '보유 추천카드 이용권',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '0개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 상품 목록
          ..._buildRecommendCardPackages(),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendCardPackages() {
    final packages = [
      {'count': 1, 'price': 20},
      {'count': 3, 'price': 50, 'discount': 17},
      {'count': 5, 'price': 60, 'discount': 40},
      {'count': 10, 'price': 100, 'discount': 50},
      {'count': 15, 'price': 120, 'discount': 60},
      {'count': 20, 'price': 150, 'discount': 63},
      {'count': 30, 'price': 220, 'discount': 63},
      {'count': 50, 'price': 280, 'discount': 72},
      {'count': 80, 'price': 420, 'discount': 74},
      {'count': 100, 'price': 520, 'discount': 74},
      {'count': 150, 'price': 680, 'discount': 77},
      {'count': 200, 'price': 780, 'discount': 81},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${package['count']}개',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (package['discount'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '↓-${package['discount']}% 할인',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${package['price']}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSuperChatPackages() {
    final packages = [
      {'count': 1, 'price': 20},
      {'count': 3, 'price': 60, 'bonus': 1},
      {'count': 5, 'price': 100, 'bonus': 3},
      {'count': 10, 'price': 200, 'bonus': 8},
      {'count': 15, 'price': 300, 'bonus': 15},
      {'count': 20, 'price': 400, 'bonus': 20},
      {'count': 30, 'price': 600, 'bonus': 35},
      {'count': 50, 'price': 1000, 'bonus': 60},
      {'count': 80, 'price': 1600, 'bonus': 95},
      {'count': 100, 'price': 2000, 'bonus': 120},
      {'count': 150, 'price': 3000, 'bonus': 190},
      {'count': 200, 'price': 4000, 'bonus': 250},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${package['count']}개',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (package['bonus'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚡ +${package['bonus']}개 더',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${package['price']}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildProfileViewPackages() {
    final packages = [
      {'count': 1, 'price': 20},
      {'count': 3, 'price': 60, 'bonus': 1},
      {'count': 5, 'price': 100, 'bonus': 3},
      {'count': 10, 'price': 200, 'bonus': 8},
      {'count': 15, 'price': 300, 'bonus': 15},
      {'count': 20, 'price': 400, 'bonus': 20},
      {'count': 30, 'price': 600, 'bonus': 35},
      {'count': 50, 'price': 1000, 'bonus': 60},
      {'count': 80, 'price': 1600, 'bonus': 95},
      {'count': 100, 'price': 2000, 'bonus': 120},
      {'count': 150, 'price': 3000, 'bonus': 190},
      {'count': 200, 'price': 4000, 'bonus': 250},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${package['count']}개',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (package['bonus'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚡ +${package['bonus']}개 더',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${package['price']}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildVipTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 왕관 아이콘 - 선택된 티어에 따라 변경
          Image.asset(
            _getCrownAsset(_selectedVipTier),
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          
          const SizedBox(height: 30),
          
          Text(
            'VIP $_selectedVipTier',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 10),
          
          const Text(
            'VIP 상품은 이성에게 더욱 매력적으로 보일 수 있습니다!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // GOLD, SILVER, BRONZE 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVipTierButton('GOLD'),
              const SizedBox(width: 8),
              _buildVipTierButton('SILVER'),
              const SizedBox(width: 8),
              _buildVipTierButton('BRONZE'),
            ],
          ),
          
          const SizedBox(height: 30),
          
          Text(
            _selectedVipTier,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // VIP 혜택 설명
          _buildVipBenefitDescription(_selectedVipTier),
          
          const SizedBox(height: 30),
          
          // VIP 상품 패키지들
          ..._buildVipPackages(),
        ],
      ),
    );
  }
  
  String _getCrownAsset(String tier) {
    switch (tier) {
      case 'GOLD':
        return 'assets/icons/gold_crown 1.png';
      case 'SILVER':
        return 'assets/icons/silver_crown 1.png';
      case 'BRONZE':
        return 'assets/icons/bronze_crown 1.png';
      default:
        return 'assets/icons/gold_crown 1.png';
    }
  }

  Widget _buildVipTierButton(String tier) {
    final isSelected = _selectedVipTier == tier;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVipTier = tier;
        });
      },
      child: SizedBox(
        width: 80,
        height: 32,
        child: isSelected
            ? Image.asset(
                _getTierButtonAsset(tier),
                width: 80,
                height: 32,
                fit: BoxFit.contain,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getTierColor(tier),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    tier,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getTierColor(tier),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
  
  String _getTierButtonAsset(String tier) {
    switch (tier) {
      case 'GOLD':
        return 'assets/vip/BS_gold.png';
      case 'SILVER':
        return 'assets/vip/BS_silver.png';
      case 'BRONZE':
        return 'assets/vip/BS_bronze.png';
      default:
        return 'assets/vip/BS_gold.png';
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'GOLD':
        return const Color(0xFFD4AF37);
      case 'SILVER':
        return const Color(0xFFC0C0C0);
      case 'BRONZE':
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildVipBenefitDescription(String tier) {
    List<String> benefits;
    switch (tier) {
      case 'GOLD':
        benefits = [
          'VIP 카테고리 노출 : VIP GOLD 카테고리내 랜덤 노출',
          '매일 추천 카드 프로필 노출 확률 UP!',
          '프로필 카드 VIP GOLD 뱃지 노출',
          '다양한 혜택을 누리면서 더욱 파격적인 가격에 이용해보세요',
        ];
        break;
      case 'SILVER':
        benefits = [
          'VIP 카테고리 노출 : VIP SILVER 카테고리내 랜덤 노출',
          '매일 추천 카드 프로필 노출 확률 UP!',
          '프로필 카드 VIP SILVER 뱃지 노출',
          'SILVER 등급만의 특별한 혜택을 누려보세요',
        ];
        break;
      case 'BRONZE':
        benefits = [
          'VIP 카테고리 노출 : VIP BRONZE 카테고리내 랜덤 노출',
          '매일 추천 카드 프로필 노출 기회 제공',
          '프로필 카드 VIP BRONZE 뱃지 노출',
          '합리적인 가격으로 VIP 혜택을 시작하세요',
        ];
        break;
      default:
        benefits = [];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '• $benefit',
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        )),
        const SizedBox(height: 4),
        const Text(
          '(혜택은 구매하신 기간내에만 유효합니다. 기간내 사용하지 않아 삭제된 혜택은 환불 및 추가 적립이 절대 불가합니다.)',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  List<Widget> _buildVipPackages() {
    final packages = [
      {'days': 7, 'price': 300, 'originalPrice': 5500, 'discount': 45},
      {'days': 15, 'price': 400, 'originalPrice': 9900, 'discount': 56},
      {'days': 20, 'price': 500, 'originalPrice': 15000, 'discount': 67},
      {'days': 30, 'price': 700, 'originalPrice': 27600, 'discount': 74},
      {'days': 45, 'price': 800, 'originalPrice': 39600, 'discount': 79},
      {'days': 60, 'price': 1000, 'originalPrice': 61200, 'discount': 84},
    ];

    return packages.map((package) {
      final days = package['days'] as int;
      final String cardAsset = _getVipCardAsset(_selectedVipTier, days);
      
      return GestureDetector(
        onTap: () {
          // TODO: 결제 창으로 이동
          _onVipPackageSelected(package);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Image.asset(
            cardAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }).toList();
  }
  
  String _getVipCardAsset(String tier, int days) {
    String prefix;
    switch (tier) {
      case 'GOLD':
        prefix = 'G';
        break;
      case 'SILVER':
        prefix = 'S';
        break;
      case 'BRONZE':
        prefix = 'B';
        break;
      default:
        prefix = 'G';
    }
    
    return 'assets/vip/$prefix$days.png';
  }
  
  void _onVipPackageSelected(Map<String, dynamic> package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('VIP $_selectedVipTier ${package['days']}일'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${package['price']}P로 구매하시겠습니까?'),
            const SizedBox(height: 16),
            Text(
              'VIP $_selectedVipTier 혜택:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._getVipBenefits(_selectedVipTier).map((benefit) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $benefit', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('구매'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processPurchase(package);
    }
  }

  Future<void> _processPurchase(Map<String, dynamic> package) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('구매 처리 중...'),
            ],
          ),
        ),
      );

      // Process VIP purchase
      final vipNotifier = ref.read(vipProvider.notifier);
      final days = package['days'] as int;
      final price = package['price'] as int;
      
      // Use purchaseVipPlan instead as a workaround
      final originalPrice = package['originalPrice'] as int? ?? price * 2;
      final discountPercent = package['discount'] as int? ?? 
        ((originalPrice - price) * 100 / originalPrice).round();
      
      final plan = VipPlan(
        id: 'ticket_$_selectedVipTier',
        name: '$_selectedVipTier VIP $days일',
        description: '$_selectedVipTier 등급 VIP $days일 이용권',
        durationDays: days,
        originalPrice: originalPrice,
        discountPrice: price,
        discountPercent: discountPercent,
        features: _getVipBenefits(_selectedVipTier),
        isPopular: days == 30,
        isRecommended: days == 30,
        type: _getVipPlanType(_selectedVipTier),
      );
      
      final success = await vipNotifier.purchaseVipPlan(plan);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('구매 완료!'),
              content: Text('VIP $_selectedVipTier ${package['days']}일 이용권이 활성화되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close ticket shop as well
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      } else {
        // Show error dialog
        final error = ref.read(vipProvider).error ?? '알 수 없는 오류가 발생했습니다.';
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('구매 실패'),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  List<String> _getVipBenefits(String tier) {
    switch (tier) {
      case 'GOLD':
        return ['VIP GOLD 배지', '프로필 우선 노출', '무제한 좋아요', '슈퍼챗 할인'];
      case 'SILVER':
        return ['VIP SILVER 배지', '프로필 노출 우선순위', '추가 좋아요'];
      case 'BRONZE':
        return ['VIP BRONZE 배지', '기본 VIP 혜택'];
      default:
        return ['VIP 혜택'];
    }
  }

  VipPlanType _getVipPlanType(String tier) {
    // Determine plan type based on tier (using monthly as default)
    return VipPlanType.monthly;
  }
}