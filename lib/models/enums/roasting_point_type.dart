enum RoastingPointType {
  light,
  medium,
  mediumDark,
  dark,
  etc;

  // DB에 저장할 때 사용 (대문자)
  String toDbValue() {
    switch (this) {
      case RoastingPointType.light:
        return 'LIGHT';
      case RoastingPointType.medium:
        return 'MEDIUM';
      case RoastingPointType.mediumDark:
        return 'MEDIUM_DARK';
      case RoastingPointType.dark:
        return 'DARK';
      case RoastingPointType.etc:
        return 'ETC';
    }
  }

  // DB에서 읽을 때 사용
  static RoastingPointType fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'LIGHT':
        return RoastingPointType.light;
      case 'MEDIUM':
        return RoastingPointType.medium;
      case 'MEDIUM_DARK':
        return RoastingPointType.mediumDark;
      case 'DARK':
        return RoastingPointType.dark;
      case 'ETC':
        return RoastingPointType.etc;
      default:
        return RoastingPointType.etc;
    }
  }

  // UI 표시용
  String get displayName {
    switch (this) {
      case RoastingPointType.light:
        return '라이트';
      case RoastingPointType.medium:
        return '미디엄';
      case RoastingPointType.mediumDark:
        return '미디엄 다크';
      case RoastingPointType.dark:
        return '다크';
      case RoastingPointType.etc:
        return '직접입력';
    }
  }
}
