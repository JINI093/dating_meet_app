import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../providers/vip_products_provider.dart';
import '../../../models/VipProduct.dart';
import '../../widgets/vip_product_edit_dialog.dart';

/// VIP 상품 관리 화면
class AdminVipProductsScreen extends ConsumerStatefulWidget {
  const AdminVipProductsScreen({super.key});

  @override
  ConsumerState<AdminVipProductsScreen> createState() => _AdminVipProductsScreenState();
}

class _AdminVipProductsScreenState extends ConsumerState<AdminVipProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(vipProductsProvider);
    
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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

  Widget _buildProductCard(VipProduct product) {
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
                color: _getColorFromString(product.iconColor ?? '#FFD700').withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: _buildVipIcon(
                  product.tier ?? 'BRONZE',
                  _getColorFromString(product.iconColor ?? '#FFD700'),
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
            
            // Features
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.features != null && product.features!.isNotEmpty) ...[
                      ...product.features!.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: _getColorFromString(product.iconColor ?? '#FFD700'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ] else ...[
                      Text(
                        product.description ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                      ),
                    ],
                  ],
                ),
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

  Widget _buildVipIcon(String tier, Color color) {
    switch (tier) {
      case 'GOLD':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 40, color: color),
            Icon(Icons.star, size: 20, color: Colors.white),
          ],
        );
      case 'SILVER':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 40, color: color),
            Icon(Icons.star_half, size: 20, color: Colors.white),
          ],
        );
      case 'BRONZE':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 40, color: color),
            Icon(Icons.star_border, size: 20, color: Colors.white),
          ],
        );
      default:
        return Icon(Icons.diamond, size: 40, color: color);
    }
  }

  Widget _buildToggleSwitch(VipProduct product) {
    return Switch(
      value: product.isActive ?? true,
      onChanged: (value) {
        ref.read(vipProductsProvider.notifier).toggleProductStatus(product.id, value);
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
                'VIP 상품 추가하기',
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

  void _editProduct(VipProduct product) {
    _showProductDialog(product: product);
  }

  void _deleteProduct(VipProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VIP 상품 삭제'),
        content: Text('${product.title} 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(vipProductsProvider.notifier).deleteProduct(product.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProductDialog({VipProduct? product}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VipProductEditDialog(product: product),
    );
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return const Color(0xFFFFD700); // 기본 골드 색상
    }
  }
}