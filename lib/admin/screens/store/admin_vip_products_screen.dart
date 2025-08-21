import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// VIP 상품 관리 화면
class AdminVipProductsScreen extends ConsumerStatefulWidget {
  const AdminVipProductsScreen({super.key});

  @override
  ConsumerState<AdminVipProductsScreen> createState() => _AdminVipProductsScreenState();
}

class _AdminVipProductsScreenState extends ConsumerState<AdminVipProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VIP 상품 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addVipProduct(),
              icon: const Icon(Icons.add),
              label: const Text('VIP 상품 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // VIP Statistics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'VIP 상품 수',
                value: '8',
                color: AdminTheme.secondaryColor,
                icon: Icons.star,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '이번 달 VIP 가입',
                value: '156',
                color: AdminTheme.infoColor,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: 'VIP 매출',
                value: '2,450,000원',
                color: AdminTheme.successColor,
                icon: Icons.monetization_on,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '평균 구독 기간',
                value: '3.2개월',
                color: AdminTheme.warningColor,
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // VIP Plans
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIP 구독 플랜',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: AdminTheme.spacingL,
                      mainAxisSpacing: AdminTheme.spacingL,
                      children: [
                        _buildVipPlanCard(
                          title: '1개월 VIP',
                          price: '29,000원',
                          originalPrice: '35,000원',
                          discount: '17%',
                          features: [
                            '무제한 좋아요',
                            '슈퍼챗 20개',
                            '프로필 부스트',
                            '읽음 확인',
                          ],
                          isPopular: false,
                          color: AdminTheme.primaryColor,
                        ),
                        _buildVipPlanCard(
                          title: '3개월 VIP',
                          price: '69,000원',
                          originalPrice: '87,000원',
                          discount: '21%',
                          features: [
                            '무제한 좋아요',
                            '슈퍼챗 80개',
                            '프로필 부스트',
                            '읽음 확인',
                            '특별 배지',
                          ],
                          isPopular: true,
                          color: AdminTheme.secondaryColor,
                        ),
                        _buildVipPlanCard(
                          title: '6개월 VIP',
                          price: '129,000원',
                          originalPrice: '174,000원',
                          discount: '26%',
                          features: [
                            '무제한 좋아요',
                            '슈퍼챗 200개',
                            '프로필 부스트',
                            '읽음 확인',
                            '특별 배지',
                            '우선 매칭',
                          ],
                          isPopular: false,
                          color: AdminTheme.successColor,
                        ),
                        _buildVipPlanCard(
                          title: '12개월 VIP',
                          price: '199,000원',
                          originalPrice: '348,000원',
                          discount: '43%',
                          features: [
                            '무제한 좋아요',
                            '슈퍼챗 500개',
                            '프로필 부스트',
                            '읽음 확인',
                            '특별 배지',
                            '우선 매칭',
                            '전담 매니저',
                          ],
                          isPopular: false,
                          color: AdminTheme.errorColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingS),
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipPlanCard({
    required String title,
    required String price,
    required String originalPrice,
    required String discount,
    required List<String> features,
    required bool isPopular,
    required Color color,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isPopular ? Border.all(color: color, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AdminTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'BEST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AdminTheme.spacingM),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AdminTheme.spacingS),
                  Text(
                    originalPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: AdminTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$discount 할인',
                  style: const TextStyle(
                    color: AdminTheme.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AdminTheme.successColor,
                        ),
                        const SizedBox(width: AdminTheme.spacingS),
                        Text(
                          feature,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _editVipPlan(title),
                      child: const Text('수정'),
                    ),
                  ),
                  const SizedBox(width: AdminTheme.spacingS),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _toggleVipPlan(title),
                      style: ElevatedButton.styleFrom(backgroundColor: color),
                      child: const Text('설정'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addVipProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VIP 상품 추가 기능 구현 예정')),
    );
  }

  void _editVipPlan(String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$planName 수정 기능 구현 예정')),
    );
  }

  void _toggleVipPlan(String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$planName 설정 변경 기능 구현 예정')),
    );
  }
}