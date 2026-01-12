import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Coffee Note 앱의 타이포그래피 스타일
/// 디자인 가이드 문서를 기반으로 정의된 텍스트 스타일들
class AppTextStyles {
  AppTextStyles._(); // 인스턴스화 방지

  /// 폰트 패밀리: NanumSquareOTF
  static const String fontFamily = 'NanumSquareOTF';

  /// Large Title 스타일
  /// 50px, Weight: 700 (Bold), Line Height: 57px
  /// 화면 제목, 중요한 정보 표시에 사용
  /// 예: 메뉴명, 카페명 (큰 제목)
  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 50,
    fontWeight: FontWeight.w700,
    height: 57 / 50, // Line Height: 57px
    color: AppColors.primaryText,
  );

  /// Body Text 스타일
  /// 30px, Weight: 400 (Regular), Line Height: 34px, Letter Spacing: 0.1em
  /// 본문 텍스트, 일반적인 정보에 사용
  /// 예: 설명 텍스트, 버튼 텍스트, 입력 필드 텍스트
  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 34 / 30, // Line Height: 34px
    letterSpacing: 0.1,
    color: AppColors.primaryText,
  );

  /// Body Text (White) 스타일
  /// 다크 배경 위에 사용하는 본문 텍스트
  static const TextStyle bodyTextWhite = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 34 / 30,
    letterSpacing: 0.1,
    color: AppColors.whiteText,
  );
}
