import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

/// アプリケーション全体のテーマを定義
/// 
/// リスをイメージした温かみのある茶色・ベージュ・オレンジ系のデザイン
class AppTheme {
  AppTheme._();

  /// ライトモードのテーマ
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        
        // カラースキーム
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: AppColors.primaryDark,
          
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentLight,
          onSecondaryContainer: AppColors.accentDark,
          
          tertiary: AppColors.secondary,
          onTertiary: AppColors.textPrimary,
          
          error: AppColors.error,
          errorContainer: AppColors.errorLight,
          onErrorContainer: AppColors.errorDark,
          
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onSurfaceVariant: AppColors.textSecondary,
          
          outline: AppColors.border,
          outlineVariant: AppColors.borderLight,
          
          shadow: AppColors.shadow,
          
          scrim: AppColors.overlay,
        ),
        
        // 背景色
        scaffoldBackgroundColor: AppColors.background,
        
        // AppBar テーマ
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.shadow,
          surfaceTintColor: Colors.transparent,
        ),
        
        // Card テーマ
        cardTheme: CardThemeData(
          elevation: AppConstants.cardElevation,
          shadowColor: AppColors.shadow,
          surfaceTintColor: Colors.transparent,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            side: const BorderSide(
              color: AppColors.borderLight,
            ),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultSpacing,
          ),
        ),
        
        // InputDecoration テーマ
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultSpacing * 1.5,
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textTertiary),
        ),
        
        // ElevatedButton テーマ
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.shadow,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding * 1.5,
              vertical: AppConstants.defaultSpacing * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
        ),
        
        // TextButton テーマ
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultSpacing,
            ),
          ),
        ),
        
        // IconButton テーマ
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.all(AppConstants.defaultSpacing * 1.5),
          ),
        ),
        
        // FloatingActionButton テーマ
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        
        // SnackBar テーマ
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultSpacing),
          ),
        ),
        
        // Divider テーマ
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          space: 1,
          thickness: 1,
        ),
        
        // Dialog テーマ
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shadowColor: AppColors.shadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius * 1.5),
          ),
        ),
        
        // BottomSheet テーマ
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shadowColor: AppColors.shadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
        ),
        
        // テキストテーマ
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textPrimary,
          ),
          bodySmall: TextStyle(
            color: AppColors.textSecondary,
          ),
          labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: AppColors.textSecondary,
          ),
          labelSmall: TextStyle(
            color: AppColors.textTertiary,
          ),
        ),
      );

  /// ダークモードのテーマ（将来的な拡張用）
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.accentLight,
          error: AppColors.errorLight,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultSpacing,
          ),
        ),
      );
}
