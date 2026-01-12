import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Coffee Note 앱의 재사용 가능한 컴포넌트 스타일
/// 디자인 가이드 문서를 기반으로 정의된 컴포넌트 스타일들
class AppComponentStyles {
  AppComponentStyles._(); // 인스턴스화 방지

  /// Primary Button 스타일 (기록하기 버튼)
  /// 배경: #2B1E1A, 텍스트: #FFFFFF, Border Radius: 20px
  static ButtonStyle primaryButton = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(AppColors.primaryDark),
    foregroundColor: MaterialStateProperty.all(AppColors.whiteText),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
      ),
    ),
    textStyle: MaterialStateProperty.all(AppTextStyles.bodyTextWhite),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  );

  /// Text Input Field 스타일
  /// 배경: #FFFFFF, 테두리: rgba(90, 58, 46, 0.3), Border Radius: 10px
  static InputDecoration textInputDecoration({
    String? hintText,
    String? labelText,
  }) {
    return InputDecoration(
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
      hintText: hintText,
      labelText: labelText,
      hintStyle: AppTextStyles.bodyText.copyWith(
        color: AppColors.primaryText.withOpacity(0.5),
      ),
      labelStyle: AppTextStyles.bodyText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Card/Note Component 스타일
  /// 배경: #FFFFFF, 테두리: rgba(90, 58, 46, 0.3), Border Radius: 10px
  static BoxDecoration noteCardDecoration = BoxDecoration(
    color: AppColors.background,
    border: Border.all(
      color: AppColors.border,
      width: AppSpacing.borderWidth,
    ),
    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
  );

  /// Hashtag 스타일
  /// 배경: #2B1E1A, 텍스트: #FFFFFF, Border Radius: 20px
  static BoxDecoration hashtagDecoration = BoxDecoration(
    color: AppColors.primaryDark,
    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
  );

  /// Hashtag 텍스트 스타일
  static TextStyle hashtagTextStyle = AppTextStyles.bodyTextWhite;

  /// Filter 영역 스타일
  /// 배경: #FFFFFF, 테두리: rgba(90, 58, 46, 0.3), Border Radius: 10px
  static BoxDecoration filterAreaDecoration = BoxDecoration(
    color: AppColors.background,
    border: Border.all(
      color: AppColors.border,
      width: AppSpacing.borderWidth,
    ),
    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
  );
}
