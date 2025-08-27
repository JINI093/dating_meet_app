import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/user_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/vip_provider.dart';
import '../../models/vip_model.dart';

// Bottom Navigation State Provider
final bottomNavigationProvider =
    StateNotifierProvider<BottomNavigationNotifier, int>(
  (ref) => BottomNavigationNotifier(),
);

class BottomNavigationNotifier extends StateNotifier<int> {
  BottomNavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

class BottomNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const BottomNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends ConsumerState<BottomNavigationScreen> {
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final profileImageFromPrefs = prefs.getString("profile_image");

    String? finalProfileImage;
    if (profileImageFromPrefs != null && profileImageFromPrefs.isNotEmpty) {
      finalProfileImage = profileImageFromPrefs;
    } else {
      // SharedPreferences에 없으면 userState에서 가져오기
      final userState = ref.read(userProvider);
      if (userState.currentUser?.profileImages != null &&
          userState.currentUser!.profileImages.isNotEmpty) {
        finalProfileImage = userState.currentUser!.profileImages.first;
      }
    }

    if (mounted) {
      setState(() {
        _profileImageUrl = finalProfileImage;
      });
    }
  }

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: "assets/icons/tab_home_unselected.png",
      activeIcon: "assets/icons/tab_home_selected.png",
      label: '홈',
      route: '/home',
    ),
    BottomNavItem(
      icon: "assets/icons/tab_like_unselected.png",
      activeIcon: "assets/icons/tab_like_selected.png",
      label: '좋아요',
      route: '/likes',
    ),
    BottomNavItem(
      icon: "", // VIP는 이미지로 대체
      activeIcon: "",
      label: 'VIP',
      route: '/vip',
    ),
    BottomNavItem(
      icon: "assets/icons/tab_chat_unselected.png",
      activeIcon: "assets/icons/tab_chat_selected.png",
      label: '채팅',
      route: '/chat',
    ),
    BottomNavItem(
      icon: "", // 프로필은 이미지로 대체
      activeIcon: "",
      label: '프로필',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavigationProvider);
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final unreadLikesCount = ref.watch(unreadLikesCountProvider);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // Determine current index based on route
    int routeIndex = 0;
    for (int i = 0; i < _navItems.length; i++) {
      if (currentRoute.startsWith(_navItems[i].route)) {
        routeIndex = i;
        break;
      }
    }

    // // Update provider if needed
    // if (routeIndex != currentIndex) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     ref.read(bottomNavigationProvider.notifier).setIndex(routeIndex);
    //   });
    // }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigationBar(
          context: context,
          ref: ref,
          currentIndex: currentIndex,
          userState: userState,
          userNotifier: userNotifier,
          unreadLikesCount: unreadLikesCount),
    );
  }

  Widget _buildBottomNavigationBar(
      {required BuildContext context,
      required WidgetRef ref,
      required int currentIndex,
      required UserState userState,
      required UserNotifier userNotifier,
      required int unreadLikesCount}) {
    return Container(
      height:
          AppDimensions.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderNormal,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            _navItems.length,
            (index) => _buildNavItem(
              context,
              ref,
              _navItems[index],
              index,
              currentIndex == index,
              unreadLikesCount: unreadLikesCount,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    BottomNavItem item,
    int index,
    bool isActive, {
    int? unreadLikesCount,
  }) {
    Widget iconWidget;
    if (index == 2) {
      // VIP: Use VIP.png asset
      iconWidget = Image.asset(
        'assets/icons/VIP.png',
        width: 45,
        height: 45,
        fit: BoxFit.fitWidth,
      );
    } else if (index == 4) {
      // 프로필: 원형 프로필 이미지 또는 기본 아바타
      iconWidget = _buildProfileImage(_profileImageUrl, isActive);
    } else if (index == 1) {
      // 좋아요: 뱃지가 있는 하트 아이콘
      iconWidget = _buildLikesIcon(isActive, unreadLikesCount ?? 0);
    } else {
      iconWidget = Image.asset(
        isActive ? item.activeIcon : item.icon,
        fit: BoxFit.fitWidth,
        width: 30,
        height: 30,
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(context, ref, index, item.route),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Center(
            child: iconWidget,
          ),
        ),
      ),
    );
  }

  void _onNavItemTap(
      BuildContext context, WidgetRef ref, int index, String route) {
    ref.read(bottomNavigationProvider.notifier).setIndex(index);

    // 프로필 탭 클릭 시 프로필 이미지 새로 로드
    if (index == 4) {
      _loadProfileImage();
    }

    // VIP 버튼 클릭 시 특별 처리
    if (index == 2) {
      // VIP 탭
      final vipState = ref.read(vipProvider);
      final userState = ref.read(userProvider);

      // VIP 상태 확인
      final isVip = _checkVipStatus(userState, vipState);

      if (isVip) {
        // VIP 사용자는 기존 VIP 화면으로
        final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
        if (currentRoute != route) {
          context.go(route);
        }
      } else {
        // 비VIP 사용자는 바로 이용권 구매 VIP 탭으로
        context.go('/ticket-shop?tab=4');
      }
    } else {
      // 다른 탭들은 기존 방식대로 처리
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
      if (currentRoute != route) {
        context.go(route);
      }
    }
  }

  Widget _buildProfileImage(String? profileImageUrl, bool isActive) {
    return Container(
      width: 34,
      height: 34,
      decoration:
          BoxDecoration(color: Colors.transparent, shape: BoxShape.rectangle),
      alignment: Alignment.center,
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              isActive ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: ClipOval(
          child: profileImageUrl != null && profileImageUrl.isNotEmpty
              ? Image.network(
                  profileImageUrl,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultProfileImage();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildDefaultProfileImage();
                  },
                )
              : _buildDefaultProfileImage(),
        ),
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.divider,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// VIP 상태 확인
  bool _checkVipStatus(UserState userState, VipState vipState) {
    // 1. VIP 상태에서 확인
    if (vipState.isVipUser && vipState.currentSubscription != null) {
      final subscription = vipState.currentSubscription!;
      // 구독이 활성화되어 있고 만료되지 않았는지 확인
      if (subscription.status == VipSubscriptionStatus.active &&
          subscription.endDate.isAfter(DateTime.now())) {
        return true;
      }
    }

    // 2. 사용자 프로필에서 확인
    if (userState.currentUser?.isVip == true) {
      return true;
    }

    return false;
  }

  Widget _buildLikesIcon(bool isActive, int unreadCount) {
    final icon = Image.asset(
      isActive ? "assets/icons/tab_like_selected.png"  : "assets/icons/tab_like_unselected.png",
      width: 30,
      height: 30,
      fit: BoxFit.fitWidth,
    );

    if (unreadCount > 0) {
      return Stack(
        children: [
          icon,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return icon;
  }
}

class BottomNavItem {
  final String icon;
  final String activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
