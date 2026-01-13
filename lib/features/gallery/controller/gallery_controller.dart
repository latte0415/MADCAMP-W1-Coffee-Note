import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/note.dart';
import '../../../backend/providers.dart';
import '../../../backend/services/note_service.dart';
import '../state/gallery_state.dart';

final galleryControllerProvider =
    AsyncNotifierProvider<GalleryController, GalleryViewData>(
  () => GalleryController(),
);

class GalleryController extends AsyncNotifier<GalleryViewData> {
  late final NoteService _noteService;

  @override
  Future<GalleryViewData> build() async {
    _noteService = ref.read(noteServiceProvider);
    return _load(const GalleryState());
  }

  /// 서비스 레이어 호출이 필요한 데이터 재조회 (비동기)
  Future<void> refresh() async {
    final currentState = state.valueOrNull?.state ?? const GalleryState();
    await _runQuery(currentState);
  }

  Future<GalleryViewData> _load(GalleryState state) async {
    final notes = await _noteService.getImageNotes();
    return GalleryViewData(state: state, notes: notes);
  }

  /// UI 상태만 변경 (동기): 활성 노트 선택
  /// 서비스 레이어 호출이 필요 없는 UI 전용 상태 변경이므로 비동기 아님
  void setActiveNote(String? noteId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        state: current.state.copyWith(activeNoteId: noteId),
      ),
    );
  }

  /// 서비스 레이어 호출이 필요한 쿼리 실행 (비동기)
  /// refresh()에서만 사용하며, setActiveNote는 UI 상태 변경이므로 직접 상태 업데이트
  Future<void> _runQuery(GalleryState nextState) async {
    final previous = state.valueOrNull;

    if (previous != null) {
      state = AsyncValue.data(
        previous.copyWith(
          state: nextState,
          isRefreshing: true,
          clearError: true,
        ),
      );
    }

    final result = await AsyncValue.guard(() => _load(nextState));

    state = result.when(
      data: (data) => AsyncValue.data(data),
      error: (e, st) {
        // 에러 발생 시 이전 데이터를 유지하고 error 필드만 업데이트
        if (previous != null) {
          return AsyncValue.data(previous.copyWith(error: e, isRefreshing: false));
        }
        return AsyncValue.error(e, st);
      },
      loading: () => const AsyncValue.loading(),
    );
  }
}
