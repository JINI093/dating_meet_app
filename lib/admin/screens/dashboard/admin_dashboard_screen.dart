import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/chart_card.dart';

/// 관리자 대시보드 화면
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AdminTheme.mobileBreakpoint;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title
        Text(
          '대시보드',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AdminTheme.spacingXL),
        
        // Stats Grid
        _buildStatsGrid(isMobile),
        const SizedBox(height: AdminTheme.spacingXL),
        
        // Charts Grid
        _buildChartsGrid(isMobile),
        const SizedBox(height: AdminTheme.spacingXL),
        
        // Recent Activity
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildStatsGrid(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: AdminTheme.spacingM,
      crossAxisSpacing: AdminTheme.spacingM,
      childAspectRatio: isMobile ? 1.5 : 1.8,
      children: [
        StatCard(
          title: '총 회원수',
          value: '12,543',
          icon: Icons.people_outline,
          color: AdminTheme.primaryColor,
          trend: '+5.2%',
          trendUp: true,
        ),
        StatCard(
          title: 'VIP 회원',
          value: '2,845',
          icon: Icons.workspace_premium_outlined,
          color: AdminTheme.secondaryColor,
          trend: '+12.8%',
          trendUp: true,
        ),
        StatCard(
          title: '오늘 매칭',
          value: '387',
          icon: Icons.favorite_outline,
          color: AdminTheme.accentColor,
          trend: '-2.1%',
          trendUp: false,
        ),
        StatCard(
          title: '이번달 매출',
          value: '₩45.2M',
          icon: Icons.monetization_on_outlined,
          color: AdminTheme.successColor,
          trend: '+8.5%',
          trendUp: true,
        ),
      ],
    );
  }

  Widget _buildChartsGrid(bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: isMobile ? 1 : 2,
              child: ChartCard(
                title: '회원 가입 추이',
                height: 300,
                child: _buildUserRegistrationChart(),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: ChartCard(
                  title: '성별 분포',
                  height: 300,
                  child: _buildGenderChart(),
                ),
              ),
            ],
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: AdminTheme.spacingM),
          ChartCard(
            title: '성별 분포',
            height: 300,
            child: _buildGenderChart(),
          ),
        ],
        const SizedBox(height: AdminTheme.spacingM),
        ChartCard(
          title: '매출 현황',
          height: 300,
          child: _buildRevenueChart(),
        ),
      ],
    );
  }

  Widget _buildUserRegistrationChart() {
    return Padding(
      padding: const EdgeInsets.all(AdminTheme.spacingM),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AdminTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 48,
                color: AdminTheme.primaryColor,
              ),
              SizedBox(height: AdminTheme.spacingM),
              Text(
                '사용자 등록 차트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.primaryTextColor,
                ),
              ),
              SizedBox(height: AdminTheme.spacingS),
              Text(
                '차트 라이브러리 설치 후 표시됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AdminTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChart() {
    return Padding(
      padding: const EdgeInsets.all(AdminTheme.spacingM),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AdminTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: AdminTheme.accentColor,
              ),
              SizedBox(height: AdminTheme.spacingM),
              Text(
                '성별 분포 차트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.primaryTextColor,
                ),
              ),
              SizedBox(height: AdminTheme.spacingS),
              Text(
                '남성 58% | 여성 42%',
                style: TextStyle(
                  fontSize: 14,
                  color: AdminTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Padding(
      padding: const EdgeInsets.all(AdminTheme.spacingM),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AdminTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: AdminTheme.successColor,
              ),
              SizedBox(height: AdminTheme.spacingM),
              Text(
                '매출 현황 차트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.primaryTextColor,
                ),
              ),
              SizedBox(height: AdminTheme.spacingS),
              Text(
                '월별 매출 추이',
                style: TextStyle(
                  fontSize: 12,
                  color: AdminTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 활동',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('모두 보기'),
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingM),
            ...List.generate(5, (index) => _buildActivityItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {'type': 'user', 'message': '새로운 회원이 가입했습니다', 'time': '2분 전'},
      {'type': 'vip', 'message': 'VIP 회원권이 구매되었습니다', 'time': '5분 전'},
      {'type': 'report', 'message': '신고가 접수되었습니다', 'time': '12분 전'},
      {'type': 'payment', 'message': '결제가 완료되었습니다', 'time': '30분 전'},
      {'type': 'match', 'message': '새로운 매칭이 성사되었습니다', 'time': '1시간 전'},
    ];
    
    final activity = activities[index];
    IconData icon;
    Color color;
    
    switch (activity['type']) {
      case 'user':
        icon = Icons.person_add_outlined;
        color = AdminTheme.primaryColor;
        break;
      case 'vip':
        icon = Icons.workspace_premium_outlined;
        color = AdminTheme.secondaryColor;
        break;
      case 'report':
        icon = Icons.flag_outlined;
        color = AdminTheme.warningColor;
        break;
      case 'payment':
        icon = Icons.payment_outlined;
        color = AdminTheme.successColor;
        break;
      case 'match':
        icon = Icons.favorite_outline;
        color = AdminTheme.accentColor;
        break;
      default:
        icon = Icons.info_outline;
        color = AdminTheme.infoColor;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminTheme.spacingS),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AdminTheme.radiusM),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AdminTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message']!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  activity['time']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.secondaryTextColor,
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