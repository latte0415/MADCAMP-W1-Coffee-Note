import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import '../../services/image_service.dart';
import 'package:uuid/uuid.dart';
// detail table 관련 import
import '../../models/detail.dart';
import '../../services/detail_service.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';

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
  Detail? _detail;

  ProcessType _selectedProcess = ProcessType.washed;
  RoastingPointType _selectedRoasting = RoastingPointType.medium;
  MethodType _selectedMethod = MethodType.filter;

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
        _selectedProcess = detail.process ?? ProcessType.washed;
        _selectedRoasting = detail.roastingPoint ?? RoastingPointType.medium;
        _selectedMethod = detail.method ?? MethodType.filter;
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
      process: _selectedProcess,
      roastingPoint: _selectedRoasting,
      method: _selectedMethod,
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
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column( // Column 시작
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- [1. 고정 영역] 상단 바 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
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
                        height: 200,
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
                      const Text("사진을 터치하여 변경", style: TextStyle(fontSize: 10, color: Colors.grey)),

                    // 기본 입력 필드들
                    _buildField("카페", _cafeController),
                    _buildField("메뉴", _menuController),
                    _buildField("한줄평", _commentController),
                    _buildField("날짜", _dateController),

                    const SizedBox(height: 20),
                    _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v)),
                    _buildSlider("바디", _body, (v) => setState(() => _body = v)),
                    _buildSlider("쓴맛", _bitterness, (v) => setState(() => _bitterness = v)),

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
                    if (_isEditing || _detail != null) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("상세 정보", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      _buildField("원산지", _countryController),
                      _buildField("품종", _varietyController),

                      const SizedBox(height: 10),
                      if (_isEditing) ...[
                        buildDropdown<ProcessType>("가공 방식", _selectedProcess, ProcessType.values, (v) => setState(() => _selectedProcess = v!)),
                        buildDropdown<RoastingPointType>("로스팅 포인트", _selectedRoasting, RoastingPointType.values, (v) => setState(() => _selectedRoasting = v!)),
                        buildDropdown<MethodType>("추출 방식", _selectedMethod, MethodType.values, (v) => setState(() => _selectedMethod = v!)),
                        buildField("테이스팅 노트", _tastingNotesController, true, onChanged: _handleTastingNotes),
                      ] else ...[
                        buildReadOnlyDetail("가공 방식", _selectedProcess.displayName),
                        buildReadOnlyDetail("로스팅", _selectedRoasting.displayName),
                        buildReadOnlyDetail("추출 방식", _selectedMethod.displayName),
                        const SizedBox(height: 15),
                        const Align(
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

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: !_isEditing, // [중요] 수정 모드가 아니면 읽기 전용 [cite: 1-1-0]
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text("${value.toInt()}")]),
        Slider(
          value: value, min: 1, max: 10, divisions: 9,
          onChanged: _isEditing ? onChanged : null, // [중요] 수정 모드가 아니면 비활성화 [cite: 1-1-0]
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          String text = "";
          if (item is ProcessType) { text = item.displayName; }
          else if (item is RoastingPointType) { text = item.displayName; }
          else if (item is MethodType) { text = item.displayName; }
          return DropdownMenuItem(value: item, child: Text(text));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // 조회 모드일 때 상세 정보를 한 줄로 보여주는 위젯
  Widget _buildReadOnlyDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // 라벨 (예: 가공 방식:)
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          // 실제 값 (예: 워시드)
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}