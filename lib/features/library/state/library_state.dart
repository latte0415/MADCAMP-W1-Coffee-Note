import '../../../models/sort_option.dart';
import 'library_filter_state.dart';

/// Library 페이지의 전체 상태를 관리하는 모델
class LibraryState {
  /// 현재 선택된 정렬 옵션 (기본값: 날짜 최신순)
  final SortOption sortOption;
  
  /// 검색어 (null이면 검색 미사용)
  final String? searchQuery;
  
  /// 필터 상태
  final LibraryFilterState filterState;

  const LibraryState({
    this.sortOption = const DateSortOption(ascending: false),
    this.searchQuery,
    this.filterState = const LibraryFilterState(),
  });

  /// 정렬 옵션을 변경한 새 상태 반환
  LibraryState copyWithSortOption(SortOption sortOption) {
    return copyWith(sortOption: sortOption);
  }

  /// 검색어를 변경한 새 상태 반환
  LibraryState copyWithSearchQuery(String? searchQuery) {
    return copyWith(
      searchQuery: searchQuery,
      clearSearchQuery: searchQuery == null || searchQuery.isEmpty,
    );
  }

  /// 필터 상태를 변경한 새 상태 반환
  LibraryState copyWithFilterState(LibraryFilterState filterState) {
    return copyWith(filterState: filterState);
  }

  /// 상태를 복사하여 새 인스턴스 생성
  LibraryState copyWith({
    SortOption? sortOption,
    String? searchQuery,
    LibraryFilterState? filterState,
    bool clearSearchQuery = false,
  }) {
    return LibraryState(
      sortOption: sortOption ?? this.sortOption,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      filterState: filterState ?? this.filterState,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LibraryState &&
    runtimeType == other.runtimeType &&
    sortOption == other.sortOption &&
    searchQuery == other.searchQuery &&
    filterState == other.filterState;

  @override
  int get hashCode =>
    sortOption.hashCode ^
    searchQuery.hashCode ^
    filterState.hashCode;
}
