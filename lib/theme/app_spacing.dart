/// Coffee Note 앱의 간격 및 레이아웃 상수
/// 디자인 가이드 문서를 기반으로 정의된 간격 값들
class AppSpacing {
  AppSpacing._(); // 인스턴스화 방지

  /// Border Radius - Large: 20px
  /// 버튼, 카드, 해시태그 배경에 사용
  static const double borderRadiusLarge = 20.0;

  /// Border Radius - Small: 10px
  /// 입력 필드, 작은 컨테이너에 사용
  static const double borderRadiusSmall = 10.0;

  /// 디자인 기준 화면 너비: 1080px
  /// 모바일 세로 방향 기준
  static const double designWidth = 1080.0;

  /// 디자인 기준 화면 높이: 2400px
  /// 모바일 세로 방향 기준
  static const double designHeight = 2400.0;

  /// 좌우 여백: 49px
  /// 컨텐츠 시작 위치
  static const double horizontalPadding = 49.0;

  /// 컴포넌트 너비: 972px
  /// 1080px - (49px × 2)
  static const double componentWidth = 972.0;

  /// Border 두께: 2px
  static const double borderWidth = 2.0;
}
