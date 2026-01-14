import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../backend/providers.dart';
import '../../models/detail.dart';
import '../state/note_form_state.dart';

/// Note 폼 Controller의 공통 로직을 담당하는 Helper 클래스
class NoteFormControllerHelper {
  /// AI 자동생성 처리 (공통 로직)
  static Future<void> generateAiData({
    required NoteFormState formState,
    required Ref ref,
    required void Function(bool) updateIsGenerating,
    required void Function(bool) updateShowDetailSection,
  }) async {
    final menuName = formState.menuController.text.trim();
    
    if (menuName.isEmpty) {
      throw Exception('메뉴명을(를) 입력해주세요');
    }

    // 기존 요청이 있으면 취소
    if (formState.isGenerating) {
      formState.cancelAiGeneration();
    }

    // 새로운 CancelToken 생성
    final cancelToken = CancelToken();
    formState.startAiGeneration(cancelToken);
    updateIsGenerating(true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final future = apiService.chatForMapping(
        menuName,
        cancelToken: cancelToken,
      );
      formState.aiGenerationFuture = future;
      
      final result = await future;
      
      // Future 일치 확인
      if (formState.aiGenerationFuture == future && 
          formState.aiGenerationCancelToken != null &&
          !formState.aiGenerationCancelToken!.isCancelled) {
        formState.applyAiResponse(result, () {});
        formState.completeAiGeneration();
        updateIsGenerating(false);
        updateShowDetailSection(true);
      }
    } catch (e) {
      // CancelToken으로 인한 취소는 무시
      if (e is DioException && e.type == DioExceptionType.cancel) {
        formState.completeAiGeneration();
        updateIsGenerating(false);
        return;
      }
      
      // 다른 에러는 다시 throw
      formState.completeAiGeneration();
      updateIsGenerating(false);
      rethrow;
    }
  }

  /// 폼 검증 (공통 로직)
  static bool isFormValid(NoteFormState formState) {
    return formState.cafeController.text.trim().isNotEmpty &&
           formState.menuController.text.trim().isNotEmpty;
  }

  /// Detail 객체 생성 (비즈니스 로직)
  static Detail? createDetailFromForm({
    required NoteFormState formState,
    required Ref ref,
    required String noteId,
    String? existingId,
  }) {
    final detailService = ref.read(detailServiceProvider);
    return detailService.createDetailFromForm(
      formState,
      noteId,
      existingId: existingId,
    );
  }
}
