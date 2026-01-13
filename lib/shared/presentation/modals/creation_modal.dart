import 'package:flutter/material.dart';
import '../../../models/note.dart';
import '../../../services/note_service.dart';
import 'package:uuid/uuid.dart';
import '../../../services/image_service.dart';
import '../../../services/detail_service.dart';
import '../../../theme/app_colors.dart';
import '../../state/note_form_state.dart';
import '../widgets/note_form_widgets.dart';



class NoteCreatePopup extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  final DetailService detailService;
  
  const NoteCreatePopup({super.key, this.prefillData, required this.detailService});

  @override
  State<NoteCreatePopup> createState() => _NoteCreatePopupState();
}

class _NoteCreatePopupState extends State<NoteCreatePopup> {
  late NoteFormState _formState;
  bool _showDetailSection = false;

  @override
  void initState() {
    super.initState();
    _formState = NoteFormState.forCreation(prefillData: widget.prefillData);
    // prefillData가 있으면 상세정보 섹션 자동 활성화
    if (widget.prefillData != null) {
    _showDetailSection = true;
    }
  }

  @override
  void dispose() {
    _formState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _formState.getScaleFactor(context);

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
                  icon: const Icon(Icons.close, color: AppColors.primaryDark, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "기록하기",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 48), // 대칭을 위한 공간
              ],
            ),

            // --- [2. 스크롤 가능한 컨텐츠 영역] ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 이미지 추가 영역
                    NoteImageSection(
                      formState: _formState,
                      scale: scale,
                      enabled: true,
                      setState: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // 2. 기본 입력 필드
                    NoteBasicFieldsSection(
                      formState: _formState,
                      isEditing: true,
                      setState: () => setState(() {}),
                    ),
                    const SizedBox(height: 25),

                    // 3. 상세정보 추가하기 토글 체크박스 + 상세 정보 섹션
                    NoteDetailSectionWithToggle(
                      formState: _formState,
                      isEditing: true,
                      showDetailSection: _showDetailSection,
                      onToggleChanged: (value) => setState(() => _showDetailSection = value),
                      setState: () => setState(() {}),
                      showAiButton: true,
                    ),

                    const SizedBox(height: 40),

                    // 5. 기록하기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _submitNote,
                        child: const Text(
                          "기록하기",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _submitNote() async {
    if (_formState.cafeController.text.isEmpty || _formState.menuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("카페와 메뉴를 입력해주세요!")),
      );
      return;
    }

    try {
      DateTime parsedDate = DateTime.parse(_formState.dateController.text);
      final String noteId = const Uuid().v4();
      String? savedImagePath;

      if (_formState.selectedImage != null) {
        savedImagePath = await ImageService.instance.saveImage(_formState.selectedImage!, noteId);
      }

      final newNote = Note(
        id: noteId,
        location: _formState.cafeController.text,
        menu: _formState.menuController.text,
        comment: _formState.commentController.text,
        levelAcidity: _formState.acidity.toInt(),
        levelBody: _formState.body.toInt(),
        levelBitterness: _formState.bitterness.toInt(),
        score: _formState.score,
        drankAt: parsedDate,
        image: savedImagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await NoteService.instance.createNote(newNote);

      if (_showDetailSection) {
        final newDetail = _formState.createDetailFromForm(noteId);
        if (newDetail != null) {
          await widget.detailService.createDetail(newDetail);
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("날짜 형식이 올바르지 않거나 오류가 발생했습니다.")),
      );
      Navigator.pop(context, false);
    }
  }
}
