import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import 'package:uuid/uuid.dart';
import '../../../backend/providers.dart';
import '../../../theme/theme.dart';
import '../../state/note_form_state.dart';
import '../widgets/note_form_widgets.dart';



class NoteCreatePopup extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prefillData;
  
  const NoteCreatePopup({super.key, this.prefillData});

  @override
  ConsumerState<NoteCreatePopup> createState() => _NoteCreatePopupState();
}

class _NoteCreatePopupState extends ConsumerState<NoteCreatePopup> {
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

            // --- [2. 스크롤 가능한 컨텐츠 영역 + 버튼 영역] ---
            Expanded(
              child: Stack(
                children: [
                  // 스크롤 가능한 컨텐츠
                  SingleChildScrollView(
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

                        const SizedBox(height: 20),
                        // 버튼 높이 + 패딩만큼 여백 추가
                        const SizedBox(height: 75),
                      ],
                    ),
                  ),
                  
                  // 하단 그라데이션 오버레이 + 버튼
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 그라데이션 오버레이
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(1.0),
                              ],
                            ),
                          ),
                        ),
                        // 기록하기 버튼
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          color: Colors.white,
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFormValid() ? AppColors.primaryDark : Colors.grey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: _isFormValid() ? _submitNote : _showValidationError,
                              child: const Text(
                                "기록하기",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _submitNote() async {

    try {
      final noteService = ref.read(noteServiceProvider);
      final imageService = ref.read(imageServiceProvider);
      final detailService = ref.read(detailServiceProvider);
      
      DateTime parsedDate = DateTime.parse(_formState.dateController.text);
      final String noteId = const Uuid().v4();
      String? savedImagePath;

      if (_formState.selectedImage != null) {
        savedImagePath = await imageService.saveImage(_formState.selectedImage!, noteId);
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

      await noteService.createNote(newNote);

      if (_showDetailSection) {
        final newDetail = _formState.createDetailFromForm(noteId);
        if (newDetail != null) {
          await detailService.createDetail(newDetail);
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
