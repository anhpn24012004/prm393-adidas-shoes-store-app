export 'app_colors.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_text_styles.dart';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.black,
      brightness: Brightness.light,
      primary: AppColors.black,
      secondary: AppColors.ink,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Arial',
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.pageTitle,
        headlineMedium: AppTextStyles.sectionTitle,
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: AppColors.ink),
        bodyMedium: AppTextStyles.body,
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.line),
          borderRadius: AppRadius.mdBorder,
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: TextStyle(color: AppColors.muted),
        hintStyle: TextStyle(color: AppColors.subtle),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
          borderRadius: AppRadius.mdBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
          borderRadius: AppRadius.mdBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black, width: 1.4),
          borderRadius: AppRadius.mdBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger),
          borderRadius: AppRadius.mdBorder,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 1.4),
          borderRadius: AppRadius.mdBorder,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.line,
          disabledForegroundColor: AppColors.subtle,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.black, width: 1.2),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.black,
        disabledColor: AppColors.surfaceAlt,
        checkmarkColor: Colors.white,
        side: BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        labelStyle: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      iconTheme: const IconThemeData(color: AppColors.black, size: 22),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.black,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.muted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.black,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      extensions: <ThemeExtension<dynamic>>[
        _AppShadowTheme(cardShadow: AppShadows.card),
      ],
    );
  }
}

class _AppShadowTheme extends ThemeExtension<_AppShadowTheme> {
  final List<BoxShadow> cardShadow;

  const _AppShadowTheme({required this.cardShadow});

  @override
  ThemeExtension<_AppShadowTheme> copyWith({List<BoxShadow>? cardShadow}) {
    return _AppShadowTheme(cardShadow: cardShadow ?? this.cardShadow);
  }

  @override
  ThemeExtension<_AppShadowTheme> lerp(
    covariant ThemeExtension<_AppShadowTheme>? other,
    double t,
  ) {
    if (other is! _AppShadowTheme) return this;
    return _AppShadowTheme(cardShadow: t < 0.5 ? cardShadow : other.cardShadow);
  }
}
