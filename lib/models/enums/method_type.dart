enum MethodType {
  espresso,
  filter,
  coldBrew,
  etc;

  // DB에 저장할 때 사용 (대문자)
  String toDbValue() {
    switch (this) {
      case MethodType.espresso:
        return 'ESPRESSO';
      case MethodType.filter:
        return 'FILTER';
      case MethodType.coldBrew:
        return 'COLD_BREW';
      case MethodType.etc:
        return 'ETC';
    }
  }

  // DB에서 읽을 때 사용
  static MethodType fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'ESPRESSO':
        return MethodType.espresso;
      case 'FILTER':
        return MethodType.filter;
      case 'COLD_BREW':
        return MethodType.coldBrew;
      case 'ETC':
        return MethodType.etc;
      default:
        return MethodType.etc;
    }
  }

  // UI 표시용
  String get displayName {
    switch (this) {
      case MethodType.espresso:
        return '에스프레소';
      case MethodType.filter:
        return '필터';
      case MethodType.coldBrew:
        return '콜드브루';
      case MethodType.etc:
        return '기타';
    }
  }
}
