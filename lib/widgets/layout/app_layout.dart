import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'sidebar.dart';
import 'header.dart';

class AppLayout extends ConsumerStatefulWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  bool _isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          Sidebar(
            isCollapsed: _isSidebarCollapsed,
            onToggle: _toggleSidebar,
          ),
          
          // 메인 콘텐츠 영역
          Expanded(
            child: Column(
              children: [
                // 헤더
                Header(
                  onMenuPressed: _toggleSidebar,
                  onThemeToggle: () {
                    ref.read(themeViewModelProvider.notifier).toggleTheme();
                  },
                  onSignOut: () async {
                    ref.read(authViewModelProvider.notifier).signOut();
                    if (mounted) {
                      context.go('/signin');
                    }
                  },
                ),
                
                // 메인 콘텐츠
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 