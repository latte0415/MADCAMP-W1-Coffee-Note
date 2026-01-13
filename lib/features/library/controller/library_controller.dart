import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/note.dart';
import '../../../backend/providers.dart';
import '../../../backend/services/note_service.dart';
import '../state/library_state.dart';
import '../state/library_filter_state.dart';
import '../../../models/sort_option.dart';

/// UI에 전달할 뷰 모델: 현재 쿼리 상태와 노트 리스트를 함께 보관
class LibraryViewData {
  final LibraryState query;
  final List<Note> notes;
  final bool isRefreshing;
  final Object? error;

  const LibraryViewData({
    required this.query,
    required this.notes,
    this.isRefreshing = false,
    this.error,
  });

  LibraryViewData copyWith({
    LibraryState? query,
    List<Note>? notes,
    bool? isRefreshing,
    Object? error,
    bool clearError = false,
  }) {
    return LibraryViewData(
      query: query ?? this.query,
      notes: notes ?? this.notes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 라이브러리 화면 상태를 관리하는 AsyncNotifier 초안.
/// - 비동기 로딩/에러/데이터를 AsyncValue로 노출
/// - 정렬/검색/필터 업데이트 시 노트 리스트를 다시 로드
final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, LibraryViewData>(
  () => LibraryController(),
);

class LibraryController extends AsyncNotifier<LibraryViewData> {
  late final NoteService _noteService;

  @override
  Future<LibraryViewData> build() async {
    _noteService = ref.read(noteServiceProvider);
    // 초기 상태: 기본 쿼리 + 전체 노트 로드
    return _loadNotes(const LibraryState());
  }

  /// 최신 상태(query)에 맞춰 노트 재조회
  Future<void> refresh() async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    await _runQuery(currentQuery);
  }

  /// 정렬 옵션 변경 후 재조회
  Future<void> updateSort(SortOption sortOption) async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    final nextQuery = currentQuery.copyWithSortOption(sortOption);
    await _runQuery(nextQuery);
  }

  /// 검색어 변경 후 재조회 (빈 문자열이면 검색 해제)
  Future<void> updateSearch(String? query) async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    final nextQuery = currentQuery.copyWithSearchQuery(
      (query == null || query.isEmpty) ? null : query,
    );
    await _runQuery(nextQuery);
  }

  /// 필터 표시 토글 후 재조회 (숨길 경우 필터 값 초기화)
  Future<void> toggleFilterVisibility() async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    final nextFilter = currentQuery.filterState.toggleFilterVisibility();
    final nextQuery = currentQuery.copyWithFilterState(nextFilter);
    await _runQuery(nextQuery);
  }

  /// 필터 값 업데이트 후 재조회
  Future<void> updateFilterValues({
    int? acidity,
    int? body,
    int? bitterness,
  }) async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    final filter = currentQuery.filterState.copyWith(
      acidity: acidity,
      body: body,
      bitterness: bitterness,
    );
    final nextQuery = currentQuery.copyWithFilterState(filter);
    await _runQuery(nextQuery);
  }

  /// 필터 초기화 후 재조회
  Future<void> clearFilters() async {
    final currentQuery = state.valueOrNull?.query ?? const LibraryState();
    final nextQuery =
        currentQuery.copyWithFilterState(currentQuery.filterState.clearFilters());
    await _runQuery(nextQuery);
  }

  /// 실제 노트 조회 로직: Service의 getNotes(NoteQuery)로 일괄 처리
  Future<LibraryViewData> _loadNotes(LibraryState query) async {
    final filter = query.filterState;
    final notes = await _noteService.getNotes(NoteQuery(
      query: query.searchQuery,
      sortOption: query.sortOption,
      showDetailFilter: filter.showDetailFilter,
      acidity: filter.acidity,
      body: filter.body,
      bitterness: filter.bitterness,
    ));

    return LibraryViewData(query: query, notes: notes);
  }

  Future<void> _runQuery(LibraryState nextQuery) async {
    final prev = state.valueOrNull;

    if (prev != null) {
      state = AsyncValue.data(
        prev.copyWith(
          query: nextQuery,
          isRefreshing: true,
          clearError: true,
        ),
      );
    }

    final result = await AsyncValue.guard(() => _loadNotes(nextQuery));

    state = result.when(
      data: (data) => AsyncValue.data(data),
      error: (e, st) {
        // 에러 발생 시 이전 데이터를 유지하고 error 필드만 업데이트
        if (prev != null) {
          return AsyncValue.data(prev.copyWith(error: e, isRefreshing: false));
        }
        return AsyncValue.error(e, st);
      },
      loading: () => const AsyncValue.loading(),
    );
  }
}
