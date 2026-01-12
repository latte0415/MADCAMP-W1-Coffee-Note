/// Library 페이지의 필터 상태를 관리하는 모델
class LibraryFilterState {
  /// 상세 필터 UI 표시 여부
  final bool showDetailFilter;
  
  /// 산미 필터 값 (null이면 필터 미적용)
  final int? acidity;
  
  /// 바디 필터 값 (null이면 필터 미적용)
  final int? body;
  
  /// 쓴맛 필터 값 (null이면 필터 미적용)
  final int? bitterness;

  const LibraryFilterState({
    this.showDetailFilter = false,
    this.acidity,
    this.body,
    this.bitterness,
  });

  /// 필터가 활성화되어 있는지 확인
  /// showDetailFilter가 true이면 활성화로 간주한다.
  bool get hasActiveFilter => showDetailFilter;

  /// 필터 값들을 초기화한 새 상태 반환
  LibraryFilterState clearFilters() {
    return copyWith(
      showDetailFilter: false,
      acidity: null,
      body: null,
      bitterness: null,
    );
  }

  /// 필터 UI 표시 여부를 토글한 새 상태 반환
  LibraryFilterState toggleFilterVisibility() {
    if (showDetailFilter) {
      // 닫을 때 필터 값 초기화
      return clearFilters();
    }
    // 열 때는 표시 여부만 켜고 기존 값을 유지(null이면 그대로 null)
    return copyWith(showDetailFilter: true);
  }

  /// 상태를 복사하여 새 인스턴스 생성
  LibraryFilterState copyWith({
    bool? showDetailFilter,
    int? acidity,
    int? body,
    int? bitterness,
  }) {
    return LibraryFilterState(
      showDetailFilter: showDetailFilter ?? this.showDetailFilter,
      acidity: acidity ?? this.acidity,
      body: body ?? this.body,
      bitterness: bitterness ?? this.bitterness,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LibraryFilterState &&
    runtimeType == other.runtimeType &&
    showDetailFilter == other.showDetailFilter &&
    acidity == other.acidity &&
    body == other.body &&
    bitterness == other.bitterness;

  @override
  int get hashCode =>
    showDetailFilter.hashCode ^
    acidity.hashCode ^
    body.hashCode ^
    bitterness.hashCode;
}
