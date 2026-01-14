import 'package:flutter/material.dart';

/// Coffee Note 앱의 색상 팔레트
/// 디자인 가이드 문서를 기반으로 정의된 색상 상수들
class AppColors {
  AppColors._(); // 인스턴스화 방지

  /// Primary Dark: #2B1E1A
  /// 주요 텍스트, 버튼 배경, 강조 요소에 사용
  static const Color primaryDark = Color(0xFF2B1E1A);

  /// Background: #FFFFFF
  /// 화면 배경, 카드 배경에 사용
  static const Color background = Color(0xFFFFFFFF);

  /// Border: rgba(90, 58, 46, 0.3)
  /// 입력 필드 테두리, 구분선에 사용
  static const Color border = Color.fromRGBO(90, 58, 46, 0.3);

  /// Primary Text: #2B1E1A (Primary Dark와 동일)
  /// 일반 텍스트에 사용
  static const Color primaryText = Color(0xFF2B1E1A);

  /// White Text: #FFFFFF
  /// 다크 배경 위 텍스트에 사용
  static const Color whiteText = Color(0xFFFFFFFF);

  /// Disabled Button: #9E9E9E
  /// 비활성화된 버튼 배경에 사용
  static const Color disabledButton = Color(0xFF9E9E9E);

  /// Error: #DC3545
  /// 에러 메시지, 경고 텍스트에 사용
  static const Color error = Color(0xFFDC3545);
}
