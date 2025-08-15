import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/points_provider.dart';
import '../../models/purchase_models.dart';
import '../../widgets/dialogs/loading_dialog.dart';

/// 포인트 인앱결제 구매 화면
class PointsPurchaseScreen extends ConsumerStatefulWidget {
  const PointsPurchaseScreen({super.key});

  @override
  ConsumerState<PointsPurchaseScreen> createState() => _PointsPurchaseScreenState();
}

class _PointsPurchaseScreenState extends ConsumerState<PointsPurchaseScreen> {
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
    final pointsState = ref.watch(pointsProvider);

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
          '포인트 구매',
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
      body: Column(
        children: [
          // 현재 포인트 표시
          _buildCurrentPointsHeader(pointsState),
          
          Expanded(
            child: purchaseState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : purchaseState.error != null
                    ? _buildErrorView(purchaseState.error!)
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPointsHeader(PointsState pointsState) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보유 포인트',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pointsState.currentPoints.toStringAsFixed(0)}P',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final pointsProducts = ref.watch(pointsProductsProvider);
    
    if (pointsProducts.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포인트 사용처 안내
          _buildUsageInfoSection(),
          const SizedBox(height: AppDimensions.spacing24),
          
          // 포인트 패키지 목록
          Text(
            '포인트 패키지',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: pointsProducts.length,
            itemBuilder: (context, index) {
              return _buildPointsProductCard(pointsProducts[index]);
            },
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          // 주의사항
          _buildNoticeSection(),
        ],
      ),
    );
  }

  Widget _buildUsageInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '포인트 사용처',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildUsageItem('VIP 멤버십 구매', '990P~'),
          _buildUsageItem('프로필 해제', '20P'),
          _buildUsageItem('슈퍼챗 보내기', '50P'),
          _buildUsageItem('부스트 사용', '100P'),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String title, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            points,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsProductCard(PointsProduct product) {
    final hasBonus = product.bonusPoints > 0;
    final bonusPercentage = hasBonus 
        ? ((product.bonusPoints / product.pointsAmount) * 100).round()
        : 0;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: hasBonus ? AppColors.primary : AppColors.cardBorder,
          width: hasBonus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasBonus 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 보너스 배지
          if (hasBonus)
            Positioned(
              top: -1,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '+$bonusPercentage%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 포인트 아이콘
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 포인트 수량
                Text(
                  '${product.pointsAmount}P',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                // 보너스 포인트
                if (hasBonus) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${product.bonusPoints}P 보너스',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '총 ${product.totalPoints}P',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // 가격
                Text(
                  product.price,
                  style: AppTextStyles.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 구매 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchasePoints(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasBonus ? AppColors.primary : AppColors.cardBorder,
                      foregroundColor: hasBonus ? Colors.white : AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      elevation: hasBonus ? 2 : 0,
                    ),
                    child: Text(
                      '구매',
                      style: AppTextStyles.bodyMedium.copyWith(
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
            '• 구매한 포인트는 즉시 계정에 추가됩니다.\n'
            '• 포인트는 환불되지 않습니다.\n'
            '• 계정 삭제 시 보유 포인트는 소멸됩니다.\n'
            '• 포인트 유효기간은 구매일로부터 1년입니다.',
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
              '구매 가능한 포인트 패키지가 없습니다',
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

  /// 포인트 구매 처리
  Future<void> _purchasePoints(PointsProduct product) async {
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

      // 구매 성공 시 자동으로 포인트가 추가됨 (PurchaseProvider에서 처리)
      
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