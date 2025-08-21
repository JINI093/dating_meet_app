import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../models/banner_model.dart';
import '../../providers/banner_provider.dart';
import '../../widgets/banner_management_section.dart';

/// 관리자 설정 화면
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '설정 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              onPressed: () {
                ref.read(adminBannerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '전체 배너'),
              Tab(text: '메인 광고'),
              Tab(text: '포인트 상점'),
              Tab(text: '이용약관'),
            ],
            indicator: BoxDecoration(
              color: AdminTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            dividerColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const BannerManagementSection(), // 전체 배너
              const BannerManagementSection(type: BannerType.mainAd), // 메인 광고
              const BannerManagementSection(type: BannerType.pointStore), // 포인트 상점
              const BannerManagementSection(type: BannerType.terms), // 이용약관
            ],
          ),
        ),
      ],
    );
  }
}