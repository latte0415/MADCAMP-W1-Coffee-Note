import 'package:flutter/material.dart';
import '../../../models/note.dart';
import '../../../services/note_service.dart';
import '../../../services/image_service.dart';
import 'package:uuid/uuid.dart';
import '../../../models/detail.dart';
import '../../../services/detail_service.dart';
import '../../../models/enums/process_type.dart';
import '../../../models/enums/roasting_point_type.dart';
import '../../../models/enums/method_type.dart';
import '../../../theme/app_colors.dart';
import '../../state/note_form_state.dart';
import 'note_form_widgets.dart';

class NoteDetailsModal extends StatefulWidget {
  final Note note;

  const NoteDetailsModal({super.key, required this.note});

  @override
  State<NoteDetailsModal> createState() => _NoteDetailsModalState();
}

class _NoteDetailsModalState extends State<NoteDetailsModal> {
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
    final detail = await DetailService.instance.getDetailByNoteId(widget.note.id);
    if (mounted) {
      setState(() {
        if (detail != null) {
          _detail = detail;
          _showDetailSection = true; // 기존 detail 정보가 있으면 체크박스 체크
          _formState.countryController.text = detail.originLocation ?? "";
          _formState.varietyController.text = detail.variety ?? "";

          // Enum 값들 설정
          _formState.selectedProcess = detail.process ?? ProcessType.washed;
          _formState.selectedRoasting = detail.roastingPoint ?? RoastingPointType.medium;
          _formState.selectedMethod = detail.method ?? MethodType.filter;

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

  // 업데이트 로직
  Future<void> _updateSubmit() async {
    String? savedImagePath;

    // 새로 선택한 이미지가 있으면 저장
    if (_formState.selectedImage != null) {
      savedImagePath = await ImageService.instance.saveImage(_formState.selectedImage!, widget.note.id);
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

    final updatedDetail = Detail(
      id: _detail?.id ?? const Uuid().v4(),
      noteId: widget.note.id,
      originLocation: _formState.countryController.text.isEmpty ? null : _formState.countryController.text,
      variety: _formState.varietyController.text.isEmpty ? null : _formState.varietyController.text,
      process: _formState.selectedProcess,
      processText: _formState.selectedProcess == ProcessType.etc && _formState.processTextController.text.isNotEmpty
          ? _formState.processTextController.text
          : null,
      roastingPoint: _formState.selectedRoasting,
      roastingPointText: _formState.selectedRoasting == RoastingPointType.etc && _formState.roastingPointTextController.text.isNotEmpty
          ? _formState.roastingPointTextController.text
          : null,
      method: _formState.selectedMethod,
      methodText: _formState.selectedMethod == MethodType.etc && _formState.methodTextController.text.isNotEmpty
          ? _formState.methodTextController.text
          : null,
      tastingNotes: _formState.tastingNotesTags.isNotEmpty ? _formState.tastingNotesTags : null,
    );

    await NoteService.instance.updateNote(updatedNote);
    
    // 상세 정보 섹션이 체크되어 있을 때만 detail 저장
    if (_showDetailSection) {
      if (_detail != null) {
        await DetailService.instance.updateDetail(updatedDetail);
      } else {
        await DetailService.instance.createDetail(updatedDetail);
      }
    } else if (_detail != null) {
      // 체크박스가 해제되었는데 기존 detail이 있으면 삭제 (선택사항)
      // 필요시 추가할 수 있음
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
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  _isEditing ? "노트 수정" : "노트 정보",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    if (_isEditing) {
                      _updateSubmit();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Text(_isEditing ? "저장" : "수정"),
                ),
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

                    // 상세정보 추가하기 토글 체크박스
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "상세정보 추가하기",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        Checkbox(
                          value: _showDetailSection,
                          onChanged: _isEditing ? (value) => setState(() => _showDetailSection = value ?? false) : null,
                          activeColor: AppColors.primaryDark,
                        ),
                      ],
                    ),

                    // 상세 정보 섹션 (토글 상태에 따라 노출)
                    if (_showDetailSection) ...[
                      const SizedBox(height: 20),
                      NoteDetailSection(
                        formState: _formState,
                        isEditing: _isEditing,
                        setState: () => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
