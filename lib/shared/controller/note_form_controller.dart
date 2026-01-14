import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/note.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
import '../../backend/providers.dart';
import '../state/note_form_state.dart';
import 'note_form_controller_base.dart';

/// Note 폼의 상태를 관리하는 Notifier
class NoteFormViewData {
  final NoteFormState formState;
  final bool showDetailSection;
  final bool isGenerating;

  const NoteFormViewData({
    required this.formState,
    this.showDetailSection = false,
    this.isGenerating = false,
  });

  NoteFormViewData copyWith({
    NoteFormState? formState,
    bool? showDetailSection,
    bool? isGenerating,
  }) {
    return NoteFormViewData(
      formState: formState ?? this.formState,
      showDetailSection: showDetailSection ?? this.showDetailSection,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

/// Creation 모달용 Provider (Family로 prefillData 전달)
final noteFormCreationControllerProvider = 
    NotifierProvider.autoDispose.family<NoteFormCreationController, NoteFormViewData, Map<String, dynamic>?>(
  () => NoteFormCreationController(),
);

class NoteFormCreationController extends AutoDisposeFamilyNotifier<NoteFormViewData, Map<String, dynamic>?> {
  @override
  NoteFormViewData build(Map<String, dynamic>? prefillData) {
    final formState = NoteFormState.forCreation(prefillData: prefillData);
    final showDetailSection = prefillData != null;
    
    // dispose 시 formState 정리
    ref.onDispose(() {
      if (formState.isGenerating) {
        formState.cancelAiGeneration();
      }
      formState.dispose();
    });
    
    return NoteFormViewData(
      formState: formState,
      showDetailSection: showDetailSection,
      isGenerating: formState.isGenerating,
    );
  }

  void updateShowDetailSection(bool value) {
    state = state.copyWith(showDetailSection: value);
  }

  void updateIsGenerating(bool value) {
    state.formState.isGenerating = value;
    state = state.copyWith(isGenerating: value);
  }

  void resetDetailFields() {
    if (state.isGenerating) {
      state.formState.cancelAiGeneration();
    }
    state.formState.resetDetailFields();
    updateIsGenerating(false);
  }

  /// AI 자동생성 처리
  Future<void> generateAiData() async {
    await NoteFormControllerHelper.generateAiData(
      formState: state.formState,
      ref: ref as Ref,
      updateIsGenerating: updateIsGenerating,
      updateShowDetailSection: updateShowDetailSection,
    );
  }

  /// 폼 검증
  bool isFormValid() {
    return NoteFormControllerHelper.isFormValid(state.formState);
  }

  /// Note 생성
  Future<void> createNote() async {
    final formState = state.formState;
    final noteService = ref.read(noteServiceProvider);
    final imageService = ref.read(imageServiceProvider);
    final detailService = ref.read(detailServiceProvider);
    
    DateTime parsedDate = DateTime.parse(formState.dateController.text);
    final String noteId = const Uuid().v4();
    String? savedImagePath;

    if (formState.selectedImage != null) {
      savedImagePath = await imageService.saveImage(formState.selectedImage!, noteId);
    }

    final newNote = Note(
      id: noteId,
      location: formState.cafeController.text,
      menu: formState.menuController.text,
      comment: formState.commentController.text,
      levelAcidity: formState.acidity.toInt(),
      levelBody: formState.body.toInt(),
      levelBitterness: formState.bitterness.toInt(),
      score: formState.score,
      drankAt: parsedDate,
      image: savedImagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await noteService.createNote(newNote);

    if (state.showDetailSection) {
      final newDetail = NoteFormControllerHelper.createDetailFromForm(
        formState: state.formState,
        ref: ref as Ref,
        noteId: noteId,
      );
      if (newDetail != null) {
        await detailService.createDetail(newDetail);
      }
    }
  }
}

/// Details 모달용 Provider (AsyncNotifier 사용)
final noteFormDetailsControllerProvider = 
    AsyncNotifierProvider.autoDispose.family<NoteFormDetailsController, NoteFormViewData, Note>(
  () => NoteFormDetailsController(),
);

class NoteFormDetailsController extends AutoDisposeFamilyAsyncNotifier<NoteFormViewData, Note> {
  Detail? _detail;
  bool _isEditing = false;

  @override
  Future<NoteFormViewData> build(Note note) async {
    final formState = NoteFormState.forDetails(note, null);
    
    // dispose 시 formState 정리
    ref.onDispose(() {
      if (formState.isGenerating) {
        formState.cancelAiGeneration();
      }
      formState.dispose();
    });
    
    // Detail 로드 (비동기)
    final detail = await _loadDetailData(note.id);
    if (detail != null) {
      _detail = detail;
      _applyDetailToFormState(formState, detail);
      return NoteFormViewData(
        formState: formState,
        showDetailSection: true,
        isGenerating: formState.isGenerating,
      );
    }
    
    return NoteFormViewData(
      formState: formState,
      showDetailSection: false,
      isGenerating: formState.isGenerating,
    );
  }

  Future<Detail?> _loadDetailData(String noteId) async {
    final detailService = ref.read(detailServiceProvider);
    return await detailService.getDetailByNoteId(noteId);
  }

  void _applyDetailToFormState(NoteFormState formState, Detail detail) {
    formState.countryController.text = detail.originLocation ?? "";
    formState.varietyController.text = detail.variety ?? "";
    formState.selectedProcess = detail.process ?? ProcessType.etc;
    formState.selectedRoasting = detail.roastingPoint ?? RoastingPointType.etc;
    formState.selectedMethod = detail.method ?? MethodType.etc;
    formState.processTextController.text = detail.processText ?? "";
    formState.roastingPointTextController.text = detail.roastingPointText ?? "";
    formState.methodTextController.text = detail.methodText ?? "";
    formState.tastingNotesTags = detail.tastingNotes ?? [];
    if (formState.tastingNotesTags.isNotEmpty) {
      formState.tastingNotesController.text = formState.tastingNotesTags.join(', ');
    }
    // state 업데이트
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(showDetailSection: true));
    }
  }

  void setEditing(bool value) {
    _isEditing = value;
  }

  bool get isEditing => _isEditing;

  Detail? get detail => _detail;

  void updateShowDetailSection(bool value) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(showDetailSection: value));
    }
  }

  void updateIsGenerating(bool value) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      currentState.formState.updateIsGenerating(value);
      state = AsyncValue.data(currentState.copyWith(isGenerating: value));
    }
  }

  void resetDetailFields() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      if (currentState.isGenerating) {
        currentState.formState.cancelAiGeneration();
      }
      currentState.formState.resetDetailFields();
      updateIsGenerating(false);
    }
  }

  /// AI 자동생성 처리
  Future<void> generateAiData() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    await NoteFormControllerHelper.generateAiData(
      formState: currentState.formState,
      ref: ref as Ref,
      updateIsGenerating: updateIsGenerating,
      updateShowDetailSection: updateShowDetailSection,
    );
  }

  /// 폼 검증
  bool isFormValid() {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;
    return NoteFormControllerHelper.isFormValid(currentState.formState);
  }

  /// Note 업데이트
  Future<void> updateNote(Note note) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final formState = currentState.formState;
    final noteService = ref.read(noteServiceProvider);
    final imageService = ref.read(imageServiceProvider);
    final detailService = ref.read(detailServiceProvider);
    
    String? savedImagePath;

    // 새로 선택한 이미지가 있으면 저장
    if (formState.selectedImage != null) {
      savedImagePath = await imageService.saveImage(formState.selectedImage!, note.id);
    } else if (formState.existingImagePath != null) {
      // 기존 이미지 경로 유지
      savedImagePath = formState.existingImagePath;
    }

    final updatedNote = Note(
      id: note.id,
      location: formState.cafeController.text,
      menu: formState.menuController.text,
      comment: formState.commentController.text,
      levelAcidity: formState.acidity.toInt(),
      levelBody: formState.body.toInt(),
      levelBitterness: formState.bitterness.toInt(),
      score: formState.score,
      drankAt: DateTime.parse(formState.dateController.text),
      image: savedImagePath,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    await noteService.updateNote(updatedNote);
    
    // 상세 정보 섹션이 체크되어 있을 때만 detail 저장
    if (currentState.showDetailSection) {
      final updatedDetail = NoteFormControllerHelper.createDetailFromForm(
        formState: currentState.formState,
        ref: ref as Ref,
        noteId: note.id,
        existingId: _detail?.id,
      );
      if (updatedDetail != null) {
        if (_detail != null) {
          await detailService.updateDetail(updatedDetail);
        } else {
          await detailService.createDetail(updatedDetail);
        }
      } else if (_detail != null) {
        // 모든 필드가 NULL이 되었고 기존 detail이 있으면 삭제
        await detailService.deleteDetail(_detail!.id);
      }
    } else if (_detail != null) {
      // 체크박스가 해제되었는데 기존 detail이 있으면 삭제
      await detailService.deleteDetail(_detail!.id);
    }
  }
}
