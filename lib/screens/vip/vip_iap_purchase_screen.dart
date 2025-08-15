import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/vip_provider.dart';
import '../../models/purchase_models.dart';
import '../../widgets/dialogs/loading_dialog.dart';

/// 인앱결제를 통한 VIP 구매 화면
class VipIAPPurchaseScreen extends ConsumerStatefulWidget {
  const VipIAPPurchaseScreen({super.key});

  @override
  ConsumerState<VipIAPPurchaseScreen> createState() => _VipIAPPurchaseScreenState();
}

class _VipIAPPurchaseScreenState extends ConsumerState<VipIAPPurchaseScreen> {
  @override
  void initState() {
    super.initState();
    // 제품 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);
    final vipState = ref.watch(vipProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'VIP 멤버십',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: Text(
              '복원',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: purchaseState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchaseState.error != null
              ? _buildErrorView(purchaseState.error!)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final vipProducts = ref.watch(vipProductsProvider);
    
    if (vipProducts.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIP 혜택 안내
          _buildBenefitsSection(),
          const SizedBox(height: AppDimensions.spacing32),
          
          // VIP 플랜 목록
          Text(
            'VIP 플랜',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          
          ...vipProducts.map((product) => _buildVipProductCard(product)),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          // 주의사항
          _buildNoticeSection(),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'VIP 멤버십 혜택',
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('무제한 좋아요', '❤️'),
          _buildBenefitItem('프로필 부스트', '🚀'),
          _buildBenefitItem('고급 필터 사용', '🔍'),
          _buildBenefitItem('슈퍼챗 혜택', '💬'),
          _buildBenefitItem('우선 고객지원', '🛟'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipProductCard(VipProduct product) {
    final isPopular = product.durationDays == 30; // 1개월 플랜을 인기 플랜으로 설정
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isPopular ? AppColors.primary : AppColors.cardBorder,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 인기 배지
          if (isPopular)
            Positioned(
              top: -1,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '인기',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 플랜 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIP ${product.vipTier}',
                          style: AppTextStyles.h5.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getTierColor(product.vipTier),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.durationDays}일 이용권',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.price,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.durationDays > 30)
                          Text(
                            '월 ${_calculateMonthlyPrice(product)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 혜택 목록
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.features.map((feature) => _buildFeatureChip(feature)).toList(),
                ),
                
                const SizedBox(height: 20),
                
                // 구매 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchaseVip(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppColors.primary : AppColors.cardBorder,
                      foregroundColor: isPopular ? Colors.white : AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      elevation: isPopular ? 4 : 0,
                    ),
                    child: Text(
                      '구매하기',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        feature,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoticeSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주의사항',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 구매한 VIP 멤버십은 즉시 활성화됩니다.\n'
            '• 구매 취소는 App Store/Google Play 정책에 따릅니다.\n'
            '• 자동 갱신은 설정에서 관리할 수 있습니다.\n'
            '• 계정 삭제 시 남은 기간은 복구되지 않습니다.',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(purchaseProvider.notifier).clearError();
                ref.read(purchaseProvider.notifier).loadProducts();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '구매 가능한 상품이 없습니다',
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시 후 다시 시도해주세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(purchaseProvider.notifier).loadProducts(),
              child: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'GOLD':
        return const Color(0xFFFFD700);
      case 'PREMIUM':
        return const Color(0xFFC0C0C0);
      case 'BASIC':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  String _calculateMonthlyPrice(VipProduct product) {
    if (product.metadata?['rawPrice'] != null) {
      final rawPrice = product.metadata!['rawPrice'] as double;
      final monthlyPrice = rawPrice / (product.durationDays / 30);
      return '${monthlyPrice.toStringAsFixed(0)}원';
    }
    return '-';
  }

  /// VIP 구매 처리
  Future<void> _purchaseVip(VipProduct product) async {
    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(message: '구매 처리 중...'),
      );

      // 인앱결제 시작
      final success = await ref.read(purchaseProvider.notifier).purchaseProduct(product.id);
      
      if (!success) {
        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.of(context).pop();
        
        // 오류 메시지 표시
        _showErrorDialog('구매 요청에 실패했습니다.');
        return;
      }

      // 구매 결과는 PurchaseProvider의 콜백에서 처리됨
      // 로딩 다이얼로그는 구매 완료 시 자동으로 닫힘
      
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();
      
      _showErrorDialog('구매 중 오류가 발생했습니다: $e');
    }
  }

  /// 구매 복원
  Future<void> _restorePurchases() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(message: '구매 복원 중...'),
      );

      await ref.read(purchaseProvider.notifier).restorePurchases();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구매 복원이 완료되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('구매 복원에 실패했습니다: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}