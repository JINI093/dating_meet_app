import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/vip_provider.dart';
import '../../models/vip_model.dart';
import '../../providers/heart_provider.dart';
import '../../models/heart_model.dart';
import '../../providers/purchase_provider.dart';
import '../../services/superchat_service.dart';
import '../../models/superchat_model.dart';
import '../../providers/recommend_card_provider.dart';

class TicketShopScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const TicketShopScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<TicketShopScreen> createState() => _TicketShopScreenState();
}

class _TicketShopScreenState extends ConsumerState<TicketShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedVipTier = 'GOLD';
  int _refreshKey = 0; // FutureBuilder 새로고침용

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

    // 추천카드 데이터 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recommendCardProvider.notifier).initialize();
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
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
      body: Theme(
        data: ThemeData.fallback(),
        child: Column(
          children: [
            // 탭 바
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor:  Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.25),
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              tabs: const [
                Tab(text: '하트'),
                Tab(text: '슈퍼챗'),
                Tab(text: '프로필 열람권'),
                Tab(text: '추천카드 더보기'),
                Tab(text: 'VIP'),
              ],
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
          // 하트 아이콘
          Image.asset(
            'assets/icons/heart.png',
            width: 160,
            height: 160,
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
            '하트',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '더욱 많은 이성에게 하트를 보내보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '하트로 더욱 많은 이성에게 관심을 표현할 수 있습니다!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 이성 한명에게 보내는 하트의 수는 제한이 없습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 하트는 호감 어필의 용도로 관심있는 이성에게 나를 어필해보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 이벤트는 사전 고지 없이 종료 또는 변경 될 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 하트 수 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보유 하트 수',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final currentHearts = ref.watch(currentHeartsProvider);
                    return Text(
                      '$currentHearts개',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 하트 패키지 목록
          Consumer(
            builder: (context, ref, child) {
              return Column(
                children: [
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 1, baseCount: 1, bonusCount: 0, price: 10),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 2, baseCount: 3, bonusCount: 0, price: 30),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 3, baseCount: 5, bonusCount: 0, price: 50),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 4, baseCount: 10, bonusCount: 2, price: 100),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 5, baseCount: 15, bonusCount: 5, price: 150),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 6, baseCount: 20, bonusCount: 10, price: 200),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 7, baseCount: 30, bonusCount: 15, price: 300),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 8, baseCount: 50, bonusCount: 25, price: 500),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 9, baseCount: 80, bonusCount: 40, price: 800),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 10, baseCount: 100, bonusCount: 60, price: 1000),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 11, baseCount: 150, bonusCount: 100, price: 1500),
                      ref),
                  const SizedBox(height: 12),
                  _buildHeartPackageItem(
                      HeartPackage(
                          id: 12, baseCount: 200, bonusCount: 200, price: 2000),
                      ref),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileViewPackageItem(int baseCount, int bonusCount, int price,
      {int? imageNumber}) {
    return GestureDetector(
      onTap: () => _onProfileViewPackageSelected(baseCount, bonusCount, price),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$baseCount개',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            // 보너스가 있을 때만 이미지 표시
            if (bonusCount > 0 && imageNumber != null)
              Image.asset(
                'assets/icons/m_profile$imageNumber.png',
                width: 112,
                height: 28,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${price}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onProfileViewPackageSelected(
      int baseCount, int bonusCount, int price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 열람권 구매'),
        content: Text('${price}P로 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: 프로필 열람권 구매 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 열람권 ${baseCount + bonusCount}개 구매가 완료되었습니다.'),
          backgroundColor: const Color(0xFF2196F3),
        ),
      );
    }
  }

  Widget _buildSuperChatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 슈퍼챗 아이콘
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '더욱 많은 이성에게 슈퍼챗을 보내보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '슈퍼챗으로 마음에 드는 이성과 대화를 이루어 보세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 설명 리스트
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• 슈퍼챗으로 이성에게 메시지를 보낼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 슈퍼챗을 받은 이성이 좋아요를 누르면 대화로 연결됩니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 이성이 슈퍼챗을 5일간 읽지 않거나 거부하면 발송 당시 소모했던 슈퍼챗은 다시 회수됩니다. 부담 없이 즐겨보세요!',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 슈퍼챗 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보유 슈퍼챗',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                FutureBuilder<int>(
                  key: ValueKey(_refreshKey),
                  future: SuperChatService().getCurrentSuperChats(),
                  builder: (context, snapshot) {
                    final currentSuperChats = snapshot.data ?? 0;
                    return Text(
                      '$currentSuperChats개',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 슈퍼챗 패키지 목록
          _buildSuperChatPackageItem(1, 0, 50),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(3, 0, 150),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(5, 1, 250, imageNumber: 1),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(10, 3, 500, imageNumber: 2),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(15, 5, 750, imageNumber: 3),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(20, 8, 1000, imageNumber: 4),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(30, 12, 1500, imageNumber: 5),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(50, 18, 2500, imageNumber: 6),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(80, 32, 4000, imageNumber: 7),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(100, 42, 5000, imageNumber: 8),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(150, 62, 7500, imageNumber: 9),
          const SizedBox(height: 12),
          _buildSuperChatPackageItem(200, 85, 10000, imageNumber: 10),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuperChatPackageItem(int baseCount, int bonusCount, int price,
      {int? imageNumber}) {
    return GestureDetector(
      onTap: () => _onSuperChatPackageSelected(baseCount, bonusCount, price),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$baseCount개',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            // 보너스가 있을 때만 이미지 표시
            if (bonusCount > 0 && imageNumber != null)
              Image.asset(
                'assets/icons/m_super$imageNumber.png',
                width: 112,
                height: 28,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.add_circle,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${price}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSuperChatPackageSelected(
      int baseCount, int bonusCount, int price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('슈퍼챗 구매'),
        content: Text('${price}P로 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _processSuperChatPurchase(baseCount, bonusCount, price);
    }
  }

  Future<void> _processSuperChatPurchase(
      int baseCount, int bonusCount, int price) async {
    try {
      // 로딩 다이얼로그 표시
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

      // 슈퍼챗 구매 처리 (직접 서비스 사용)
      final superChatService = SuperChatService();
      final package = SuperChatPackage(
        id: DateTime.now().millisecondsSinceEpoch,
        baseCount: baseCount,
        bonusCount: bonusCount,
        price: price,
      );

      final success = await superChatService.purchaseSuperChats(package);

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // 슈퍼챗 수량 새로고침
        setState(() {
          _refreshKey++;
        });

        // 성공 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.chat, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  const Text('구매 완료!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '슈퍼챗 $baseCount${bonusCount > 0 ? '+$bonusCount' : ''}개가 지급되었습니다.'),
                  if (bonusCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '보너스 $bonusCount개 포함!',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      } else {
        // 실패 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('구매 실패'),
              content: const Text('슈퍼챗 구매에 실패했습니다.'),
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
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      // 오류 스낵바 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
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
          ),
          const SizedBox(height: 20),
          // 프로필 열람권 패키지 목록
          _buildProfileViewPackageItem(1, 0, 20),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(3, 1, 60, imageNumber: 1),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(5, 3, 100, imageNumber: 2),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(10, 8, 200, imageNumber: 3),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(15, 15, 300, imageNumber: 4),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(20, 20, 400, imageNumber: 5),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(30, 35, 600, imageNumber: 6),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(50, 60, 1000, imageNumber: 7),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(80, 95, 1600, imageNumber: 8),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(100, 120, 2000, imageNumber: 9),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(150, 190, 3000, imageNumber: 10),
          const SizedBox(height: 12),
          _buildProfileViewPackageItem(200, 250, 4000, imageNumber: 11),
        ],
      ),
    );
  }

  Widget _buildRecommendCardPackageItem(
      int baseCount, int bonusCount, int price,
      {int? imageNumber}) {
    return GestureDetector(
      onTap: () =>
          _onRecommendCardPackageSelected(baseCount, bonusCount, price),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$baseCount개',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            // 보너스가 있을 때만 이미지 표시
            if (bonusCount > 0 && imageNumber != null)
              Image.asset(
                'assets/icons/m_more$imageNumber.png',
                width: 112,
                height: 28,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.more_horiz,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${price}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRecommendCardPackageSelected(
      int baseCount, int bonusCount, int price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('추천카드 이용권 구매'),
        content: Text('${price}P로 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: 추천카드 이용권 구매 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('추천카드 이용권 ${baseCount + bonusCount}개 구매가 완료되었습니다.'),
          backgroundColor: const Color(0xFFFF9800),
        ),
      );
    }
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
            width: 240,
            height: 240,
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
                '• 추천 카드는 매일 10명 무료로 확인해 보실 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추가로 매달 인기 회원 20명 무료로 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 내 주변 VIP 회원들은 추천카드 횟수 상관없이 볼 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 추천 카드 더보기 상품으로 더욱 많은 이성을 확인해보세요! 아직 많은 이성이 여러분을 만나길 기다리고 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              SizedBox(height: 4),
              Text(
                '• 할인 이벤트나 적립 이벤트는 예고 없이 종료, 변경 될 수 있습니다.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 보유 추천카드 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
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
                Consumer(
                  builder: (context, ref, child) {
                    final currentRecommendCards =
                        ref.watch(currentRecommendCardsProvider);
                    return Text(
                      '${currentRecommendCards}개',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 추천카드 패키지 목록
          _buildRecommendCardPackageItem(1, 0, 50),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(3, 1, 150, imageNumber: 1),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(5, 3, 250, imageNumber: 2),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(10, 8, 500, imageNumber: 3),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(15, 15, 750, imageNumber: 4),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(20, 20, 1000, imageNumber: 5),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(30, 35, 1500, imageNumber: 6),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(50, 60, 2500, imageNumber: 7),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(80, 95, 4000, imageNumber: 8),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(100, 120, 5000, imageNumber: 9),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(150, 190, 7500, imageNumber: 10),
          const SizedBox(height: 12),
          _buildRecommendCardPackageItem(200, 250, 10000, imageNumber: 11),
        ],
      ),
    );
  }

  List<Widget> _buildHeartPackages() {
    return [
      Consumer(
        builder: (context, ref, child) {
          final heartState = ref.watch(heartProvider);

          if (heartState.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (heartState.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '오류: ${heartState.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(heartProvider.notifier).refreshHearts(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: heartState.packages
                .map((package) => _buildHeartPackageItem(package, ref))
                .toList(),
          );
        },
      ),
    ];
  }

  Widget _getHeartImage(int baseCount) {
    int imageNumber;
    switch (baseCount) {
      case 10:
        imageNumber = 1;
        break;
      case 15:
        imageNumber = 2;
        break;
      case 20:
        imageNumber = 3;
        break;
      case 30:
        imageNumber = 4;
        break;
      case 50:
        imageNumber = 5;
        break;
      case 80:
        imageNumber = 6;
        break;
      case 100:
        imageNumber = 7;
        break;
      case 150:
        imageNumber = 8;
        break;
      case 200:
        imageNumber = 9;
        break;
      default:
        imageNumber = 1; // 기본값
    }

    return Image.asset(
      'assets/icons/m_heart$imageNumber.png',
      width: 112,
      height: 28,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.favorite,
        color: Color(0xFFFF357B),
        size: 24,
      ),
    );
  }

  Widget _buildHeartPackageItem(HeartPackage package, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _onHeartPackageSelected(package, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${package.baseCount}개',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            // 10개 이상일 때만 이미지 표시
            if (package.baseCount >= 10 && package.hasBonus)
              _getHeartImage(package.baseCount)
            else
              const SizedBox.shrink(),
            Text(
              '${package.price}P',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onHeartPackageSelected(
      HeartPackage package, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('하트 구매'),
        content: Text('${package.price}P로 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF357B),
              foregroundColor: Colors.white,
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processHeartPurchase(package, ref);
    }
  }

  Future<void> _processHeartPurchase(
      HeartPackage package, WidgetRef ref) async {
    try {
      // 로딩 다이얼로그 표시
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

      // 인앱결제용 제품 ID 생성 (하트 수량 기준으로)
      String productId;
      if (package.baseCount <= 10) {
        productId = 'dating_hearts_10';
      } else if (package.baseCount <= 50) {
        productId = 'dating_hearts_50';
      } else if (package.baseCount <= 100) {
        productId = 'dating_hearts_100';
      } else {
        productId = 'dating_hearts_500';
      }

      // PurchaseProvider를 통해 인앱결제 시작
      final success =
          await ref.read(purchaseProvider.notifier).purchaseProduct(productId);

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // 성공 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFFF357B)),
                  const SizedBox(width: 8),
                  const Text('구매 완료!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('하트 ${package.totalCount}개가 지급되었습니다.'),
                  if (package.hasBonus) ...[
                    const SizedBox(height: 8),
                    Text(
                      '보너스 ${package.bonusCount}개 포함!',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    '인앱결제로 안전하게 구매되었습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF357B),
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      } else {
        // 실패 다이얼로그 표시
        final error = ref.read(heartProvider).error ?? '알 수 없는 오류가 발생했습니다.';
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
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      // 오류 스낵바 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  List<Widget> _buildRecommendCardPackages() {
    final packages = [
      {'count': 1, 'price': 10},
      {'count': 3, 'price': 30},
      {'count': 5, 'price': 50},
      {'count': 10, 'price': 100},
      {'count': 15, 'price': 150},
      {'count': 20, 'price': 200},
      {'count': 30, 'price': 300},
      {'count': 50, 'price': 500},
      {'count': 80, 'price': 800},
      {'count': 100, 'price': 1000},
      {'count': 150, 'price': 1500},
      {'count': 200, 'price': 2000},
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      {'count': 1, 'price': 50},
      {'count': 3, 'price': 150},
      {'count': 5, 'price': 250},
      {'count': 10, 'price': 500},
      {'count': 15, 'price': 750},
      {'count': 20, 'price': 1000},
      {'count': 30, 'price': 1500},
      {'count': 50, 'price': 2500},
      {'count': 80, 'price': 4000},
      {'count': 100, 'price': 5000},
      {'count': 150, 'price': 7500},
      {'count': 200, 'price': 10000},
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      {'count': 1, 'price': 10},
      {'count': 3, 'price': 60},
      {'count': 5, 'price': 100},
      {'count': 10, 'price': 200},
      {'count': 15, 'price': 300},
      {'count': 20, 'price': 400},
      {'count': 30, 'price': 600},
      {'count': 50, 'price': 1000},
      {'count': 80, 'price': 1600},
      {'count': 100, 'price': 2000},
      {'count': 150, 'price': 3000},
      {'count': 200, 'price': 4000},
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ..._getVipBenefits(_selectedVipTier).map(
              (benefit) => Padding(
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
              content: Text(
                  'VIP $_selectedVipTier ${package['days']}일 이용권이 활성화되었습니다.'),
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
