import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';


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
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, routeIndex),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int currentIndex) {
    // 임시 프로필 이미지 (실제 연동 시 provider 등에서 가져오세요)
    final String? profileImageUrl = null; // ex) 'https://randomuser.me/api/portraits/men/1.jpg';
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
      // 프로필: 원형 프로필 이미지 or 기본 아바타
      iconWidget = profileImageUrl != null
          ? CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(profileImageUrl),
            )
          : CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF2196F3),
              backgroundImage: AssetImage('assets/icons/profile.png'),
            );
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
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    if (currentRoute != route) {
      context.go(route);
    }
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