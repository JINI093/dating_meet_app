import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../providers/recommend_card_provider.dart';

/// 오늘의 매칭 종료 다이얼로그
class DailyMatchEndDialog extends ConsumerWidget {
  const DailyMatchEndDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRecommendCards = ref.watch(currentRecommendCardsProvider);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 경고 아이콘
            Image.asset(
              'assets/icons/caution.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                // 이미지 로드 실패 시 대체 아이콘
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    size: 40,
                    color: Colors.orange,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // 제목
            Text(
              '오늘의 추천 카드는\n여기까지에요',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // 설명
            Text(
              '더 많은 상대를 보고싶으시면\n추천카드 더 보기를 사용할 수 있습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // 버튼들
            Column(
              children: [
                // 이용권 사용하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: 보유한 이용권이 있으면 사용하기, 없으면 구매 화면으로
                      _handleUseTicket(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '이용권 사용하기 : ${currentRecommendCards}회 남음',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 이용권 구매 이동하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToTicketShop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '이용권 구매 이동하기',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 이용권 사용하기 처리
  void _handleUseTicket(BuildContext context) {
    // TODO: 보유한 추천카드 더보기 이용권이 있는지 확인하고
    // 있으면 사용, 없으면 구매 화면으로 이동
    _navigateToTicketShop(context);
  }

  /// 이용권 구매 상점으로 이동
  void _navigateToTicketShop(BuildContext context) {
    // 추천카드 더보기 탭으로 이동 (인덱스 3)
    context.push('/ticket-shop', extra: 3);
  }
}

/// 매칭 종료 다이얼로그 표시 헬퍼 함수
Future<void> showDailyMatchEndDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (BuildContext context) {
      return const DailyMatchEndDialog();
    },
  );
}