import 'package:dating_app_40s/providers/vip_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../models/profile_model.dart';
import '../../widgets/cards/profile_card.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/vip_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/cards/vip_plan_card.dart';
import '../../widgets/sheets/payment_confirmation_sheet.dart';

class VipScreen extends ConsumerStatefulWidget {
  const VipScreen({super.key});
  @override
  ConsumerState<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends ConsumerState<VipScreen> {
  String selectedGrade = 'GOLD';
  List<ProfileModel> vipProfiles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // GOLD 등급 프로필을 바로 불러와서 세팅
      setState(() {
        vipProfiles = ref.read(vipProvider.notifier).getProfilesByGrade('GOLD');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // 상단 필터: 선택 효과 없이 항상 동일
                  Row(
                    children: [
                      _buildGradeIcon('GOLD', 'assets/icons/gold.png'),
                      const SizedBox(width: 8),
                      _buildGradeIcon('SILVER', 'assets/icons/silver.png'),
                      const SizedBox(width: 8),
                      _buildGradeIcon('BRONZE', 'assets/icons/bronze.png'),
                    ],
                  ),
                  const Spacer(),
                  // VIP 구매 버튼
                  GestureDetector(
                    onTap: () => _goToVipPurchase(),
                    child: Image.asset('assets/icons/vip_buy.png', width: 72, height: 72),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 카드 스와이프: 홈페이지와 동일하게 - 애니메이션 제거
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: vipProfiles.isNotEmpty
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
                                  onTap: () {},
                                  child: Image.asset(
                                    'assets/icons/dislike.png',
                                    width: 56,
                                    height: 56,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.cardShadow,
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.xmark,
                                          color: AppColors.textSecondary,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Super Chat Button
                                GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                    'assets/icons/superchat.png',
                                    width: 64,
                                    height: 64,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: AppColors.secondaryGradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.secondary.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.paperplane_fill,
                                          color: AppColors.textWhite,
                                          size: 36,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Like Button
                                GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                    'assets/icons/like.png',
                                    width: 56,
                                    height: 56,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: AppColors.primaryGradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.heart_fill,
                                          color: AppColors.textWhite,
                                          size: 32,
                                        ),
                                      );
                                    },
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

  Widget _buildGradeIcon(String grade, String asset) {
    return GestureDetector(
      onTap: () => _onGradeSelected(grade),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Image.asset(asset, width: 36, height: 36),
      ),
    );
  }

  void _onGradeSelected(String grade) {
    setState(() {
      selectedGrade = grade;
      vipProfiles = ref.read(vipProvider.notifier).getProfilesByGrade(grade);
    });
  }

  void _goToVipPurchase() {
    // VIP 구매 화면 이동
  }

  void _showProfileDetail(ProfileModel profile) {
    // 상세보기
  }
}