import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../models/note.dart';
import 'package:uuid/uuid.dart';
import '../../../backend/providers.dart';
import '../../state/note_form_state.dart';
import '../../controller/note_form_controller.dart';
import '../widgets/note_form_widgets.dart';
import 'note_modal_mixin.dart';
import '../widgets/note_modal_scaffold.dart';
import '../widgets/note_modal_header.dart';
import '../widgets/note_modal_button.dart';



class NoteCreatePopup extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prefillData;
  
  const NoteCreatePopup({super.key, this.prefillData});

  @override
  ConsumerState<NoteCreatePopup> createState() => _NoteCreatePopupState();
}

class _NoteCreatePopupState extends ConsumerState<NoteCreatePopup> with NoteModalMixin {
  @override
  Widget build(BuildContext context) {
    final viewData = ref.watch(noteFormCreationControllerProvider(widget.prefillData));
    final controller = ref.read(noteFormCreationControllerProvider(widget.prefillData).notifier);
    final formState = viewData.formState;
    final scale = formState.getScaleFactor(context);

    return NoteModalScaffold(
      header: NoteModalHeader(
        title: "기록하기",
        onClose: () => Navigator.pop(context),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 이미지 추가 영역
          NoteImageSection(
            formState: formState,
            scale: scale,
            enabled: true,
            setState: () => setState(() {}),
          ),
          const SizedBox(height: 20),

          // 2. 기본 입력 필드
          NoteBasicFieldsSection(
            formState: formState,
            isEditing: true,
            setState: () => setState(() {}),
          ),
          const SizedBox(height: 25),

          // 3. 상세정보 추가하기 토글 체크박스 + 상세 정보 섹션
          NoteDetailSectionWithToggle(
            formState: formState,
            isEditing: true,
            showDetailSection: viewData.showDetailSection,
            onToggleChanged: (value) => controller.updateShowDetailSection(value),
            setState: () => setState(() {}),
            showAiButton: true,
            onAiGenerate: () async {
              try {
                await controller.generateAiData();
              } catch (e) {
                // 취소된 경우는 조용히 처리 (사용자에게 에러 표시 안 함)
                if (e is DioException && e.type == DioExceptionType.cancel) {
                  return;
                }
                
                if (mounted) {
                  if (e.toString().contains('메뉴명')) {
                    showMenuValidationError(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("AI 자동생성 중 오류가 발생했습니다: ${e.toString()}")),
                    );
                  }
                }
              }
            },
            onReset: () => controller.resetDetailFields(),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingButtonBuilder: () {
        final currentViewData = ref.watch(noteFormCreationControllerProvider(widget.prefillData));
        final currentController = ref.read(noteFormCreationControllerProvider(widget.prefillData).notifier);
        return NoteModalButton(
          isValid: currentController.isFormValid(),
          isGenerating: currentViewData.isGenerating,
          buttonText: "기록하기",
          onPressed: () async {
            try {
              await currentController.createNote();
              if (mounted) Navigator.pop(context, true);
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("날짜 형식이 올바르지 않거나 오류가 발생했습니다.")),
              );
              Navigator.pop(context, false);
            }
          },
          onValidationError: () {
            final viewData = ref.read(noteFormCreationControllerProvider(widget.prefillData));
            showValidationError(context, viewData.formState);
          },
        );
      },
    );
  }


}
