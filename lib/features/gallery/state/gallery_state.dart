import '../../../models/note.dart';

class GalleryState {
  final String? activeNoteId;

  const GalleryState({
    this.activeNoteId,
  });

  GalleryState copyWith({
    String? activeNoteId,
    bool clearActive = false,
  }) {
    return GalleryState(
      activeNoteId: clearActive ? null : (activeNoteId ?? this.activeNoteId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryState &&
          runtimeType == other.runtimeType &&
          activeNoteId == other.activeNoteId;

  @override
  int get hashCode => activeNoteId.hashCode;
}

class GalleryViewData {
  final GalleryState state;
  final List<Note> notes;
  final bool isRefreshing;
  final Object? error;

  const GalleryViewData({
    required this.state,
    required this.notes,
    this.isRefreshing = false,
    this.error,
  });

  GalleryViewData copyWith({
    GalleryState? state,
    List<Note>? notes,
    bool? isRefreshing,
    Object? error,
    bool clearError = false,
  }) {
    return GalleryViewData(
      state: state ?? this.state,
      notes: notes ?? this.notes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
