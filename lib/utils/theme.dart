import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textWhite,
        tertiary: AppColors.vip,
        onTertiary: AppColors.textWhite,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textWhite,
        outline: AppColors.divider,
        shadow: AppColors.cardShadow,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: AppTextStyles.tabLabelActive,
        unselectedLabelStyle: AppTextStyles.tabLabel,
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        shadowColor: AppColors.cardShadow,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.cardRadius),
          ),
        ),
        margin: EdgeInsets.all(AppDimensions.spacing8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightM,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderNormal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightM,
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppDimensions.textFieldPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
            width: AppDimensions.borderNormal,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
            width: AppDimensions.borderNormal,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderNormal,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThick,
          ),
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.errorText,
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.dialogRadius),
          ),
        ),
        titleTextStyle: AppTextStyles.h5,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetRadius),
          ),
        ),
        modalBackgroundColor: AppColors.surface,
        modalBarrierColor: AppColors.overlay,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.tabLabelActive,
        unselectedLabelStyle: AppTextStyles.tabLabel,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.tabIndicatorWeight,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 4.0,
        shape: CircleBorder(),
      ),

      // Chip Theme
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.buttonDisabled,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.filterChipPadding,
          vertical: AppDimensions.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.filterChipRadius),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.listItemPadding,
          vertical: AppDimensions.spacing8,
        ),
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodyMedium,
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textHint;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return AppColors.textHint.withValues(alpha: 0.3);
        }),
      ),

      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.divider,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary,
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

      // Snack Bar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusS),
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.textPrimary,
        tertiary: AppColors.vip,
        onTertiary: AppColors.textPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: AppColors.textWhite,
        outline: AppColors.dividerDark,
        shadow: AppColors.cardShadow,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: AppTextStyles.tabLabelActive,
        unselectedLabelStyle: AppTextStyles.tabLabel,
      ),

      // Rest of the dark theme properties follow similar pattern...
      // (For brevity, including just the essential ones)
    );
  }

  // Cupertino Theme (iOS Style)
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: AppColors.primary,
      primaryContrastingColor: AppColors.textWhite,
      barBackgroundColor: AppColors.surface,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.textPrimary,
        textStyle: AppTextStyles.bodyMedium,
        actionTextStyle: AppTextStyles.buttonMedium,
        tabLabelTextStyle: AppTextStyles.tabLabel,
        navTitleTextStyle: AppTextStyles.appBarTitle,
        navLargeTitleTextStyle: AppTextStyles.h3,
        navActionTextStyle: AppTextStyles.buttonMedium,
        pickerTextStyle: AppTextStyles.bodyMedium,
        dateTimePickerTextStyle: AppTextStyles.bodyMedium,
      ),
    );
  }
}