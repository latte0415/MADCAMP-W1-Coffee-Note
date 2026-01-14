import 'package:flutter/material.dart';
import 'dart:io';
import '../../state/note_form_state.dart';
import '../../../models/enums/process_type.dart';
import '../../../models/enums/roasting_point_type.dart';
import '../../../models/enums/method_type.dart';
import '../../../theme/theme.dart';
import 'popup_widget.dart';

/// 이미지 선택 및 표시 섹션
class NoteImageSection extends StatelessWidget {
  final NoteFormState formState;
  final double scale;
  final bool enabled;
  final VoidCallback setState;

  const NoteImageSection({
    super.key,
    required this.formState,
    required this.scale,
    required this.enabled,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => formState.showImagePicker(context, setState) : null,
      child: Container(
        width: double.infinity,
        height: 300 * scale,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.border, width: AppSpacing.borderWidth * scale),
        ),
        child: formState.hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: Image.file(
                  File(formState.currentImagePath!),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, color: Colors.grey, size: 60 * scale),
                  SizedBox(height: 10 * scale),
                  Text(
                    "이미지 추가하기",
                    style: TextStyle(
                      fontSize: 30 * scale,
                      color: Colors.grey,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 기본 입력 필드 섹션 (메뉴, 카페, 날짜, 슬라이더, 한줄평, 별점)
class NoteBasicFieldsSection extends StatelessWidget {
  final NoteFormState formState;
  final bool isEditing;
  final VoidCallback setState;

  const NoteBasicFieldsSection({
    super.key,
    required this.formState,
    required this.isEditing,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildField("메뉴명", formState.menuController, isEditing, onChanged: isEditing ? (_) => setState() : null),
        buildField("카페명", formState.cafeController, isEditing, onChanged: isEditing ? (_) => setState() : null),
        buildField("날짜", formState.dateController, isEditing),
        const SizedBox(height: 25),

        buildSlider(context, "산미", formState.acidity, (v) {
          formState.acidity = v;
          setState();
        }, isEditing),
        buildSlider(context, "바디", formState.body, (v) {
          formState.body = v;
          setState();
        }, isEditing),
        buildSlider(context, "쓴맛", formState.bitterness, (v) {
          formState.bitterness = v;
          setState();
        }, isEditing),
        const SizedBox(height: 20),

        buildField("한줄평", formState.commentController, isEditing),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => IconButton(
            onPressed: isEditing ? () {
              formState.score = index + 1;
              setState();
            } : null,
            icon: Icon(
              index < formState.score ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 35,
            ),
          )),
        ),
      ],
    );
  }
}

/// 상세 정보 섹션 (국가, 품종, 가공방식, 로스팅, 추출방식, 테이스팅 노트)
class NoteDetailSection extends StatelessWidget {
  final NoteFormState formState;
  final bool isEditing;
  final VoidCallback setState;

  const NoteDetailSection({
    super.key,
    required this.formState,
    required this.isEditing,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildField("국가/지역", formState.countryController, isEditing),
        buildField("품종", formState.varietyController, isEditing),
        const SizedBox(height: 10),

        if (isEditing) ...[
          buildDropdown<ProcessType>(
            "가공방식",
            formState.selectedProcess,
            ProcessType.values,
            (v) {
              formState.selectedProcess = v!;
              setState();
            },
            etcController: formState.processTextController,
          ),
          buildDropdown<RoastingPointType>(
            "로스팅포인트",
            formState.selectedRoasting,
            RoastingPointType.values,
            (v) {
              formState.selectedRoasting = v!;
              setState();
            },
            etcController: formState.roastingPointTextController,
          ),
          buildDropdown<MethodType>(
            "추출방식",
            formState.selectedMethod,
            MethodType.values,
            (v) {
              formState.selectedMethod = v!;
              setState();
            },
            etcController: formState.methodTextController,
          ),
          buildField(
            "테이스팅 노트",
            formState.tastingNotesController,
            true,
            onChanged: (value) => formState.handleTastingNotes(value, setState),
          ),
        ] else ...[
          buildReadOnlyDetail(
            "가공 방식",
            formState.selectedProcess == ProcessType.etc
                ? formState.processTextController.text
                : formState.selectedProcess.displayName,
          ),
          buildReadOnlyDetail(
            "로스팅",
            formState.selectedRoasting == RoastingPointType.etc
                ? formState.roastingPointTextController.text
                : formState.selectedRoasting.displayName,
          ),
          buildReadOnlyDetail(
            "추출 방식",
            formState.selectedMethod == MethodType.etc
                ? formState.methodTextController.text
                : formState.selectedMethod.displayName,
          ),
          const SizedBox(height: 15),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "테이스팅 노트",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (formState.tastingNotesTags.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: formState.tastingNotesTags.map((tag) => GestureDetector(
                onTap: isEditing ? () {
                  formState.tastingNotesTags.remove(tag);
                  setState();
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "#$tag",
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

/// 상세 정보 섹션과 체크박스를 함께 관리하는 위젯
class NoteDetailSectionWithToggle extends StatelessWidget {
  final NoteFormState formState;
  final bool isEditing;
  final bool showDetailSection;
  final ValueChanged<bool> onToggleChanged;
  final VoidCallback setState;
  final bool showAiButton;

  const NoteDetailSectionWithToggle({
    super.key,
    required this.formState,
    required this.isEditing,
    required this.showDetailSection,
    required this.onToggleChanged,
    required this.setState,
    this.showAiButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상세정보 추가하기 토글 체크박스
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "상세정보 추가하기",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            Checkbox(
              value: showDetailSection,
              onChanged: isEditing ? (value) => onToggleChanged(value ?? false) : null,
              activeColor: AppColors.primaryDark,
            ),
          ],
        ),

        // 상세 정보 섹션 (토글 상태에 따라 노출)
        if (showDetailSection) ...[
          SizedBox(height: showAiButton ? 10 : 20),
          if (showAiButton)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 90,
                height: 28,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // AI 자동생성 로직 추가
                  },
                  child: const Text(
                    "AI 자동생성",
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (showAiButton) const SizedBox(height: 20),
          NoteDetailSection(
            formState: formState,
            isEditing: isEditing,
            setState: setState,
          ),
          SizedBox(height: showAiButton ? 15 : 20),
        ],
      ],
    );
  }
}
