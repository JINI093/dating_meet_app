import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

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
import '../../providers/matches_provider.dart';
import '../../routes/route_names.dart';
import '../../widgets/dialogs/region_selector_bottom_sheet.dart';
import '../notification/notification_screen.dart';
import '../chat/chat_room_screen.dart';
import '../../widgets/navigation/vip_route_guard.dart';
import '../../services/daily_counter_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../providers/likes_provider.dart';
import '../../models/like_model.dart';
import '../../providers/points_provider.dart';
import '../../utils/logger.dart';
import '../profile/other_profile_screen.dart';
import '../../providers/heart_provider.dart';
import '../../widgets/dialogs/daily_match_end_dialog.dart';
import '../../providers/recommend_card_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final SwiperController _swiperController = SwiperController();
  final DailyCounterService _dailyCounterService = DailyCounterService();

  // Filter states
  List<String> _selectedRegions = [];
  double _selectedDistance = 15.0; // km 단위로 변경
  bool _isDistanceFilterActive = false; // 거리 필터 활성화 상태
  String _selectedPopularity = '인기';
  final bool _isVipFilterActive = false;
  Position? _userPosition;
  int _swipeCount = 0;

  // 다이얼로그 중복 호출 방지 플래그 (static으로 전역 관리)
  static bool _isCardLimitDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // 초기화 시 matchProvider 인덱스 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchProvider.notifier).setCurrentIndex(0);
      // 포인트 데이터 로드
      ref.read(pointsProvider.notifier).loadUserPoints();
      // 하트 데이터 로드
      ref.read(heartProvider.notifier).refreshHearts();
      // 추천카드 데이터 로드
      ref.read(recommendCardProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final profiles = matchState.profiles;
    final isLoading = matchState.isLoading;
    final error = matchState.error;

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
            else if (error != null)
              SliverFillRemaining(
                child: _buildErrorState(error),
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
                      Consumer(
                        builder: (context, ref, child) {
                          final pointsState = ref.watch(pointsProvider);
                          return Text(
                            '${pointsState.currentPoints}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          );
                        },
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 지역 필터
                  _buildFilterChip(
                    _selectedRegions.isEmpty
                        ? '지역'
                        : _selectedRegions.length == 1
                            ? _selectedRegions.first
                            : '지역 ${_selectedRegions.length}개',
                    isSelected: _selectedRegions.isNotEmpty,
                    onTap: () => _showRegionSelectorBottomSheet(),
                  ),
                  const SizedBox(width: 4),
                  // 거리 필터
                  _buildFilterChip(
                    _isDistanceFilterActive
                        ? '${_selectedDistance.round()}km'
                        : '거리',
                    isSelected: _isDistanceFilterActive,
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
                  const SizedBox(width: 4),
                  // VIP Frame 버튼
                  GestureDetector(
                    onTap: () => context.go('/ticket-shop?tab=4'),
                    child: Image.asset(
                      'assets/icons/ic_vip_home.png',
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 상점 버튼을 오른쪽에 고정
          _buildFilterChip(
            '상점',
            isSelected: false,
            onTap: () => context.go(RouteNames.pointShop),
          )
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
          color: isSelected ? (selectedColor ?? Colors.black) : Colors.white,
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
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (label != '상점') ...[
              const SizedBox(width: 4),
              Text(
                '>',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
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

    // 프로필을 좋아요 수 기준으로 정렬하여 순위 계산
    final sortedProfiles = List<ProfileModel>.from(profiles)
      ..sort((a, b) => b.likeCount.compareTo(a.likeCount));

    // 각 프로필의 순위를 매핑
    final profileRankMap = <String, int>{};
    for (int i = 0; i < sortedProfiles.length; i++) {
      profileRankMap[sortedProfiles[i].id] = i + 1;
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
                final profile = profiles[index];
                final rank = profileRankMap[profile.id] ?? 0;

                return ProfileCard(
                  profile: profile,
                  popularityRank: rank,
                  onTap: () => _showProfileDetail(profile),
                );
              },
              onIndexChanged: (index) {
                // 스와이프 카운트 업데이트 및 matchProvider와 동기화
                setState(() {
                  _swipeCount++;
                });

                // matchProvider의 currentIndex와 동기화
                ref.read(matchProvider.notifier).setCurrentIndex(index);

                // 일일 프로필 조회 카운터 증가
                _incrementDailyProfileCounter();

                // 4. 카드를 5번 넘기면 모달 노출
                if (_swipeCount == 5) {
                  print("=-=-=-=-=-=-=-=-==");
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
        // Pass Button
        GestureDetector(
          onTap: _onPassTap,
          child: Image.asset(
            'assets/icons/ic_close_homecard.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),

        // Super Chat Button
        GestureDetector(
          onTap: _onSuperChatTap,
          child: Image.asset(
            'assets/icons/ic_superchat_homecard.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),

        // Like Button
        GestureDetector(
          onTap: _onLikeTap,
          child: Image.asset(
            'assets/icons/ic_like_homecard.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showDailyMatchEndDialog(context);
    // });

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

  Widget _buildErrorState(String error) {
    // "오늘의 매칭이 모두 끝났습니다" 메시지인 경우 특별한 UI 표시
    if (error.contains('오늘의 매칭이 모두 끝났습니다')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDailyMatchEndDialog(context);
      });

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_circle,
              size: AppDimensions.emptyStateImageSize,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.emptyStateSpacing),
            Text(
              '오늘의 매칭이 끝났어요!',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              '내일 더 많은 새로운 인연을 만나보세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 일반적인 에러 상태
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: AppDimensions.emptyStateImageSize,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.emptyStateSpacing),
          Text(
            '프로필을 불러올 수 없어요',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton(
            onPressed: () {
              ref.read(matchProvider.notifier).refreshProfiles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('다시 시도'),
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
      // 먼저 현재 프로필 확인
      final currentProfile = ref.read(matchProvider).currentProfile;
      if (currentProfile == null) return;

      // 이미 좋아요를 누른 프로필인지 확인
      final sentLikesState = ref.read(likesProvider);
      final alreadyLiked = sentLikesState.sentLikes.any((like) =>
          like.toProfileId == currentProfile.id &&
          like.likeType != LikeType.pass);

      if (alreadyLiked) {
        // 이미 좋아요를 누른 상대
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '이미 좋아요를 누른 상대입니다',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),
          );
        }
        return;
      }

      // 하트가 충분한지 확인
      final heartState = ref.read(heartProvider);
      const requiredHearts = 1; // 좋아요를 보내는데 필요한 하트 수

      if (heartState.currentHearts < requiredHearts) {
        // 하트가 부족한 경우 알림 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('하트가 부족합니다. (현재: ${heartState.currentHearts}개)'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: '하트 구매',
                textColor: Colors.white,
                onPressed: () {
                  print('💝 하트 구매 버튼 클릭됨: ${RouteNames.ticketShop}');
                  try {
                    context.push(RouteNames.ticketShop);
                  } catch (e) {
                    print('❌ 라우트 이동 오류: $e');
                  }
                },
              ),
            ),
          );
        }
        return;
      }

      // 하트 소모 처리
      final heartSpent = await ref.read(heartProvider.notifier).spendHearts(
            requiredHearts,
            description: '좋아요 보내기',
          );

      if (!heartSpent) {
        // 하트 소모 실패
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('하트 사용에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 좋아요 보내기
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
      // 먼저 하트가 충분한지 확인
      final heartState = ref.read(heartProvider);
      const requiredHearts = 3; // 슈퍼챗을 보내는데 필요한 하트 수

      if (heartState.currentHearts < requiredHearts) {
        // 하트가 부족한 경우 알림 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '슈퍼챗을 보내려면 하트 $requiredHearts개가 필요합니다. (현재: ${heartState.currentHearts}개)'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: '하트 구매',
                textColor: Colors.white,
                onPressed: () {
                  print('💝 하트 구매 버튼 클릭됨: ${RouteNames.ticketShop}');
                  try {
                    context.push(RouteNames.ticketShop);
                  } catch (e) {
                    print('❌ 라우트 이동 오류: $e');
                  }
                },
              ),
            ),
          );
        }
        return;
      }

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
          profileImageUrl: currentProfile.profileImages.isNotEmpty
              ? currentProfile.profileImages.first
              : '',
          name: currentProfile.name,
          age: currentProfile.age,
          location: currentProfile.location,
          onSend: (message) {
            Navigator.pop(context, message);
          },
        ),
      );

      if (result != null && result.isNotEmpty) {
        // 하트 소모 처리
        final heartSpent = await ref.read(heartProvider.notifier).spendHearts(
              requiredHearts,
              description: '슈퍼챗 보내기',
            );

        if (!heartSpent) {
          // 하트 소모 실패
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('하트 사용에 실패했습니다. 다시 시도해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // 슈퍼챗 보내기
        final matchResult =
            await ref.read(matchProvider.notifier).superChatProfile(result);
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
    // 프로필 상세 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _incrementDailyProfileCounter() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn ||
          authState.currentUser?.user?.userId == null) {
        return;
      }

      final userId = authState.currentUser!.user!.userId;
      final userState = ref.read(userProvider);
      final vipTier = userState.vipTier ?? 'FREE';

      await _dailyCounterService.incrementCounter(userId, vipTier);
    } catch (e) {
      // 일일 카운터 증가 실패는 조용히 처리
      Logger.log('Failed to increment daily profile counter: $e',
          name: 'MainScreen');
    }
  }

  void _showRegionSelectorBottomSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RegionSelectorBottomSheet(
        initialSelectedRegions: _selectedRegions,
        onSelected: (selectedRegions) {
          setState(() {
            _selectedRegions = selectedRegions;
          });
        },
      ),
    );
    if (result != null) {
      setState(() {
        _selectedRegions = result;
      });
      await ref.read(matchProvider.notifier).applyFilters({
        'regions': result,
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
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DistanceFilterSheet(
          currentDistance: _selectedDistance,
        ),
      );

      if (result != null) {
        final distance = result['distance'] as double;
        final position = result['position'] as Position?;
        final isLocationEnabled = result['isLocationEnabled'] as bool;

        setState(() {
          _selectedDistance = distance;
          _userPosition = position;
          _isDistanceFilterActive = true; // 거리 필터 활성화
        });

        // Apply filter with distance and location
        await ref.read(matchProvider.notifier).applyFilters({
          'distance': distance,
          'userPosition': position,
          'isLocationEnabled': isLocationEnabled,
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
      // Show match success snackbar and automatically navigate to chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to chat room automatically after a brief delay
      if (result.matchModel != null) {
        // Add match to matches provider so it appears in chat list
        ref.read(matchesProvider.notifier).addNewMatch(result.matchModel!);

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            // Use direct Navigator.push instead of GoRouter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  match: result.matchModel!,
                  chatId: result.matchModel!.id,
                ),
              ),
            );
          }
        });
      }
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
          // Navigate to chat screen with match data
          Navigator.pop(context); // Close dialog first

          if (result.matchModel != null) {
            final matchId = result.matchModel!.id;
            final chatRoomPath = RouteNames.getChatRoomPath(matchId);
            context.push(chatRoomPath, extra: result.matchModel);
          }
        },
        onContinueTap: () {
          // Continue with current flow
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCardLimitModal() {
    // 이미 다이얼로그가 열려있는지 확인하여 중복 호출 방지
    if (_isCardLimitDialogOpen) {
      return;
    }

    // Navigator에서 현재 열려있는 다이얼로그 확인
    if (Navigator.of(context).canPop()) {
      return;
    }

    // ModalRoute에서 현재 열려있는 다이얼로그 확인
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && currentRoute.isCurrent == false) {
      return;
    }

    // 전역 플래그를 true로 설정
    _isCardLimitDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => _CardLimitDialog(),
    ).then((_) {
      // 다이얼로그가 닫힐 때 플래그를 false로 설정
      _isCardLimitDialogOpen = false;
    }).catchError((_) {
      // 에러가 발생해도 플래그를 false로 설정
      _isCardLimitDialogOpen = false;
    });
  }

  void _goToPointShopScreen() {
    context.go(RouteNames.pointShop);
  }

  void _goToVipScreen() {
    context.go(RouteNames.vip);
  }
}

// 커스텀 인기순 바텀시트 위젯
class _PopularitySheet extends StatefulWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  String? tempSelected = null;

  _PopularitySheet({required this.selected, required this.onSelect}) {
    tempSelected = selected;
  }

  @override
  State<_PopularitySheet> createState() => _PopularitySheetState();
}

class _PopularitySheetState extends State<_PopularitySheet> {
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
              const Text('인기 순 정렬',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            gradient: const LinearGradient(
                colors: [Color(0xFF3FE37F), Color(0xFF1CB5E0)]),
            selected: widget.tempSelected == '슈퍼챗 많이 받은 순',
            onTap: () {
              setState(() {
                if (widget.tempSelected == '슈퍼챗 많이 받은 순') {
                  widget.tempSelected = '인기';
                } else {
                  widget.tempSelected = '슈퍼챗 많이 받은 순';
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _popularityButton(
            context,
            icon: CupertinoIcons.heart_fill,
            text: '좋아요 많은 순',
            gradient: const LinearGradient(
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)]),
            selected: widget.tempSelected == '좋아요 많은 순',
            onTap: () {
              setState(() {
                if (widget.tempSelected == '좋아요 많은 순') {
                  widget.tempSelected = '인기';
                } else {
                  widget.tempSelected = '좋아요 많은 순';
                }
              });
            },
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              widget.onSelect(widget.tempSelected ?? '인기');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 19),
              decoration: BoxDecoration(
                color: Color(0xFF000000),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Text(
                "설정",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _popularityButton(BuildContext context,
      {required IconData icon,
      required String text,
      required LinearGradient gradient,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: selected ? Colors.black : Colors.transparent,
              width: 2,
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 카드 제한 모달
class _CardLimitDialog extends StatefulWidget {
  @override
  State<_CardLimitDialog> createState() => _CardLimitDialogState();
}

class _CardLimitDialogState extends State<_CardLimitDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // 다이얼로그가 닫힐 때 전역 플래그 초기화
          _MainScreenState._isCardLimitDialogOpen = false;
          return true;
        },
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                const Text('오늘의 추천 카드는\n여기까지에요',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 12),
                const Text('더 많은 상대를 보고싶으면 [추천카드 더 보기]를 사용할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('이용권 사용하기 : 3회 남음',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('이용권 구매 이동하기',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
