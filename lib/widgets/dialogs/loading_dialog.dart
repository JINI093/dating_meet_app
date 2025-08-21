import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

/// 로딩 다이얼로그 위젯
class LoadingDialog extends StatelessWidget {
  final String message;
  final bool canCancel;

  const LoadingDialog({
    super.key,
    this.message = '처리 중...',
    this.canCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canCancel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 로딩 인디케이터
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // 메시지
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              // 취소 버튼 (옵션)
              if (canCancel) ...[
                const SizedBox(height: AppDimensions.spacing16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 로딩 다이얼로그 표시 헬퍼 함수
Future<T?> showLoadingDialog<T>(
  BuildContext context, {
  String message = '처리 중...',
  bool canCancel = false,
  Future<T> Function()? future,
}) {
  if (future != null) {
    // Future와 함께 사용하는 경우
    final completer = showDialog<T>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        message: message,
        canCancel: canCancel,
      ),
    );

    future().then((result) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
    }).catchError((error) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      throw error;
    });

    return completer;
  } else {
    // 단순 다이얼로그 표시
    return showDialog<T>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        message: message,
        canCancel: canCancel,
      ),
    );
  }
}