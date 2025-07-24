import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';

class Header extends ConsumerWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onThemeToggle;
  final VoidCallback onSignOut;

  const Header({
    super.key,
    required this.onMenuPressed,
    required this.onThemeToggle,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);
    final userData = authViewModel.userData;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 메뉴 버튼
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onMenuPressed,
          ),
          
          const SizedBox(width: 16),
          
          // 페이지 제목 (현재 라우트에 따라 동적 변경)
          Expanded(
            child: Text(
              _getPageTitle(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 우측 액션 버튼들
          Row(
            children: [
              // 테마 토글 버튼
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: onThemeToggle,
              ),
              
              const SizedBox(width: 8),
              
              // 알림 버튼
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // 알림 기능 구현
                },
              ),
              
              const SizedBox(width: 8),
              
              // 사용자 메뉴
              if (userData != null) ...[
                PopupMenuButton<String>(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          userData['name']?[0] ?? 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userData['name'] ?? '관리자',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: const Row(
                        children: [
                          Icon(Icons.person_outline),
                          SizedBox(width: 8),
                          Text('프로필'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: const Row(
                        children: [
                          Icon(Icons.settings_outlined),
                          SizedBox(width: 8),
                          Text('설정'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'signout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('로그아웃'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        // 프로필 페이지로 이동
                        break;
                      case 'settings':
                        // 설정 페이지로 이동
                        break;
                      case 'signout':
                        onSignOut();
                        break;
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getPageTitle(BuildContext context) {
    // 현재 라우트에 따라 페이지 제목 반환
    // 실제로는 GoRouter를 사용하여 현재 라우트를 확인해야 함
    return '대시보드';
  }
} 