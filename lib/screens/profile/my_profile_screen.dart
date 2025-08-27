import 'dart:io';
import 'package:dating_app_40s/screens/events/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../providers/points_provider.dart';
import '../../providers/heart_provider.dart';
import '../../providers/superchat_provider.dart';
import '../../providers/recommend_card_provider.dart';
import '../../providers/profile_view_provider.dart';
import 'edit_profile_screen.dart';
import '../point/point_shop_screen.dart';
import 'block_contacts_screen.dart';
import 'inquiry_screen.dart';
import 'point_history_screen.dart';
import 'notice_screen.dart';
import 'privacy_policy_screen.dart';
import 'faq_screen.dart';
import 'referral_code_screen.dart';
import 'coupon_status_screen.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';
import '../point/ticket_shop_screen.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(userProvider.notifier).initializeUser();
        // 포인트 데이터 로드
        ref.read(pointsProvider.notifier).loadUserPoints();
        // 하트 및 이용권 데이터 초기화
        ref.read(heartProvider.notifier).refreshHearts();
        ref.read(superchatProvider.notifier).initialize();
        ref.read(recommendCardProvider.notifier).initialize();
        ref.read(profileViewProvider.notifier).initialize();
      }
    });
  }

  Future<void> _refreshProfile() async {
    // DynamoDB에서 최신 프로필 데이터 새로고침
    await ref.read(userProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: userState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // 새로고침을 위해 추가
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildTitle(),
                        const SizedBox(height: 20),
                        _buildVipGradeBar(user),
                        const SizedBox(height: 20),
                        _buildProfileCard(user),
                        const SizedBox(height: 16),
                        _buildStatsSection(user),
                        const SizedBox(height: 16),
                        _buildProfileCompletion(user),
                        const SizedBox(height: 20),
                        _buildEditButton(),
                        const SizedBox(height: 30),
                        _buildMenuList(),
                        const SizedBox(height: 40),
                        _buildWithdrawalButton(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        '내 정보',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVipGradeBar(ProfileModel user) {
    // 사용자의 VIP 등급 확인
    final userState = ref.watch(userProvider);
    final vipTier = userState.vipTier ?? user.vipTier;
    
    // VIP 등급에 따른 이미지 및 정보 설정
    String vipImagePath;
    String vipGradeText;
    List<Color> gradientColors;
    
    switch (vipTier?.toUpperCase()) {
      case 'GOLD':
        vipImagePath = 'assets/vip/gold_level.png';
        vipGradeText = 'GOLD';
        gradientColors = [const Color(0xFFB8860B), const Color(0xFFFFD700)];
        break;
      case 'SILVER':
        vipImagePath = 'assets/vip/silver_level.png';
        vipGradeText = 'SILVER';
        gradientColors = [const Color(0xFF708090), const Color(0xFFC0C0C0)];
        break;
      case 'BRONZE':
        vipImagePath = 'assets/vip/bronze_level.png';
        vipGradeText = 'BRONZE';
        gradientColors = [const Color(0xFF8B4513), const Color(0xFFCD7F32)];
        break;
      default:
        vipImagePath = 'assets/vip/no_level.png';
        vipGradeText = '일반 회원';
        gradientColors = [const Color(0xFF666666), const Color(0xFF999999)];
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _goToVipPurchase,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            vipImagePath,
            width: double.infinity,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'VIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        vipGradeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user.profileImages.isNotEmpty
                ? _getImageProvider(user.profileImages.first)
                : null,
            backgroundColor: AppColors.surface,
            child: user.profileImages.isEmpty
                ? const Icon(CupertinoIcons.person, size: 30, color: AppColors.textHint)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getDisplayValue(user.occupation, '데이터 디자이너')}, ${_getDisplayValue(user.location, '서울')}, ${user.age}세',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.isVerified ? '인증완료' : '인증완료',
                  style: const TextStyle(
                    color: Color(0xFFFF357B),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ProfileModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 포인트 섹션
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/point/1.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC107),
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
                    Consumer(
                      builder: (context, ref, child) {
                        final pointsState = ref.watch(pointsProvider);
                        return Text(
                          '${pointsState.currentPoints}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                        onTap: () {
                          _goToPointExchange();
                        },
                        child: Image.asset('assets/icons/ic_exchange_point.png')
                    ),
                    // _buildSmallButton('포인트 전환', const Color(0xFFFFC107), _goToPointExchange),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      _goToPointShop();
                    },
                    child: Image.asset('assets/icons/ic_point_store.png')
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 이용권 섹션
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
                  '이용권',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      _goToTicketShop();
                    },
                    child: Image.asset('assets/icons/ic_use_store.png')
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 좋아요 수 섹션
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
                  '내가 받은 좋아요 수',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.heart,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.likeCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 슈퍼챗 수 섹션
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
                  '내가 받은 슈퍼챗 수',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.paperplane,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.superChatCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // 내 이용권 보유 현황 타이틀
          const Center(
            child: Text(
              '내 이용권 보유 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 이용권 현황
          _buildTicketStatusSection(),
          const SizedBox(height: 8),
          // 주의사항 2
          const Align(
            alignment: Alignment.center,
            child: Text(
              '* 내가 받은 좋아요/슈퍼챗 수는 매월 1일 초기화됩니다.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion(ProfileModel user) {
    // final percent = ((user.profileCompletionRate * 100).round()).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '프로필 완성률',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(user.profileCompletionRate * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFFF02062),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * user.profileCompletionRate * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF02062),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '조금 더 작성하여 매칭 확률을 높여보세요!',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _goToEditProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5F5F5),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
          child: const Text(
            '정보 변경',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Column(
      children: [
        _buildMenuItem('이벤트', '진행중인 이벤트를 확인하실 수 있습니다.', () => _navigateToEventScreen()),
        _buildMenuItem('지인차단', '만나고 싶지 않은 지인을 차단합니다.', () => _navigateToBlockContacts()),
        _buildMenuItem('문의하기', '서비스에 궁금한 점이 있다면?', () => _navigateToInquiry()),
        _buildMenuItem('내 쿠폰 현황', '보유하고 있는 쿠폰을 확인할 수 있습니다', () => _navigateToCouponStatus()),
        _buildMenuItem('포인트 현황', '포인트 충전/적립/사용 내역을 알 수 있습니다', () => _navigateToPointHistory()),
        _buildMenuItem('공지사항', '서비스 이용에 대한 알림이나 변경사항을 알려드립니다', () => _navigateToNotice()),
        _buildMenuItem('개인정보취급방침', '서비스에 활용되는 개인정보에 대해 알려드립니다', () => _navigateToPrivacyPolicy()),
        _buildMenuItem('자주 묻는 질문', '서비스 이용에 대한 자주 묻는 질문을 알려드립니다.', () => _navigateToFaq()),
        _buildMenuItem('추천인 코드 확인', '', () => _navigateToReferralCode()),
        _buildMenuItem('로그아웃', '', () => _showLogoutDialog()),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: subtitle.isNotEmpty ? Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ) : null,
        trailing: const Icon(
          CupertinoIcons.chevron_forward,
          size: 18,
          color: Color(0xFF999999),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
    );
  }

  Widget _buildWithdrawalButton() {
    return Center(
      child: GestureDetector(
        onTap: _showWithdrawalBottomSheet,
        child: const Text(
          '회원탈퇴',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text('프로필을 불러올 수 없습니다.'),
    );
  }

  /// 프로필 데이터가 비어있거나 기본값일 때 대체 값 제공
  String _getDisplayValue(String? value, String defaultValue) {
    if (value == null || value.isEmpty || value == '미설정') {
      return defaultValue;
    }
    return value;
  }

  /// 이미지 프로바이더 생성 (로컬 파일과 네트워크 이미지 모두 지원)
  ImageProvider? _getImageProvider(String imageUrl) {
    print('🖼️  이미지 로드 시도: $imageUrl');
    
    if (imageUrl.startsWith('file://')) {
      // 로컬 파일 경로인 경우
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);
      print('📁 로컬 파일 확인: $filePath, 존재: ${file.existsSync()}');
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // 파일이 존재하지 않으면 placeholder 이미지 사용
        print('❌ 로컬 파일 없음, placeholder 사용');
        return const NetworkImage('https://picsum.photos/200/200');
      }
    } else if (imageUrl.startsWith('http')) {
      // 네트워크 이미지인 경우
      print('🌐 네트워크 이미지 사용');
      return NetworkImage(imageUrl);
    }
    
    print('⚠️  알 수 없는 이미지 형식, null 반환');
    return null;
  }


  Widget _buildTicketStatusSection() {
    final heartState = ref.watch(heartProvider);
    final superchatState = ref.watch(superchatProvider);
    final recommendCardState = ref.watch(recommendCardProvider);
    final profileViewState = ref.watch(profileViewProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTicketItem(
                icon: CupertinoIcons.heart,
                label: '좋아요',
                count: heartState.currentHearts,
              ),
              _buildTicketItem(
                icon: CupertinoIcons.paperplane,
                label: '슈퍼챗',
                count: superchatState.currentSuperChats,
              ),
              _buildTicketItem(
                icon: CupertinoIcons.square_grid_2x2,
                label: '추천카드 더보기',
                count: recommendCardState.currentRecommendCards,
              ),
              _buildTicketItem(
                icon: CupertinoIcons.doc_person,
                label: '프로필 열람권',
                count: profileViewState.currentProfileViewTickets,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: const Color(0xFF666666),
                ),
                const SizedBox(width: 2),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _goToEditProfile() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _goToPointShop() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const PointShopScreen(),
      ),
    );
  }

  void _goToPointExchange() {
    context.go('/points');
  }

  void _goToTicketShop() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const TicketShopScreen(),
      ),
    );
  }

  void _goToVipPurchase() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const TicketShopScreen(initialTabIndex: 4), // VIP 탭 (index 4)
      ),
    );
  }

  void _navigateToEventScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EventsScreen(),
      ),
    );
  }

  void _navigateToCouponStatus() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CouponStatusScreen(),
      ),
    );
  }

  void _navigateToBlockContacts() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const BlockContactsScreen(),
      ),
    );
  }

  void _navigateToInquiry() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const InquiryScreen(),
      ),
    );
  }

  void _navigateToPointHistory() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const PointHistoryScreen(),
      ),
    );
  }

  void _navigateToNotice() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const NoticeScreen(),
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _navigateToFaq() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const FaqScreen(),
      ),
    );
  }

  void _navigateToReferralCode() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReferralCodeScreen(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말로 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await _logout();
              Navigator.pop(context);
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // 사용자 상태 초기화
    ref.read(userProvider.notifier).logout();
    
    // Auth Provider를 통한 로그아웃 처리
    final authNotifier = ref.read(enhancedAuthProvider.notifier);
    
    // 자동 로그인 설정 해제
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_login_enabled', false);

    await authNotifier.setAutoLoginEnabled(false);
    
    // 로그아웃 처리
    await authNotifier.signOut();
    
    // 로그인 페이지로 이동 (모든 스택 제거)
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  void _showWithdrawalBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/secession.png'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            
            // 바텀시트 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 이성 더 만나보기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 바텀시트 닫기
                        // 내 정보 페이지로 이동 (현재 페이지이므로 그냥 닫기만)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF02062),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '이성 더 만나보기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 회원 탈퇴하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 바텀시트 닫기
                        _showWithdrawalReasonDialog(); // 바로 탈퇴 사유 팝업 표시
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '회원 탈퇴하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '소중한 의견 감사합니다.\n꼭 개선하도록 하겠습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.4,
          ),
        ),
        content: const Text(
          '정말 탈퇴하실건가요?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '네',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showWithdrawalReasonDialog();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFF357B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '아니요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawalReasonDialog() {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '탈퇴하기',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '사용 하시면서 느꼈던 불편한 사유를 알려주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: reasonController,
                maxLines: 5,
                maxLength: 100,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  hintText: '탈퇴 사유를 입력해주세요',
                  hintStyle: TextStyle(color: Color(0xFF999999)),
                  counterStyle: TextStyle(color: Color(0xFF999999)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processWithdrawal(reasonController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF357B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '제출하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal(String reason) {
    // 회원 탈퇴 처리
    ref.read(userProvider.notifier).logout();
    
    // 탈퇴 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('회원 탈퇴가 완료되었습니다.'),
        duration: Duration(seconds: 3),
      ),
    );
    
    // 로그인 페이지로 이동
    context.go(RouteNames.login);
  }
}