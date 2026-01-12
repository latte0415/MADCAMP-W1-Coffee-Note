import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_component_styles.dart';

/// Coffee Note 앱의 테마 설정
/// 디자인 가이드 문서를 기반으로 정의된 Flutter ThemeData
class AppTheme {
  AppTheme._(); // 인스턴스화 방지

  /// 앱의 기본 테마
  static ThemeData get lightTheme {
    return ThemeData(
      // 폰트 패밀리 설정
      fontFamily: AppTextStyles.fontFamily,
      
      // 색상 스키마
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryDark,
        background: AppColors.background,
        surface: AppColors.background,
        onPrimary: AppColors.whiteText,
        onBackground: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.largeTitle,
        bodyLarge: AppTextStyles.bodyText,
        bodyMedium: AppTextStyles.bodyText,
        bodySmall: AppTextStyles.bodyText,
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodyText.copyWith(
          color: AppColors.primaryText.withOpacity(0.5),
        ),
        labelStyle: AppTextStyles.bodyText,
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppComponentStyles.primaryButton,
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          side: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
        elevation: 0,
      ),

      // AppBar 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.bodyText,
      ),

      // FloatingActionButton 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.whiteText,
      ),

      // BottomNavigationBar 테마
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.background,
      ),

      // Scaffold 배경색
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
