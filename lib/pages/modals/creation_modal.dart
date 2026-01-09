import 'package:flutter/material.dart';
import '../../models/note.dart';        // Note 모델 파일 경로
import '../../services/note_service.dart'; // NoteService 파일 경로
import 'package:uuid/uuid.dart';
import 'dart:io'; // image 추가
import 'package:image_picker/image_picker.dart'; // image 추가
import '../../services/image_service.dart'; // image 추가

class NoteCreatePopup extends StatefulWidget {
  const NoteCreatePopup({super.key});

  @override
  State<NoteCreatePopup> createState() => _NoteCreatePopupState();
}

class _NoteCreatePopupState extends State<NoteCreatePopup> {
  // 입력 데이터 저장을 위한 상태 변수
  final TextEditingController _cafeController = TextEditingController();
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0] // "2026-01-09" 형식
  );
  XFile? _selectedImage; // image 변수

  double _acidity = 5;
  double _body = 5;
  double _bitterness = 5;
  int _score = 3;
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                final img = await ImageService.instance.pickImage(ImageSource.gallery);
                if (img != null) setState(() => _selectedImage = img);
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                final img = await ImageService.instance.pickImage(ImageSource.camera);
                if (img != null) setState(() => _selectedImage = img);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 키보드 높이만큼 하단에 여백을 줌
      padding: EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단: 뒤로 가기 버튼 (액션바 형식)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        "뒤로 가기", style: TextStyle(color: Colors.grey)),
                  ),
                  const Text("새 노트 작성", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 60), // 대칭을 위한 공간
                ],
              ),
              const Divider(),

              // [추가] 이미지 선택 영역 UI
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("커피 사진", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                      Text("사진 추가하기", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 텍스트 입력창 섹션
              _buildTextField("카페 이름", _cafeController),
              _buildTextField("날짜 (예: 2026-01-09)", _dateController),
              _buildTextField("메뉴명", _menuController),
              _buildTextField("한줄평", _commentController),

              const SizedBox(height: 20),

              // 슬라이더 섹션 (산미, 바디, 쓰기)
              _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v)),
              _buildSlider("바디", _body, (v) => setState(() => _body = v)),
              _buildSlider(
                  "쓴맛", _bitterness, (v) => setState(() => _bitterness = v)),

              const SizedBox(height: 20),

              // 별점 섹션
              const Text(
                  "점수", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) =>
                    IconButton(
                      onPressed: () => setState(() => _score = index + 1),
                      icon: Icon(
                        index < _score ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 30,
                      ),
                    )),
              ),

              const SizedBox(height: 30),

              // 생성하기 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitNote,
                  child: const Text("Note 등록하기", style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 빌더
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(fontSize: 13)),
    );
  }

  // 슬라이더 빌더 (1~10 int)
  Widget _buildSlider(String label, double value,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text("${value.toInt()}")],
        ),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Theme
              .of(context)
              .primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // [수정] 생성 로직: ImageService 연동
  void _submitNote() async {
    if (_cafeController.text.isEmpty || _menuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("카페와 메뉴를 입력해주세요!")));
      return;
    }

    try {
      DateTime parsedDate = DateTime.parse(_dateController.text);
      final String noteId = const Uuid().v4(); // [수정] ID를 먼저 생성 (파일 이름용)
      String? savedImagePath;

      // [추가] 이미지가 선택되었다면 물리적 경로에 저장
      if (_selectedImage != null) {
        savedImagePath = await ImageService.instance.saveImage(_selectedImage!, noteId);
      }

      final newNote = Note(
        id: noteId,
        location: _cafeController.text,
        menu: _menuController.text,
        comment: _commentController.text,
        levelAcidity: _acidity.toInt(),
        levelBody: _body.toInt(),
        levelBitterness: _bitterness.toInt(),
        score: _score,
        drankAt: parsedDate,
        image: savedImagePath, // [추가] 저장된 경로 DB 필드에 할당
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await NoteService.instance.createNote(newNote);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("날짜 형식이 올바르지 않거나 오류가 발생했습니다.")),
      );
    }
  }
}