import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';

/// 일반 상품 관리 화면
class AdminGeneralProductsScreen extends ConsumerStatefulWidget {
  const AdminGeneralProductsScreen({super.key});

  @override
  ConsumerState<AdminGeneralProductsScreen> createState() => _AdminGeneralProductsScreenState();
}

class _AdminGeneralProductsScreenState extends ConsumerState<AdminGeneralProductsScreen> {
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
              '일반 상품 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addProduct(),
              icon: const Icon(Icons.add),
              label: const Text('상품 추가'),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '전체 상품',
                value: '24',
                color: AdminTheme.primaryColor,
                icon: Icons.inventory,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '활성 상품',
                value: '18',
                color: AdminTheme.successColor,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '비활성 상품',
                value: '6',
                color: AdminTheme.warningColor,
                icon: Icons.pause_circle,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '이번 달 판매',
                value: '145',
                color: AdminTheme.infoColor,
                icon: Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Content Area
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '상품 목록',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: '상품명 검색...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) => _onSearchChanged(value),
                            ),
                          ),
                          const SizedBox(width: AdminTheme.spacingM),
                          DropdownButton<String>(
                            value: '전체',
                            items: const [
                              DropdownMenuItem(value: '전체', child: Text('전체')),
                              DropdownMenuItem(value: '활성', child: Text('활성')),
                              DropdownMenuItem(value: '비활성', child: Text('비활성')),
                            ],
                            onChanged: (value) => _onStatusFilterChanged(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: _buildProductTable(),
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
                    fontSize: 24,
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

  Widget _buildProductTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('상품명')),
          DataColumn(label: Text('카테고리')),
          DataColumn(label: Text('가격')),
          DataColumn(label: Text('재고')),
          DataColumn(label: Text('상태')),
          DataColumn(label: Text('등록일')),
          DataColumn(label: Text('관리')),
        ],
        rows: [
          _buildProductRow('슈퍼챗 10개', '포인트', '9,900원', '무제한', '활성', '2024-01-15'),
          _buildProductRow('슈퍼챗 50개', '포인트', '45,000원', '무제한', '활성', '2024-01-15'),
          _buildProductRow('프로필 부스트', '기능', '5,000원', '무제한', '활성', '2024-01-20'),
          _buildProductRow('추천 알림 OFF', '기능', '3,000원', '무제한', '비활성', '2024-01-25'),
        ],
      ),
    );
  }

  DataRow _buildProductRow(
    String name,
    String category,
    String price,
    String stock,
    String status,
    String date,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(category)),
        DataCell(Text(price)),
        DataCell(Text(stock)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == '활성' 
                ? AdminTheme.successColor.withValues(alpha: 0.1)
                : AdminTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: status == '활성'
                  ? AdminTheme.successColor
                  : AdminTheme.warningColor,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == '활성'
                  ? AdminTheme.successColor
                  : AdminTheme.warningColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(date)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editProduct(name),
                tooltip: '수정',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _deleteProduct(name),
                tooltip: '삭제',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('상품 추가 기능 구현 예정')),
    );
  }

  void _editProduct(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$productName 수정 기능 구현 예정')),
    );
  }

  void _deleteProduct(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$productName 삭제 기능 구현 예정')),
    );
  }

  void _onSearchChanged(String value) {
    // TODO: Implement search functionality
  }

  void _onStatusFilterChanged(String? value) {
    // TODO: Implement status filter functionality
  }
}