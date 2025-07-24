import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      title: Text(
        title,
        style: AppTextStyles.h6.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textWhite.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          child: Text(
            confirmText ?? '확인',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
