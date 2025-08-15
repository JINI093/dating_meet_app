import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/user_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/vip_provider.dart';
import '../../models/vip_model.dart';


// Bottom Navigation State Provider
final bottomNavigationProvider = StateNotifierProvider<BottomNavigationNotifier, int>(
  (ref) => BottomNavigationNotifier(),
);

class BottomNavigationNotifier extends StateNotifier<int> {
  BottomNavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

class BottomNavigationScreen extends ConsumerWidget {
  final Widget child;

  const BottomNavigationScreen({
    super.key,
    required this.child,
  });

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: CupertinoIcons.home,
      activeIcon: CupertinoIcons.home,
      label: '홈',
      route: '/home',
    ),
    BottomNavItem(
      icon: CupertinoIcons.heart,
      activeIcon: CupertinoIcons.heart_fill,
      label: '좋아요',
      route: '/likes',
    ),
    BottomNavItem(
      icon: null, // VIP는 이미지로 대체
      activeIcon: null,
      label: 'VIP',
      route: '/vip',
    ),
    BottomNavItem(
      icon: CupertinoIcons.chat_bubble,
      activeIcon: CupertinoIcons.chat_bubble_fill,
      label: '채팅',
      route: '/chat',
    ),
    BottomNavItem(
      icon: null, // 프로필은 이미지로 대체
      activeIcon: null,
      label: '프로필',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavigationProvider);
    final userState = ref.watch(userProvider);
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

    // Update provider if needed
    if (routeIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bottomNavigationProvider.notifier).setIndex(routeIndex);
      });
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, routeIndex, userState, unreadLikesCount),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int currentIndex, userState, int unreadLikesCount) {
    // 사용자 프로필 이미지 가져오기
    String? profileImageUrl;
    if (userState.currentUser?.profileImages != null && userState.currentUser!.profileImages.isNotEmpty) {
      profileImageUrl = userState.currentUser!.profileImages.first;
    }
    
    return Container(
      height: AppDimensions.bottomNavHeight + MediaQuery.of(context).padding.bottom,
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
              profileImageUrl: profileImageUrl,
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
    String? profileImageUrl,
    int? unreadLikesCount,
  }) {
    Widget iconWidget;
    if (index == 2) {
      // VIP: Use VIP.png asset
      iconWidget = Image.asset(
        'assets/icons/VIP.png',
        width: 32,
        height: 32,
      );
    } else if (index == 4) {
      // 프로필: 원형 프로필 이미지 또는 기본 아바타
      iconWidget = _buildProfileImage(profileImageUrl, isActive);
    } else if (index == 1) {
      // 좋아요: 뱃지가 있는 하트 아이콘
      iconWidget = _buildLikesIcon(isActive, unreadLikesCount ?? 0);
    } else {
      iconWidget = Icon(
        isActive ? (item.activeIcon ?? item.icon) : item.icon,
        color: isActive ? Colors.black : Colors.grey,
        size: 28,
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

  void _onNavItemTap(BuildContext context, WidgetRef ref, int index, String route) {
    ref.read(bottomNavigationProvider.notifier).setIndex(index);
    
    // VIP 버튼 클릭 시 특별 처리
    if (index == 2) { // VIP 탭
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
        // 비VIP 사용자는 바로 구매 화면으로
        context.go('/vip/purchase');
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
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isActive 
            ? Border.all(color: AppColors.primary, width: 2) 
            : null,
      ),
      child: ClipOval(
        child: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? Image.network(
                profileImageUrl,
                width: 28,
                height: 28,
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
    final icon = Icon(
      isActive ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      color: isActive ? Colors.black : Colors.grey,
      size: 28,
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
  final IconData? icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}