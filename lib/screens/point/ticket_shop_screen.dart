import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketShopScreen extends ConsumerStatefulWidget {
  const TicketShopScreen({super.key});

  @override
  ConsumerState<TicketShopScreen> createState() => _TicketShopScreenState();
}

class _TicketShopScreenState extends ConsumerState<TicketShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
}