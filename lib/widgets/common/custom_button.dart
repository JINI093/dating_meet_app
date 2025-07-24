import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

enum CustomButtonStyle {
  primary,
  secondary,
  outline,
  text,
  gradient,
  disabled,
}

enum CustomButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final CustomButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final List<Color>? gradientColors;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    
    return SizedBox(
      width: width ?? buttonConfig.width,
      height: height ?? buttonConfig.height,
      child: Container(
        decoration: BoxDecoration(
          gradient: buttonConfig.gradient,
          borderRadius: BorderRadius.circular(
            borderRadius ?? buttonConfig.borderRadius,
          ),
          boxShadow: buttonConfig.boxShadow,
        ),
        child: Material(
          color: buttonConfig.gradient != null 
              ? Colors.transparent 
              : buttonConfig.backgroundColor,
          borderRadius: BorderRadius.circular(
            borderRadius ?? buttonConfig.borderRadius,
          ),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(
              borderRadius ?? buttonConfig.borderRadius,
            ),
            child: Container(
              padding: padding ?? buttonConfig.padding,
              decoration: BoxDecoration(
                border: buttonConfig.border,
                borderRadius: BorderRadius.circular(
                  borderRadius ?? buttonConfig.borderRadius,
                ),
              ),
              child: _buildButtonContent(buttonConfig),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(_ButtonConfig config) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: config.loadingSize,
          height: config.loadingSize,
          child: CircularProgressIndicator(
            color: config.textColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: config.textColor,
            size: config.iconSize,
          ),
          SizedBox(width: config.iconSpacing),
          Text(
            text,
            style: config.textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Center(
      child: Text(
        text,
        style: config.textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (style) {
      case CustomButtonStyle.primary:
        return _ButtonConfig(
          backgroundColor: backgroundColor ?? AppColors.primary,
          textColor: textColor ?? AppColors.textWhite,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.textWhite,
          ),
          borderRadius: AppDimensions.radiusM,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
        );

      case CustomButtonStyle.secondary:
        return _ButtonConfig(
          backgroundColor: backgroundColor ?? AppColors.buttonSecondary,
          textColor: textColor ?? AppColors.textPrimary,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.textPrimary,
          ),
          borderRadius: AppDimensions.radiusM,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
        );

      case CustomButtonStyle.outline:
        return _ButtonConfig(
          backgroundColor: backgroundColor ?? Colors.transparent,
          textColor: textColor ?? AppColors.primary,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.primary,
          ),
          border: Border.all(
            color: borderColor ?? AppColors.primary,
            width: AppDimensions.borderNormal,
          ),
          borderRadius: AppDimensions.radiusM,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
        );

      case CustomButtonStyle.text:
        return _ButtonConfig(
          backgroundColor: backgroundColor ?? Colors.transparent,
          textColor: textColor ?? AppColors.primary,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.primary,
          ),
          borderRadius: AppDimensions.radiusS,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
        );

      case CustomButtonStyle.gradient:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppColors.textWhite,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.textWhite,
          ),
          gradient: LinearGradient(
            colors: gradientColors ?? AppColors.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppDimensions.radiusM,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
          boxShadow: [
            BoxShadow(
              color: (gradientColors ?? AppColors.primaryGradient)[0]
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CustomButtonStyle.disabled:
        return _ButtonConfig(
          backgroundColor: backgroundColor ?? AppColors.buttonDisabled,
          textColor: textColor ?? AppColors.textHint,
          textStyle: _getTextStyle().copyWith(
            color: textColor ?? AppColors.textHint,
          ),
          borderRadius: AppDimensions.radiusM,
          height: _getHeight(),
          width: width,
          padding: _getPadding(),
          iconSize: _getIconSize(),
          iconSpacing: AppDimensions.spacing8,
          loadingSize: _getLoadingSize(),
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case CustomButtonSize.small:
        return AppTextStyles.buttonSmall;
      case CustomButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case CustomButtonSize.large:
        return AppTextStyles.buttonLarge;
      case CustomButtonSize.extraLarge:
        return AppTextStyles.buttonLarge.copyWith(fontSize: 18);
    }
  }

  double _getHeight() {
    switch (size) {
      case CustomButtonSize.small:
        return AppDimensions.buttonHeightS;
      case CustomButtonSize.medium:
        return AppDimensions.buttonHeightM;
      case CustomButtonSize.large:
        return AppDimensions.buttonHeightL;
      case CustomButtonSize.extraLarge:
        return AppDimensions.buttonHeightXL;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        );
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        );
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing20,
          vertical: AppDimensions.spacing16,
        );
      case CustomButtonSize.extraLarge:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing24,
          vertical: AppDimensions.spacing20,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return AppDimensions.iconS;
      case CustomButtonSize.medium:
        return AppDimensions.iconM;
      case CustomButtonSize.large:
        return AppDimensions.iconM;
      case CustomButtonSize.extraLarge:
        return AppDimensions.iconL;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 16.0;
      case CustomButtonSize.medium:
        return 20.0;
      case CustomButtonSize.large:
        return 24.0;
      case CustomButtonSize.extraLarge:
        return 28.0;
    }
  }
}

class _ButtonConfig {
  final Color? backgroundColor;
  final Color textColor;
  final TextStyle textStyle;
  final Border? border;
  final Gradient? gradient;
  final double borderRadius;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double iconSpacing;
  final double loadingSize;
  final List<BoxShadow>? boxShadow;

  const _ButtonConfig({
    this.backgroundColor,
    required this.textColor,
    required this.textStyle,
    this.border,
    this.gradient,
    required this.borderRadius,
    required this.height,
    this.width,
    required this.padding,
    required this.iconSize,
    required this.iconSpacing,
    required this.loadingSize,
    this.boxShadow,
  });
}