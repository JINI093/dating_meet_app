import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../models/profile_model.dart';
import '../../providers/vip_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/cards/profile_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../point/ticket_shop_screen.dart';

class VipDatingScreen extends ConsumerStatefulWidget {
  const VipDatingScreen({super.key});

  @override
  ConsumerState<VipDatingScreen> createState() => _VipDatingScreenState();
}

class _VipDatingScreenState extends ConsumerState<VipDatingScreen> {
  String selectedGrade = 'GOLD';
  List<ProfileModel> vipProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // GOLD 등급 프로필을 바로 불러와서 세팅
      _loadVipProfiles('GOLD');
    });
  }

  Future<void> _loadVipProfiles(String grade) async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final profiles = await ref.read(vipProvider.notifier).getProfilesByGrade(grade);
      if (mounted) {
        setState(() {
          vipProfiles = profiles;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          vipProfiles = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final currentVipTier = userState.vipTier;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '오늘의 VIP',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // 상단 타이틀 + 필터 + VIP 구매 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // VIP 등급별 프로필 탭 표시
                  Row(
                    children: _buildVipTierTabs(currentVipTier),
                  ),
                  const Spacer(),
                  // VIP 구매 버튼
                  GestureDetector(
                    onTap: () => _goToVipPurchase(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VIP 구매',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 카드 스와이프: 홈페이지와 동일하게
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : vipProfiles.isNotEmpty
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ProfileCard(
                                profile: vipProfiles[0],
                                onTap: () => _showProfileDetail(vipProfiles[0]),
                              ),
                          // 카드 하단에 겹치게 액션 버튼들
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Dislike Button
                                GestureDetector(
                                  onTap: () => _onDislike(),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.cardShadow,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.xmark,
                                      color: AppColors.textSecondary,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                // Super Chat Button
                                GestureDetector(
                                  onTap: () => _onSuperChat(),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: AppColors.secondaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.paperplane_fill,
                                      color: AppColors.textWhite,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                // Like Button
                                GestureDetector(
                                  onTap: () => _onLike(),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: AppColors.primaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.heart_fill,
                                      color: AppColors.textWhite,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'VIP 프로필이 없습니다.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVipTierTabs(String? currentVipTier) {
    List<Widget> tabs = [];
    
    // 사용자의 VIP 등급에 따라 표시할 탭 결정
    if (currentVipTier == 'GOLD') {
      // Gold 사용자: Gold 등급 VIP 프로필만 표시
      tabs.add(_buildGradeButton('GOLD'));
    } else if (currentVipTier == 'SILVER') {
      // Silver 사용자: Silver 등급 VIP 프로필만 표시
      tabs.add(_buildGradeButton('SILVER'));
    } else if (currentVipTier == 'BRONZE') {
      // Bronze 사용자: Bronze 등급 VIP 프로필만 표시
      tabs.add(_buildGradeButton('BRONZE'));
    } else {
      // 일반 사용자: 모든 VIP 등급 프로필 표시
      tabs.add(_buildGradeButton('GOLD'));
      tabs.add(const SizedBox(width: 8));
      tabs.add(_buildGradeButton('SILVER'));
      tabs.add(const SizedBox(width: 8));
      tabs.add(_buildGradeButton('BRONZE'));
    }
    
    return tabs;
  }

  Widget _buildGradeButton(String grade) {
    final isSelected = selectedGrade == grade;
    Color buttonColor;
    
    switch (grade) {
      case 'GOLD':
        buttonColor = const Color(0xFFFFD700);
        break;
      case 'SILVER':
        buttonColor = const Color(0xFFC0C0C0);
        break;
      case 'BRONZE':
        buttonColor = const Color(0xFFCD7F32);
        break;
      default:
        buttonColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _onGradeSelected(grade),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: buttonColor,
            width: 1,
          ),
        ),
        child: Text(
          grade,
          style: TextStyle(
            color: isSelected ? Colors.white : buttonColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onGradeSelected(String grade) {
    setState(() {
      selectedGrade = grade;
    });
    _loadVipProfiles(grade);
  }

  void _goToVipPurchase() {
    // VIP 구매 페이지로 이동 (기존의 ticket_shop_screen의 VIP 탭)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TicketShopScreen(initialTabIndex: 4),
      ),
    );
  }

  void _showProfileDetail(ProfileModel profile) {
    // 프로필 상세보기
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('나이: ${profile.age}세'),
            Text('지역: ${profile.location}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _onDislike() {
    // 다음 프로필로 넘어가기
    _nextProfile();
  }

  void _onSuperChat() {
    // 슈퍼챗 기능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('슈퍼챗 기능')),
    );
    _nextProfile();
  }

  void _onLike() {
    // 좋아요 기능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('좋아요 전송!')),
    );
    _nextProfile();
  }

  void _nextProfile() {
    if (vipProfiles.length > 1) {
      setState(() {
        vipProfiles.removeAt(0);
      });
    } else {
      // 더 이상 프로필이 없으면 새로 로드
      _loadVipProfiles(selectedGrade);
    }
  }
}