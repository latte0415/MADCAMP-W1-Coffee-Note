import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import '../../services/image_service.dart';

class NoteDetailsModal extends StatefulWidget {
  final Note note; // 클릭한 노트를 받아옵니다. [cite: 1-1-0]

  const NoteDetailsModal({super.key, required this.note});

  @override
  State<NoteDetailsModal> createState() => _NoteDetailsModalState();
}

class _NoteDetailsModalState extends State<NoteDetailsModal> {
  late TextEditingController _cafeController;
  late TextEditingController _menuController;
  late TextEditingController _commentController;
  late TextEditingController _dateController;

  bool _isEditing = false; // 수정 모드인지 확인하는 플래그 [cite: 1-1-0]
  String? _currentImagePath;
  late double _acidity, _body, _bitterness;
  late int _score;

  @override
  void initState() {
    super.initState();
    // 기존 데이터를 컨트롤러에 초기화 [cite: 1-1-0]
    _cafeController = TextEditingController(text: widget.note.location);
    _menuController = TextEditingController(text: widget.note.menu);
    _commentController = TextEditingController(text: widget.note.comment);
    _dateController = TextEditingController(text: widget.note.drankAt.toString().split(' ')[0]);
    _currentImagePath = widget.note.image;
    _acidity = widget.note.levelAcidity.toDouble();
    _body = widget.note.levelBody.toDouble();
    _bitterness = widget.note.levelBitterness.toDouble();
    _score = widget.note.score;
  }

  // 이미지 변경 로직
  Future<void> _changeImage() async {
    if (!_isEditing) return; // 수정 모드일 때만 작동 [cite: 1-1-0]
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

    await NoteService.instance.updateNote(updatedNote); // DB 업데이트 [cite: 1-1-0]
    if (mounted) Navigator.pop(context, true); // 성공 신호와 함께 닫기 [cite: 1-1-0]
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column( // 전체를 Column으로 유지
        mainAxisSize: MainAxisSize.min,
        children: [
            // --- [1. 고정 영역] 상단 바를 스크롤 밖으로 배치 ---
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
            const Divider(),
// --- [2. 스크롤 영역] 나머지 내용만 스크롤되도록 감싸기 ---
            Expanded( // 남은 공간을 차지하며 내부 스크롤 허용 [cite: 1-1-0]
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
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                        child: _currentImagePath != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _currentImagePath!.startsWith('/')
                              ? Image.file(File(_currentImagePath!), fit: BoxFit.cover) // 로컬 파일
                              : Image.file(File(_currentImagePath!), fit: BoxFit.cover), // 저장된 파일
                        )
                            : const Icon(Icons.coffee, size: 50, color: Colors.grey),
                      ),
                    ),
                    if(_isEditing) const Text("사진을 터치하여 변경", style: TextStyle(fontSize: 10, color: Colors.grey)),

                    // 입력 필드들 (readOnly 속성으로 제어) [cite: 1-1-0]
                    _buildField("카페", _cafeController),
                    _buildField("메뉴", _menuController),
                    _buildField("한줄평", _commentController),

                    const SizedBox(height: 20),
                    _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v)),
                    _buildSlider("바디", _body, (v) => setState(() => _body = v)),
                    _buildSlider("쓴맛", _bitterness, (v) => setState(() => _bitterness = v)),

                    // 별점 영역 (수정 모드일 때만 클릭 가능하게 처리) [cite: 1-1-0]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => IconButton(
                        onPressed: _isEditing ? () => setState(() => _score = index + 1) : null,
                        icon: Icon(index < _score ? Icons.star : Icons.star_border, color: Colors.amber),
                      )),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        ],
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
}