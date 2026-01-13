enum ProcessType {
  washed,
  natural,
  pulpedNatural,
  honey,
  etc;

  // DB에 저장할 때 사용 (대문자)
  String toDbValue() {
    switch (this) {
      case ProcessType.washed:
        return 'WASHED';
      case ProcessType.natural:
        return 'NATURAL';
      case ProcessType.pulpedNatural:
        return 'PULPED_NATURAL';
      case ProcessType.honey:
        return 'HONEY';
      case ProcessType.etc:
        return 'ETC';
    }
  }

  // DB에서 읽을 때 사용
  static ProcessType fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'WASHED':
        return ProcessType.washed;
      case 'NATURAL':
        return ProcessType.natural;
      case 'PULPED_NATURAL':
        return ProcessType.pulpedNatural;
      case 'HONEY':
        return ProcessType.honey;
      case 'ETC':
        return ProcessType.etc;
      default:
        return ProcessType.etc;
    }
  }

  // UI 표시용
  String get displayName {
    switch (this) {
      case ProcessType.washed:
        return '워시드';
      case ProcessType.natural:
        return '내추럴';
      case ProcessType.pulpedNatural:
        return '펄프드 내추럴';
      case ProcessType.honey:
        return '허니';
      case ProcessType.etc:
        return '직접입력';
    }
  }
}
