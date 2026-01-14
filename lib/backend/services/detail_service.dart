import 'package:uuid/uuid.dart';
import '../repositories/detail_repository.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
import '../../shared/state/note_form_state.dart';

class DetailService {
    final DetailRepository detailRepository;

    DetailService({required this.detailRepository});

    Future<Detail> createDetail(Detail detail) async {
        return await detailRepository.createDetail(detail);
    }

    Future<Detail?> getDetailByNoteId(String noteId) async {
        return await detailRepository.getDetailByNoteId(noteId);
    }

    Future<Detail> updateDetail(Detail detail) async {
        return await detailRepository.updateDetail(detail);
    }

    Future<bool> deleteDetail(String id) async {
        return await detailRepository.deleteDetail(id);
    }

    /// Form 데이터로부터 Detail 객체 생성
    /// 모든 필드가 NULL이면 null을 반환 (detail 저장 생략)
    Detail? createDetailFromForm(
      NoteFormState formState,
      String noteId, {
      String? existingId,
    }) {
      // "직접입력"(etc) 선택 시 텍스트가 빈칸이면 NULL로 처리
      final processText = formState.selectedProcess == ProcessType.etc && 
              formState.processTextController.text.trim().isNotEmpty
          ? formState.processTextController.text.trim()
          : null;
      final roastingPointText = formState.selectedRoasting == RoastingPointType.etc && 
              formState.roastingPointTextController.text.trim().isNotEmpty
          ? formState.roastingPointTextController.text.trim()
          : null;
      final methodText = formState.selectedMethod == MethodType.etc && 
              formState.methodTextController.text.trim().isNotEmpty
          ? formState.methodTextController.text.trim()
          : null;
      
      // "직접입력"이 아닌 경우 enum 값 사용, "직접입력"이면 null
      final process = formState.selectedProcess == ProcessType.etc ? null : formState.selectedProcess;
      final roastingPoint = formState.selectedRoasting == RoastingPointType.etc ? null : formState.selectedRoasting;
      final method = formState.selectedMethod == MethodType.etc ? null : formState.selectedMethod;
      
      final originLocation = formState.countryController.text.trim().isEmpty 
          ? null 
          : formState.countryController.text.trim();
      final variety = formState.varietyController.text.trim().isEmpty 
          ? null 
          : formState.varietyController.text.trim();
      final tastingNotes = formState.tastingNotesTags.isNotEmpty ? formState.tastingNotesTags : null;
      
      // 모든 필드가 NULL인지 확인
      if (originLocation == null &&
          variety == null &&
          process == null &&
          processText == null &&
          roastingPoint == null &&
          roastingPointText == null &&
          method == null &&
          methodText == null &&
          tastingNotes == null) {
        return null; // 모든 필드가 NULL이면 detail 저장 생략
      }
      
      return Detail(
        id: existingId ?? const Uuid().v4(),
        noteId: noteId,
        originLocation: originLocation,
        variety: variety,
        process: process,
        processText: processText,
        roastingPoint: roastingPoint,
        roastingPointText: roastingPointText,
        method: method,
        methodText: methodText,
        tastingNotes: tastingNotes,
      );
    }
}