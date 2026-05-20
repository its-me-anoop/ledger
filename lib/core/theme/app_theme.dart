import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkScheme : _lightScheme;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final raised = isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaised;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.xl(color: textPrimary),
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.base(weight: FontWeight.w500),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.base(weight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textMuted,
          textStyle: AppTypography.sm(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceRecessedDark : AppColors.surfaceRecessed,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: isDark ? AppColors.dangerDark : AppColors.danger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: isDark ? AppColors.dangerDark : AppColors.danger,
            width: 1.5,
          ),
        ),
        labelStyle: AppTypography.sm(color: textMuted),
        floatingLabelStyle: AppTypography.sm(color: primary),
        helperStyle: AppTypography.sm(color: textMuted),
        errorStyle: AppTypography.sm(
          color: isDark ? AppColors.dangerDark : AppColors.danger,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s4,
        ),
        constraints: const BoxConstraints(minHeight: 52),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      cardTheme: CardThemeData(
        color: raised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTypography.base(weight: FontWeight.w500),
        unselectedLabelStyle: AppTypography.base(),
        labelColor: primary,
        unselectedLabelColor: textMuted,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        labelStyle: AppTypography.sm(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.textPrimary,
        contentTextStyle: AppTypography.sm(
          color: isDark ? AppColors.textPrimaryDark : AppColors.surfaceRaised,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryDim,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.success,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.successDim,
    onSecondaryContainer: AppColors.success,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: AppColors.dangerDim,
    onErrorContainer: AppColors.danger,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceRecessed,
    onSurfaceVariant: AppColors.textMuted,
    outline: AppColors.border,
    shadow: AppColors.textPrimary,
    scrim: AppColors.overlay,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.surfaceDark,
    primaryContainer: AppColors.primaryDimDark,
    onPrimaryContainer: AppColors.textPrimaryDark,
    secondary: AppColors.successDark,
    onSecondary: AppColors.surfaceDark,
    secondaryContainer: AppColors.successDimDark,
    onSecondaryContainer: AppColors.successDark,
    error: AppColors.dangerDark,
    onError: AppColors.surfaceDark,
    errorContainer: AppColors.dangerDimDark,
    onErrorContainer: AppColors.dangerDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceRecessedDark,
    onSurfaceVariant: AppColors.textMutedDark,
    outline: AppColors.borderDark,
    shadow: AppColors.textPrimaryDark,
    scrim: AppColors.overlay,
  );
}
