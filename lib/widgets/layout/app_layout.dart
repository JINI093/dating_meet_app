import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';
import 'sidebar.dart';
import 'header.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
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
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                  onSignOut: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
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