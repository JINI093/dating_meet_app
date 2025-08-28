import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../providers/general_products_provider.dart';
import '../../../models/GeneralProduct.dart';
import '../../widgets/product_edit_dialog.dart';
import '../../scripts/create_initial_products.dart';

/// 일반 상품 관리 화면
class AdminGeneralProductsScreen extends ConsumerStatefulWidget {
  const AdminGeneralProductsScreen({super.key});

  @override
  ConsumerState<AdminGeneralProductsScreen> createState() => _AdminGeneralProductsScreenState();
}

class _AdminGeneralProductsScreenState extends ConsumerState<AdminGeneralProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(generalProductsProvider);
    
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 초기 데이터 생성 버튼 (상품이 없을 때만 표시)
          if (productsState.products.isEmpty && !productsState.isLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await CreateInitialProducts.createDefaultProducts();
                  ref.read(generalProductsProvider.notifier).loadProducts();
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('기본 상품 4개 생성하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
          // Error Message
          if (productsState.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                productsState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            
          // Loading Indicator
          if (productsState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: productsState.products.length + 1,
                itemBuilder: (context, index) {
                  if (index == productsState.products.length) {
                    return _buildAddProductCard();
                  }
                  return _buildProductCard(productsState.products[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(GeneralProduct product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getColorFromString(product.iconColor ?? '#FF6B9D').withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: _buildIcon(
                  product.iconType ?? 'heart',
                  _getColorFromString(product.iconColor ?? '#FF6B9D'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              product.title ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              product.subtitle ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Expanded(
              child: Text(
                product.description ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 7,
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => _editProduct(product),
                  tooltip: '수정',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => _deleteProduct(product),
                  tooltip: '삭제',
                ),
                const SizedBox(width: 8),
                _buildToggleSwitch(product),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String type, Color color) {
    switch (type) {
      case 'heart':
        return Icon(Icons.favorite, size: 40, color: color);
      case 'chat':
        return Icon(Icons.chat_bubble, size: 40, color: color);
      case 'profile':
        return _buildProfileIcon(color);
      case 'stack':
        return _buildStackIcon(color);
      default:
        return Icon(Icons.inventory_2, size: 40, color: color);
    }
  }

  Widget _buildProfileIcon(Color color) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          child: Container(
            width: 30,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 5,
          child: Container(
            width: 30,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStackIcon(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(-8, -8),
          child: Transform.rotate(
            angle: -0.1,
            child: Container(
              width: 35,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(8, 8),
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              width: 35,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSwitch(GeneralProduct product) {
    return Switch(
      value: product.isActive ?? true,
      onChanged: (value) {
        ref.read(generalProductsProvider.notifier).toggleProductStatus(product.id, value);
      },
      activeColor: AdminTheme.primaryColor,
    );
  }

  Widget _buildAddProductCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _addProduct,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '상품 추가하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProduct() {
    _showProductDialog();
  }

  void _editProduct(GeneralProduct product) {
    _showProductDialog(product: product);
  }

  void _deleteProduct(GeneralProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('${product.title} 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(generalProductsProvider.notifier).deleteProduct(product.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProductDialog({GeneralProduct? product}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductEditDialog(product: product),
    );
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return const Color(0xFFFF6B9D); // 기본 색상
    }
  }
}