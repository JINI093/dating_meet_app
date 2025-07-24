import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VipPurchaseScreen extends ConsumerStatefulWidget {
  const VipPurchaseScreen({super.key});

  @override
  ConsumerState<VipPurchaseScreen> createState() => _VipPurchaseScreenState();
}

class _VipPurchaseScreenState extends ConsumerState<VipPurchaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
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
            child: Row(
              children: [
                _buildTabItem('슈퍼챗', 0, false),
                _buildTabItem('프로필 열람권', 1, false),
                _buildTabItem('추천카드 더 보기', 2, false),
                _buildTabItem('VIP', 3, true),
              ],
            ),
          ),
          // VIP 탭 내용
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // VIP 등급 선택 버튼들
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildVipGradeButton('GOLD', 0),
                      const SizedBox(width: 12),
                      _buildVipGradeButton('SILVER', 1),
                      const SizedBox(width: 12),
                      _buildVipGradeButton('BRONZE', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // VIP 등급별 내용
                Expanded(
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildVipGoldContent(),
                      _buildVipSilverContent(),
                      _buildVipBronzeContent(),
                    ],
                  ),
                ),
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

  Widget _buildTabItem(String title, int index, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : const Color(0xFF999999),
          ),
        ),
      ),
    );
  }

  Widget _buildVipGradeButton(String grade, int index) {
    final isSelected = _selectedTabIndex == index;
    final colors = [
      const Color(0xFFB8860B), // GOLD
      const Color(0xFF808080), // SILVER
      const Color(0xFFCD7F32), // BRONZE
    ];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors[index] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors[index],
            width: 1,
          ),
        ),
        child: Text(
          grade,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors[index],
          ),
        ),
      ),
    );
  }

  Widget _buildVipGoldContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 왕관 이미지
          Image.asset(
            'assets/icons/gold_crown 1.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'VIP GOLD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'VIP 상품은 이성에게 더욱 매력적으로 보일 수 있습니다!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          // VIP GOLD 버튼
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'VIP GOLD                    8일 남음',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 등급 선택 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradeSelectButton('GOLD', true),
              const SizedBox(width: 12),
              _buildGradeSelectButton('SILVER', false),
              const SizedBox(width: 12),
              _buildGradeSelectButton('BRONZE', false),
            ],
          ),
          const SizedBox(height: 30),
          // GOLD 혜택 제목
          const Text(
            'GOLD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // 혜택 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• VIP 카테고리 노출 = VIP GOLD 카테고리에 랜덤 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 매일 추천 카드 프로필 노출 혜택 UP!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 프로필 카드 VIP GOLD 뱃지 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 디자인 혜택을 추가받은 더욱 미쳐진 가격에 이용하세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '(혜택은 상품의 배송니 까지만 혜택이 적용됩니다. 상품 혜택으로 기록된 혜택은 적용되지 않습니다.)',
                style: TextStyle(fontSize: 10, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 상품 패키지들
          ..._buildGoldPackages(),
        ],
      ),
    );
  }

  Widget _buildVipSilverContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 왕관 이미지
          Image.asset(
            'assets/icons/silver_crown 1.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF808080),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'VIP SILVER',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'VIP 상품은 이성에게 더욱 매력적으로 보일 수 있습니다!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          // VIP SILVER 버튼
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF808080),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'VIP SILVER                    8일 남음',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 등급 선택 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradeSelectButton('GOLD', false),
              const SizedBox(width: 12),
              _buildGradeSelectButton('SILVER', true),
              const SizedBox(width: 12),
              _buildGradeSelectButton('BRONZE', false),
            ],
          ),
          const SizedBox(height: 30),
          // SILVER 혜택 제목
          const Text(
            'SILVER',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // 혜택 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 하루 10장 추가 추천 카드',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• PICK+ 카테고리 노출 = PICK+ SILVER 카테고리에 랜덤 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 매일 추천 카드 프로필 노출 혜택 UP!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 프로필 카드 VIP SILVER 뱃지 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 하트/슈퍼챗 혜택 2개 혜택',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 상품 패키지들
          ..._buildSilverPackages(),
        ],
      ),
    );
  }

  Widget _buildVipBronzeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 왕관 이미지
          Image.asset(
            'assets/icons/bronze_crown 1.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFCD7F32),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'VIP BRONZE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'VIP 상품은 이성에게 더욱 매력적으로 보일 수 있습니다!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          // VIP BRONZE 버튼
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFCD7F32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'VIP BRONZE                    8일 남음',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 등급 선택 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradeSelectButton('GOLD', false),
              const SizedBox(width: 12),
              _buildGradeSelectButton('SILVER', false),
              const SizedBox(width: 12),
              _buildGradeSelectButton('BRONZE', true),
            ],
          ),
          const SizedBox(height: 30),
          // BRONZE 혜택 제목
          const Text(
            'BRONZE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // 혜택 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 하루 5장 추가 추천 카드',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• PICK+ 카테고리 노출 = PICK+ BRONZE 카테고리에 랜덤 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 프로필 카드 VIP BRONZE 뱃지 노출',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 상품 패키지들
          ..._buildBronzePackages(),
        ],
      ),
    );
  }

  Widget _buildGradeSelectButton(String grade, bool isSelected) {
    final colors = {
      'GOLD': const Color(0xFFB8860B),
      'SILVER': const Color(0xFF808080),
      'BRONZE': const Color(0xFFCD7F32),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colors[grade] : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors[grade]!,
          width: 1,
        ),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : colors[grade],
        ),
      ),
    );
  }

  List<Widget> _buildGoldPackages() {
    final packages = [
      {'days': 7, 'originalPrice': 550, 'price': 300, 'discount': 45},
      {'days': 15, 'originalPrice': 990, 'price': 400, 'discount': 56},
      {'days': 20, 'originalPrice': 1590, 'price': 500, 'discount': 67},
      {'days': 30, 'originalPrice': 2790, 'price': 700, 'discount': 74},
      {'days': 45, 'originalPrice': 3990, 'price': 800, 'discount': 79},
      {'days': 60, 'originalPrice': 6400, 'price': 1000, 'discount': 84},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 왼쪽 날짜 부분
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      '${package['days']}일',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 중간 혜택 부분
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '하트 ${package['days'] == 7 ? '5' : package['days'] == 15 ? '10' : package['days'] == 20 ? '20' : package['days'] == 30 ? '40' : package['days'] == 45 ? '60' : '100'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.chat, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '슈퍼챗 ${package['days'] == 7 ? '4' : package['days'] == 15 ? '6' : package['days'] == 20 ? '10' : package['days'] == 30 ? '15' : package['days'] == 45 ? '18' : '22'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '프로필열람권 ${package['days'] == 7 ? '5' : package['days'] == 15 ? '10' : package['days'] == 20 ? '20' : package['days'] == 30 ? '40' : package['days'] == 45 ? '60' : '100'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.more_horiz, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '추천카드더보기 ${package['days'] == 7 ? '5' : package['days'] == 15 ? '10' : package['days'] == 20 ? '20' : package['days'] == 30 ? '40' : package['days'] == 45 ? '60' : '100'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 오른쪽 가격 부분
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${package['originalPrice']}P',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '${package['price']}P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 할인 라벨
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  '-${package['discount']}%\n할인',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSilverPackages() {
    final packages = [
      {'days': 7, 'originalPrice': 300, 'price': 220, 'discount': 33},
      {'days': 15, 'originalPrice': 650, 'price': 320, 'discount': 53},
      {'days': 20, 'originalPrice': 1250, 'price': 420, 'discount': 68},
      {'days': 30, 'originalPrice': 2350, 'price': 620, 'discount': 74},
      {'days': 45, 'originalPrice': 3450, 'price': 720, 'discount': 79},
      {'days': 60, 'originalPrice': 5650, 'price': 920, 'discount': 84},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF808080),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 왼쪽 날짜 부분
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      '${package['days']}일',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 중간 혜택 부분
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '하트 ${package['days'] == 7 ? '2' : package['days'] == 15 ? '7' : package['days'] == 20 ? '17' : package['days'] == 30 ? '35' : package['days'] == 45 ? '55' : '95'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.chat, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '슈퍼챗 ${package['days'] == 7 ? '4' : package['days'] == 15 ? '6' : package['days'] == 20 ? '8' : package['days'] == 30 ? '12' : package['days'] == 45 ? '14' : '18'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '프로필열람권 ${package['days'] == 7 ? '2' : package['days'] == 15 ? '7' : package['days'] == 20 ? '17' : package['days'] == 30 ? '35' : package['days'] == 45 ? '55' : '95'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.more_horiz, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '추천카드더보기 ${package['days'] == 7 ? '2' : package['days'] == 15 ? '7' : package['days'] == 20 ? '17' : package['days'] == 30 ? '35' : package['days'] == 45 ? '55' : '95'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 오른쪽 가격 부분
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${package['originalPrice']}P',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '${package['price']}P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 할인 라벨
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  '-${package['discount']}%\n할인',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildBronzePackages() {
    final packages = [
      {'days': 7, 'originalPrice': 150, 'price': 150, 'discount': 33},
      {'days': 15, 'originalPrice': 450, 'price': 250, 'discount': 56},
      {'days': 20, 'originalPrice': 1090, 'price': 350, 'discount': 70},
      {'days': 30, 'originalPrice': 2090, 'price': 550, 'discount': 75},
      {'days': 45, 'originalPrice': 3390, 'price': 650, 'discount': 82},
      {'days': 60, 'originalPrice': 5050, 'price': 850, 'discount': 84},
    ];

    return packages.map((package) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFCD7F32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 왼쪽 날짜 부분
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      '${package['days']}일',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 중간 혜택 부분
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '하트 ${package['days'] == 7 ? '1' : package['days'] == 15 ? '5' : package['days'] == 20 ? '14' : package['days'] == 30 ? '30' : package['days'] == 45 ? '50' : '85'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.chat, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '슈퍼챗 ${package['days'] == 7 ? '4' : package['days'] == 15 ? '4' : package['days'] == 20 ? '6' : package['days'] == 30 ? '10' : package['days'] == 45 ? '12' : '16'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '프로필열람권 ${package['days'] == 7 ? '1' : package['days'] == 15 ? '5' : package['days'] == 20 ? '14' : package['days'] == 30 ? '30' : package['days'] == 45 ? '50' : '85'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.more_horiz, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '추천카드더보기 ${package['days'] == 7 ? '1' : package['days'] == 15 ? '5' : package['days'] == 20 ? '14' : package['days'] == 30 ? '30' : package['days'] == 45 ? '50' : '85'}개',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 오른쪽 가격 부분
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${package['originalPrice']}P',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '${package['price']}P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 할인 라벨
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  '-${package['discount']}%\n할인',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}