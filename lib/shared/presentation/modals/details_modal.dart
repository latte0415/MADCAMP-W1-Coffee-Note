import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../models/note.dart';
import '../../../models/detail.dart';
import '../../../backend/providers.dart';
import '../../../models/enums/process_type.dart';
import '../../../models/enums/roasting_point_type.dart';
import '../../../models/enums/method_type.dart';
import '../../../theme/theme.dart';
import '../../state/note_form_state.dart';
import '../../controller/note_form_controller.dart';
import '../widgets/note_form_widgets.dart';
import 'note_modal_mixin.dart';
import '../widgets/note_modal_scaffold.dart';
import '../widgets/note_modal_header.dart';
import '../widgets/note_modal_button.dart';

class NoteDetailsModal extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailsModal({super.key, required this.note});

  @override
  ConsumerState<NoteDetailsModal> createState() => _NoteDetailsModalState();
}

class _NoteDetailsModalState extends ConsumerState<NoteDetailsModal> with NoteModalMixin {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(noteFormDetailsControllerProvider(widget.note));
    final controller = ref.read(noteFormDetailsControllerProvider(widget.note).notifier);
    
    return asyncState.when(
      data: (viewData) => _buildContent(context, viewData, controller),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류가 발생했습니다: $error'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.invalidate(noteFormDetailsControllerProvider(widget.note)),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NoteFormViewData viewData, NoteFormDetailsController controller) {
    final formState = viewData.formState;

    return NoteModalScaffold(
      header: NoteModalHeader(
        title: _isEditing ? "노트 수정" : "노트 정보",
        onClose: () => Navigator.pop(context, false),
        actionButton: !_isEditing
            ? TextButton(
                onPressed: () {
                  setState(() => _isEditing = true);
                  controller.setEditing(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                ),
                child: const Text("수정"),
              )
            : null,
      ),
      content: Column(
        children: [
          const SizedBox(height: 10),
          // 이미지 영역
          NoteImageSection(
            formState: formState,
            scale: 1.0,
            enabled: _isEditing,
            setState: () => setState(() {}),
          ),
          if (_isEditing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text("사진을 터치하여 변경", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),

          // 기본 입력 필드들
          const SizedBox(height: 20),
          NoteBasicFieldsSection(
            formState: formState,
            isEditing: _isEditing,
            setState: () => setState(() {}),
          ),

          const SizedBox(height: 20),

          // 상세정보 추가하기 토글 체크박스 + 상세 정보 섹션
          NoteDetailSectionWithToggle(
            formState: formState,
            isEditing: _isEditing,
            showDetailSection: viewData.showDetailSection,
            onToggleChanged: (value) => controller.updateShowDetailSection(value),
            setState: () => setState(() {}),
            showAiButton: _isEditing,
            onAiGenerate: _isEditing
                ? () async {
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
                          showApiError(context, e);
                        }
                      }
                    }
                  }
                : null,
            onReset: _isEditing 
                ? () => controller.resetDetailFields()
                : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingButtonBuilder: _isEditing
          ? () {
              final asyncState = ref.watch(noteFormDetailsControllerProvider(widget.note));
              final currentController = ref.read(noteFormDetailsControllerProvider(widget.note).notifier);
              final currentViewData = asyncState.valueOrNull;
              if (currentViewData == null) return const SizedBox.shrink();
              return NoteModalButton(
                isValid: currentController.isFormValid(),
                isGenerating: currentViewData.isGenerating,
                buttonText: "저장",
                onPressed: () async {
                  try {
                    await currentController.updateNote(widget.note);
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
                  final asyncState = ref.read(noteFormDetailsControllerProvider(widget.note));
                  final viewData = asyncState.valueOrNull;
                  if (viewData != null) {
                    showValidationError(context, viewData.formState);
                  }
                },
              );
            }
          : null,
    );
  }

}
