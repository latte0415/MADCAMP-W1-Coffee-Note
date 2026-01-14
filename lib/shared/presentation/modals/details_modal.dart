import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../models/detail.dart';
import '../../../backend/providers.dart';
import '../../../models/enums/process_type.dart';
import '../../../models/enums/roasting_point_type.dart';
import '../../../models/enums/method_type.dart';
import '../../../theme/theme.dart';
import '../../state/note_form_state.dart';
import '../widgets/note_form_widgets.dart';

class NoteDetailsModal extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailsModal({super.key, required this.note});

  @override
  ConsumerState<NoteDetailsModal> createState() => _NoteDetailsModalState();
}

class _NoteDetailsModalState extends ConsumerState<NoteDetailsModal> {
  late NoteFormState _formState;
  bool _isEditing = false;
  bool _showDetailSection = false;
  Detail? _detail;

  @override
  void initState() {
    super.initState();
    // 초기에는 Note만으로 formState 생성 (Detail은 나중에 로드)
    _formState = NoteFormState.forDetails(widget.note, null);
    _loadDetailData();
  }

  @override
  void dispose() {
    _formState.dispose();
    super.dispose();
  }

  // detail table load 함수
  Future<void> _loadDetailData() async {
    final detailService = ref.read(detailServiceProvider);
    final detail = await detailService.getDetailByNoteId(widget.note.id);
    if (mounted) {
      setState(() {
        if (detail != null) {
          _detail = detail;
          _showDetailSection = true; // 기존 detail 정보가 있으면 체크박스 체크
          _formState.countryController.text = detail.originLocation ?? "";
          _formState.varietyController.text = detail.variety ?? "";

          // Enum 값들 설정 (null이면 기본값 "직접입력")
          _formState.selectedProcess = detail.process ?? ProcessType.etc;
          _formState.selectedRoasting = detail.roastingPoint ?? RoastingPointType.etc;
          _formState.selectedMethod = detail.method ?? MethodType.etc;

          // 직접 입력했던 텍스트들을 각 컨트롤러에 넣어줌
          _formState.processTextController.text = detail.processText ?? "";
          _formState.roastingPointTextController.text = detail.roastingPointText ?? "";
          _formState.methodTextController.text = detail.methodText ?? "";

          _formState.tastingNotesTags = detail.tastingNotes ?? [];
          if (_formState.tastingNotesTags.isNotEmpty) {
            _formState.tastingNotesController.text = _formState.tastingNotesTags.join(', ');
          }
        } else {
          _showDetailSection = false; // 기존 detail 정보가 없으면 체크박스 해제
        }
      });
    }
  }

  bool _isFormValid() {
    return _formState.cafeController.text.trim().isNotEmpty &&
           _formState.menuController.text.trim().isNotEmpty;
  }

  void _showValidationError() {
    final missingFields = <String>[];
    if (_formState.cafeController.text.trim().isEmpty) {
      missingFields.add('카페명');
    }
    if (_formState.menuController.text.trim().isEmpty) {
      missingFields.add('메뉴명');
    }
    
    if (missingFields.isNotEmpty) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${missingFields.first}을(를) 입력해주세요',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      
      overlay.insert(overlayEntry);
      
      Future.delayed(const Duration(seconds: 2), () {
        overlayEntry.remove();
      });
    }
  }

  // 업데이트 로직
  Future<void> _updateSubmit() async {
    final noteService = ref.read(noteServiceProvider);
    final imageService = ref.read(imageServiceProvider);
    final detailService = ref.read(detailServiceProvider);
    
    String? savedImagePath;

    // 새로 선택한 이미지가 있으면 저장
    if (_formState.selectedImage != null) {
      savedImagePath = await imageService.saveImage(_formState.selectedImage!, widget.note.id);
      // 기존 이미지 삭제 (선택사항 - 필요시 추가)
    } else if (_formState.existingImagePath != null) {
      // 기존 이미지 경로 유지
      savedImagePath = _formState.existingImagePath;
    }

    final updatedNote = Note(
      id: widget.note.id,
      location: _formState.cafeController.text,
      menu: _formState.menuController.text,
      comment: _formState.commentController.text,
      levelAcidity: _formState.acidity.toInt(),
      levelBody: _formState.body.toInt(),
      levelBitterness: _formState.bitterness.toInt(),
      score: _formState.score,
      drankAt: DateTime.parse(_formState.dateController.text),
      image: savedImagePath,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
    );

    await noteService.updateNote(updatedNote);
    
    // 상세 정보 섹션이 체크되어 있을 때만 detail 저장
    if (_showDetailSection) {
      final updatedDetail = _formState.createDetailFromForm(widget.note.id, existingId: _detail?.id);
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

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- [1. 고정 영역] 상단 바 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryDark, size: 16),
                  onPressed: () => Navigator.pop(context, false),
                ),
                Text(
                  _isEditing ? "노트 수정" : "노트 정보",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (!_isEditing)
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditing = true);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: const Text("수정"),
                  )
                else
                  const SizedBox(width: 48), // 대칭을 위한 공간
              ],
            ),

            // --- [2. 스크롤 영역] ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // 이미지 영역
                    NoteImageSection(
                      formState: _formState,
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
                      formState: _formState,
                      isEditing: _isEditing,
                      setState: () => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // 상세정보 추가하기 토글 체크박스 + 상세 정보 섹션
                    NoteDetailSectionWithToggle(
                      formState: _formState,
                      isEditing: _isEditing,
                      showDetailSection: _showDetailSection,
                      onToggleChanged: (value) => setState(() => _showDetailSection = value),
                      setState: () => setState(() {}),
                      showAiButton: false,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- [3. 고정 영역] 저장 버튼 (수정 모드일 때만 표시) ---
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid() ? AppColors.primaryDark : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isFormValid() ? _updateSubmit : _showValidationError,
                    child: const Text(
                      "저장",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
