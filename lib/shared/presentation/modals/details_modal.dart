import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/note.dart';
import '../../../services/note_service.dart';
import '../../../services/image_service.dart';
import 'package:uuid/uuid.dart';
// detail table 관련 import
import '../../../models/detail.dart';
import '../../../services/detail_service.dart';
import '../../../models/enums/process_type.dart';
import '../../../models/enums/roasting_point_type.dart';
import '../../../models/enums/method_type.dart';
// theme 관련 import
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_component_styles.dart';
import '../widgets/popup_widget.dart';

class NoteDetailsModal extends StatefulWidget {
  final Note note; // 클릭한 노트를 받아옵니다.

  const NoteDetailsModal({super.key, required this.note});

  @override
  State<NoteDetailsModal> createState() => _NoteDetailsModalState();
}

class _NoteDetailsModalState extends State<NoteDetailsModal> {
  late TextEditingController _cafeController;
  late TextEditingController _menuController;
  late TextEditingController _commentController;
  late TextEditingController _dateController;

  // detail 용 controller
  late TextEditingController _countryController;
  late TextEditingController _varietyController;
  late TextEditingController _tastingNotesController;
  List<String> _tastingNotesTags = [];
  Detail? _detail;

  ProcessType _selectedProcess = ProcessType.washed;
  RoastingPointType _selectedRoasting = RoastingPointType.medium;
  MethodType _selectedMethod = MethodType.filter;

  // ETC 선택 시 직접 입력을 위한 controller 변수
  final TextEditingController _processTextController = TextEditingController();
  final TextEditingController _roastingPointTextController = TextEditingController();
  final TextEditingController _methodTextController = TextEditingController();

  bool _isEditing = false; // 수정 모드인지 확인하는 플래그
  String? _currentImagePath;
  late double _acidity, _body, _bitterness;
  late int _score;

  @override
  void initState() {
    super.initState();
    // 기존 데이터를 컨트롤러에 초기화
    _cafeController = TextEditingController(text: widget.note.location);
    _menuController = TextEditingController(text: widget.note.menu);
    _commentController = TextEditingController(text: widget.note.comment);
    _dateController = TextEditingController(text: widget.note.drankAt.toString().split(' ')[0]);
    // detail 컨트롤러 초기화
    _countryController = TextEditingController();
    _varietyController = TextEditingController();
    _tastingNotesController = TextEditingController();

    _currentImagePath = widget.note.image;
    _acidity = widget.note.levelAcidity.toDouble();
    _body = widget.note.levelBody.toDouble();
    _bitterness = widget.note.levelBitterness.toDouble();
    _score = widget.note.score;

    _loadDetailData();
  }

  // detail table load 함수
  Future<void> _loadDetailData() async {
    final detail = await DetailService.instance.getDetailByNoteId(widget.note.id);
    if (detail != null && mounted) {
      setState(() {
        _detail = detail;
        _countryController.text = detail.originLocation ?? "";
        _varietyController.text = detail.variety ?? "";

        // 1. Enum 값들 설정
        _selectedProcess = detail.process ?? ProcessType.washed;
        _selectedRoasting = detail.roastingPoint ?? RoastingPointType.medium;
        _selectedMethod = detail.method ?? MethodType.filter;

        // 2. [추가] 직접 입력했던 텍스트들을 각 컨트롤러에 넣어줌
        // 이 로직이 있어야 '기타'를 눌렀을 때 이전에 썼던 글이 나타납니다.
        _processTextController.text = detail.processText ?? "";
        _roastingPointTextController.text = detail.roastingPointText ?? "";
        _methodTextController.text = detail.methodText ?? "";

        // _selectedProcess = detail.process ?? ProcessType.washed;
        // _selectedRoasting = detail.roastingPoint ?? RoastingPointType.medium;
        // _selectedMethod = detail.method ?? MethodType.filter;
        _tastingNotesTags = detail.tastingNotes ?? [];
      });
    }
  }

  // 이미지 변경 로직
  Future<void> _changeImage() async {
    if (!_isEditing) return; // 수정 모드일 때만 작동
    final img = await ImageService.instance.pickImage(ImageSource.gallery);
    if (img != null) {
      // 기존 이미지는 일단 두고, 저장 시점에 처리하거나 경로만 업데이트
      setState(() => _currentImagePath = img.path);
    }
  }

