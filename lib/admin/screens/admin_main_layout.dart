import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/admin_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_header.dart';

/// 관리자 메인 레이아웃
class AdminMainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminMainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends ConsumerState<AdminMainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AdminTheme.mobileBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AdminTheme.backgroundColor,
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                currentRoute: widget.currentRoute,
                isCollapsed: false,
                onToggle: () {
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Desktop/Tablet Sidebar
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSidebarCollapsed ? 80 : 280,
              child: AdminSidebar(
                currentRoute: widget.currentRoute,
                isCollapsed: _isSidebarCollapsed,
                onToggle: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
              ),
            ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                AdminHeader(
                  onMenuTap: isMobile
                      ? () {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      : null,
                ),
                
                // Content Area
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(
                      isMobile ? AdminTheme.spacingM : AdminTheme.spacingL,
                    ),
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