import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/cards/profile_card.dart';
import '../../widgets/sheets/super_chat_bottom_sheet.dart';
import '../../widgets/sheets/region_selection_sheet.dart';
import '../../widgets/sheets/distance_filter_sheet.dart';
import '../../widgets/sheets/popularity_filter_sheet.dart';
import '../../widgets/sections/today_vip_section.dart';
import '../../widgets/common/notification_badge.dart';
import '../../widgets/dialogs/match_success_dialog.dart';
import '../../models/profile_model.dart';
import '../../providers/match_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';
import '../../widgets/dialogs/region_selector_bottom_sheet.dart';
import '../notification/notification_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final SwiperController _swiperController = SwiperController();
  
  // Filter states
  String _selectedRegion = '지역';
  String _selectedDistance = '범위';
  String _selectedPopularity = '인기';
  final bool _isVipFilterActive = false;
  int _swipeCount = 0;

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final profiles = matchState.profiles;
    final isLoading = matchState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(child: _buildAppBar()),

            // Filter Bar
            SliverToBoxAdapter(child: _buildFilterBar()),

            // VIP Section: 처음에는 노출하지 않음
            // if (!isLoading && profiles.where((p) => p.isVip).isNotEmpty)
            //   SliverToBoxAdapter(
            //     child: TodayVipSection(
            //       vipProfiles: profiles.where((p) => p.isVip).toList(),
            //       onViewAll: _goToVipProfiles,
            //     ),
            //   ),

            // Main Content - Profile Cards
            if (isLoading)
              SliverFillRemaining(
                child: _buildLoadingState(),
              )
            else
              SliverFillRemaining(
                child: _buildMainContent(profiles),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: AppDimensions.appBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/icons/logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          
          const Spacer(),
          
          // Notification & Points
          Row(
            children: [
              // Notification Icon with Badge
              NotificationBadge(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    CupertinoIcons.bell,
                    color: AppColors.textPrimary,
                    size: AppDimensions.iconM,
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing8),
              
              // Points
              GestureDetector(
                onTap: () {
                  context.go(RouteNames.pointShop);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFA500),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.money_dollar,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '302',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 지역 필터
          _buildFilterChip(
            _selectedRegion,
            isSelected: _selectedRegion != '지역',
            onTap: () => _showRegionSelectorBottomSheet(),
          ),
          const SizedBox(width: 4),
          // 거리 필터
          _buildFilterChip(
            _selectedDistance,
            isSelected: _selectedDistance != '범위',
            selectedColor: Colors.pink,
            onTap: () => _showDistanceFilter(),
          ),
          const SizedBox(width: 4),
          // 인기 필터
          _buildFilterChip(
            _selectedPopularity,
            isSelected: _selectedPopularity != '인기',
            onTap: () => _showPopularityCustomSheet(),
          ),
          const SizedBox(width: 12),
          // VIP Frame 버튼
          GestureDetector(
            onTap: () => context.go('/vip'),
            child: Image.asset(
              'assets/icons/VIP Frame.png',
              width: 30,
              height: 30,
            ),
          ),
          const Spacer(),
          // 상점 버튼
          _buildFilterChip(
            '상점',
            isSelected: false,
            onTap: () => context.go(RouteNames.pointShop),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    Color? selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? Colors.black)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? (selectedColor ?? Colors.black)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (label != '상점') ...[
              const SizedBox(width: 4),
              Text(
                '>',
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<ProfileModel> profiles) {
    if (profiles.isEmpty) {
      return _buildEmptyState();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Swiper(
              controller: _swiperController,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                return ProfileCard(
                  profile: profiles[index],
                  onTap: () => _showProfileDetail(profiles[index]),
                );
              },
              onIndexChanged: (index) {
                // 4. 카드를 5번 넘기면 모달 노출
                setState(() {
                  _swipeCount++;
                });
                if (_swipeCount == 5) {
                  _showCardLimitModal();
                }
              },
              scrollDirection: Axis.horizontal,
              pagination: null,
            ),
          ),
        ),
        Positioned(
          bottom: AppDimensions.spacing32,
          left: 0,
          right: 0,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass Button - Gray X
        GestureDetector(
          onTap: _onPassTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6C6C6C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.xmark,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        // Super Chat Button - Green
        GestureDetector(
          onTap: _onSuperChatTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.paperplane_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        // Like Button - Pink Heart
        GestureDetector(
          onTap: _onLikeTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.heart_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart,
            size: AppDimensions.emptyStateImageSize,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppDimensions.emptyStateSpacing),
          Text(
            '오늘의 추천이 모두 끝났어요',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            '내일 새로운 인연을 만나보세요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _onPassTap() async {
    try {
      final result = await ref.read(matchProvider.notifier).passProfile();
      if (result != null && mounted) {
        _swiperController.next();
        _showActionResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('패스 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onLikeTap() async {
    try {
      final result = await ref.read(matchProvider.notifier).likeProfile();
      if (result != null && mounted) {
        _swiperController.next();
        _showActionResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onSuperChatTap() async {
    try {
      final currentProfile = ref.read(matchProvider).currentProfile;
      if (currentProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 정보를 불러올 수 없습니다.')),
        );
        return;
      }

      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => SuperChatBottomSheet(
          profileImageUrl: currentProfile.profileImages.isNotEmpty ? currentProfile.profileImages.first : '',
          name: currentProfile.name,
          age: currentProfile.age,
          location: currentProfile.location,
          onSend: (message) {
            Navigator.pop(context, message);
          },
        ),
      );
      
      if (result != null && result.isNotEmpty) {
        final matchResult = await ref.read(matchProvider.notifier).superChatProfile(result);
        if (matchResult != null && mounted) {
          _swiperController.next();
          _showActionResult(matchResult);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('슈퍼챗 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showProfileDetail(ProfileModel profile) {
    // TODO: 프로필 상세 화면으로 이동
  }

  void _showRegionSelectorBottomSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RegionSelectorBottomSheet(
        initialSido: _selectedRegion == '지역' ? null : _selectedRegion,
        initialGugun: null,
        onSelected: (sido, gugun) {
          setState(() {
            _selectedRegion = '$sido $gugun';
          });
          Navigator.pop(context, '$sido $gugun');
        },
      ),
    );
    if (result != null && result != _selectedRegion) {
      setState(() {
        _selectedRegion = result;
      });
      await ref.read(matchProvider.notifier).applyFilters({
        'region': result,
      });
    }
  }

  void _showPopularityCustomSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PopularitySheet(
        selected: _selectedPopularity,
        onSelect: (value) {
          setState(() {
            _selectedPopularity = value;
          });
          Navigator.pop(context, value);
        },
      ),
    );
    if (result != null && result != _selectedPopularity) {
      setState(() {
        _selectedPopularity = result;
      });
      await ref.read(matchProvider.notifier).applyFilters({
        'popularity': result,
      });
    }
  }

  void _showDistanceFilter() async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DistanceFilterSheet(
          selectedDistance: _selectedDistance,
        ),
      );
      
      if (result != null && result != _selectedDistance) {
        setState(() {
          _selectedDistance = result;
        });
        // Apply filter
        await ref.read(matchProvider.notifier).applyFilters({
          'distance': result,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('거리 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showVipFilter() {
    try {
      // VIP 탭으로 이동
      Navigator.of(context).pushNamed(RouteNames.vip);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('VIP 화면으로 이동 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _goToPointShop() {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포인트 상점 기능이 구현되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('포인트 상점으로 이동 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _goToVipProfiles() {
    try {
      Navigator.of(context).pushNamed(RouteNames.vip);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('VIP 프로필로 이동 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
  
  void _showActionResult(MatchResult result) {
    if (result.isMatch) {
      // Show match dialog
      _showMatchDialog(result);
    } else {
      // Show simple snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
      );
    }
  }
  
  void _showMatchDialog(MatchResult result) {
    if (result.matchedProfile == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchSuccessDialog(
        matchedProfile: result.matchedProfile!,
        onChatTap: () {
          // TODO: Navigate to chat screen
        },
        onContinueTap: () {
          // Continue with current flow
        },
      ),
    );
  }

  void _showCardLimitModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CardLimitDialog(),
    );
  }
  
  void _goToPointShopScreen() {
    context.go(RouteNames.pointShop);
  }

  void _goToVipScreen() {
    context.go(RouteNames.vip);
  }
}

// 커스텀 인기순 바텀시트 위젯
class _PopularitySheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PopularitySheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('인기 순 정렬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.xmark, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _popularityButton(
            context,
            icon: CupertinoIcons.paperplane_fill,
            text: '슈퍼챗 많이 받은 순',
            gradient: const LinearGradient(colors: [Color(0xFF3FE37F), Color(0xFF1CB5E0)]),
            selected: selected == '슈퍼챗 많이 받은 순',
            onTap: () => onSelect('슈퍼챗 많이 받은 순'),
          ),
          const SizedBox(height: 16),
          _popularityButton(
            context,
            icon: CupertinoIcons.heart_fill,
            text: '좋아요 많은 순',
            gradient: const LinearGradient(colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)]),
            selected: selected == '좋아요 많은 순',
            onTap: () => onSelect('좋아요 많은 순'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('설정', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _popularityButton(BuildContext context, {required IconData icon, required String text, required LinearGradient gradient, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32),
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 카드 제한 모달
class _CardLimitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            const Text('오늘의 추천 카드는\n여기까지에요', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            const Text('더 많은 상대를 보고싶으면 [추천카드 더 보기]를 사용할 수 있습니다.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('이용권 사용하기 : 3회 남음', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('이용권 구매 이동하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}