  // 업데이트 로직
  Future<void> _updateSubmit() async {
    final updatedNote = Note(
      id: widget.note.id,
      location: _cafeController.text,
      menu: _menuController.text,
      comment: _commentController.text,
      levelAcidity: _acidity.toInt(),
      levelBody: _body.toInt(),
      levelBitterness: _bitterness.toInt(),
      score: _score,
      drankAt: DateTime.parse(_dateController.text),
      image: _currentImagePath,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
    );

    final updatedDetail = Detail(
      id: _detail?.id ?? const Uuid().v4(), // 기존게 없으면 새로 생성
      noteId: widget.note.id,
      originLocation: _countryController.text.isEmpty ? null : _countryController.text,
      variety: _varietyController.text.isEmpty ? null : _varietyController.text,
      // process: _selectedProcess,
      // roastingPoint: _selectedRoasting,
      // method: _selectedMethod,
      process: _selectedProcess,
      processText: _selectedProcess == ProcessType.etc ? _processTextController.text : null,
      roastingPoint: _selectedRoasting,
      roastingPointText: _selectedRoasting == RoastingPointType.etc ? _roastingPointTextController.text : null,
      method: _selectedMethod,
      methodText: _selectedMethod == MethodType.etc ? _methodTextController.text : null,
      tastingNotes: _tastingNotesTags.isNotEmpty ? _tastingNotesTags : null,
    );

    await NoteService.instance.updateNote(updatedNote); // Note DB 업데이트
    // Detail DB: 기존 정보가 있거나 수정 모드에서 입력했다면 DB 업데이트
    if (_detail != null) {
      await DetailService.instance.updateDetail(updatedDetail);
    } else {
      await DetailService.instance.createDetail(updatedDetail);
    }

    if (mounted) Navigator.pop(context, true); // 성공 신호와 함께 닫기
  }

  void _handleTastingNotes(String value) {
    if (value.endsWith(' ') || value.endsWith(',')) {
      final newTag = value.trim().replaceAll(',', '');
      if (newTag.isNotEmpty && _tastingNotesTags.length < 5 && !_tastingNotesTags.contains(newTag)) {
        setState(() => _tastingNotesTags.add(newTag));
        _tastingNotesController.clear();
      } else {
        _tastingNotesController.clear();
      }
    }
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
        child: Column( // Column 시작
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- [1. 고정 영역] 상단 바 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.primaryDark, size: 16),
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
                    GestureDetector(
                      onTap: _changeImage,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _currentImagePath != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_currentImagePath!), fit: BoxFit.cover),
                        )
                            : const Icon(Icons.coffee, size: 50, color: Colors.grey),
                      ),
                    ),
                    if (_isEditing)
                      const Text("사진을 터치하여 변경", style: TextStyle(fontSize: 16, color: Colors.grey)),

                    // 기본 입력 필드들
                    const SizedBox(height: 20),
                    buildField("메뉴명", _menuController, _isEditing),
                    buildField("카페명", _cafeController, _isEditing),
                    buildField("날짜", _dateController, _isEditing),

                    const SizedBox(height: 20),
                    buildSlider(context, "산미", _acidity, (v) => setState(() => _acidity = v), _isEditing),
                    buildSlider(context, "바디", _body, (v) => setState(() => _body = v), _isEditing),
                    buildSlider(context, "쓴맛", _bitterness, (v) => setState(() => _bitterness = v), _isEditing),

                    const SizedBox(height: 20),
                    buildField("한줄평", _commentController, _isEditing),

                    // 별점 영역
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => IconButton(
                        onPressed: _isEditing ? () => setState(() => _score = index + 1) : null,
                        icon: Icon(index < _score ? Icons.star : Icons.star_border, color: Colors.amber),
                      )),
                    ),
                    const SizedBox(height: 20),

                    // 상세 정보 섹션
                    const SizedBox(height: 20),
                    if (_isEditing || _detail != null) ...[
                      // 국가/품종 필드
                      buildField("국가/지역", _countryController, _isEditing),
                      buildField("품종", _varietyController, _isEditing),

                      const SizedBox(height: 10),

                      // 수정 모드 여부에 따른 가공/로스팅/추출 방식 표시 로직
                      if (_isEditing) ...[
                        buildDropdown<ProcessType>("가공방식", _selectedProcess, ProcessType.values, (v) => setState(() => _selectedProcess = v!), etcController: _processTextController,),
                        buildDropdown<RoastingPointType>("로스팅포인트", _selectedRoasting, RoastingPointType.values, (v) => setState(() => _selectedRoasting = v!), etcController: _roastingPointTextController,),
                        buildDropdown<MethodType>("추출방식", _selectedMethod, MethodType.values, (v) => setState(() => _selectedMethod = v!), etcController: _methodTextController,),
                        buildField("테이스팅 노트", _tastingNotesController, true, onChanged: _handleTastingNotes),
                      ] else ...[
                        buildReadOnlyDetail(
                            "가공 방식",
                            _selectedProcess == ProcessType.etc
                                ? _processTextController.text // '직접입력'일 땐 직접 입력한 텍스트
                                : _selectedProcess.displayName,
                        ),
                        buildReadOnlyDetail(
                          "로스팅",
                          _selectedRoasting == RoastingPointType.etc
                              ? _roastingPointTextController.text // '직접입력'일 땐 직접 입력한 텍스트
                              : _selectedRoasting.displayName,
                        ),
                        buildReadOnlyDetail(
                          "추출 방식",
                          _selectedMethod == MethodType.etc
                              ? _methodTextController.text // '직접입력'일 땐 직접 입력한 텍스트
                              : _selectedMethod.displayName,
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("테이스팅 노트", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (_tastingNotesTags.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tastingNotesTags.map((tag) => GestureDetector(
                              onTap: _isEditing ? () => setState(() => _tastingNotesTags.remove(tag)) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text("#$tag", style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )).toList(),
                          ),
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