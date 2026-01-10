import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import 'package:uuid/uuid.dart';
// image 추가를 위한 import
import 'dart:io'; // image 추가
import 'package:image_picker/image_picker.dart';
import '../../services/image_service.dart';
// detail table 추가를 위한 import
import '../../services/detail_service.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';

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

  // detail table 추가를 위한 controller 변수
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();

  // detail table 입력 섹션 표시 상태 변수 (default: false)
  bool _showDetailSection = false;

  ProcessType _selectedProcess = ProcessType.washed;
  RoastingPointType _selectedRoasting = RoastingPointType.medium;
  MethodType _selectedMethod = MethodType.filter;

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          // 화면의 85%까지만 커지도록 제한
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 중요: 자식들 크기만큼만 차지
          children: [
            // --- [고정 영역] 상단 바 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("뒤로 가기", style: TextStyle(color: Colors.grey)),
                ),
                const Text("새 노트 작성",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 60),
              ],
            ),
            const Divider(),

            // --- [스크롤 영역] 핵심 수정 포인트 ---
            // Expanded가 있어야 Column 내에서 남은 공간을 SingleChildScrollView가 차지할 수 있습니다.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // 이미지 선택 영역 UI
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

                    // 슬라이더 섹션
                    _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v)),
                    _buildSlider("바디", _body, (v) => setState(() => _body = v)),
                    _buildSlider("쓴맛", _bitterness, (v) => setState(() => _bitterness = v)),

                    const SizedBox(height: 20),

                    // 별점 섹션
                    const Text("점수", style: TextStyle(fontSize: 14, color: Colors.grey)),
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

                    // 상세 정보 입력 섹션 (Switch)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("상세 정보 (선택)",
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        Switch(
                          value: _showDetailSection,
                          onChanged: (value) => setState(() => _showDetailSection = value),
                        ),
                      ],
                    ),

                    if (_showDetailSection) ...[
                      _buildTextField("원산지 (국가)", _countryController),
                      _buildTextField("품종", _varietyController),
                      const SizedBox(height: 15),
                      _buildDropdown<ProcessType>(
                          "가공 방식", _selectedProcess, ProcessType.values,
                              (v) => setState(() => _selectedProcess = v!)
                      ),
                      _buildDropdown<RoastingPointType>(
                          "로스팅 포인트", _selectedRoasting, RoastingPointType.values,
                              (v) => setState(() => _selectedRoasting = v!)
                      ),
                      _buildDropdown<MethodType>(
                          "추출 방식", _selectedMethod, MethodType.values,
                              (v) => setState(() => _selectedMethod = v!)
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Note 등록하기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitNote,
                        child: const Text("Note 등록하기",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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


  // 드롭다운 빌더
  Widget _buildDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((item) {
          // [수정] Enum의 displayName을 사용하여 한글로 표시
          String text = "";
          if (item is ProcessType) {
            text = item.displayName;
          } else if (item is RoastingPointType) {
            text = item.displayName;
          } else if (item is MethodType) {
            text = item.displayName;
          } else {
            text = item.toString().split('.').last;
          }

          return DropdownMenuItem(
            value: item,
            child: Text(text, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // submit 로직
  void _submitNote() async {
    if (_cafeController.text.isEmpty || _menuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("카페와 메뉴를 입력해주세요!")));
      return;
    }

    try {
      DateTime parsedDate = DateTime.parse(_dateController.text);
      final String noteId = const Uuid().v4(); // [수정] ID를 먼저 생성 (파일 이름용)
      String? savedImagePath;

      // 이미지가 선택되었다면 물리적 경로에 저장
      if (_selectedImage != null) {
        savedImagePath = await ImageService.instance.saveImage(_selectedImage!, noteId);
      }

      // 1. Note 생성
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
        image: savedImagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Note -> DB 저장
      await NoteService.instance.createNote(newNote);

      // 스위치가 켜져 있을 때만 상세 정보 저장 실행
      if (_showDetailSection) {
        final newDetail = Detail(
          id: const Uuid().v4(),
          noteId: noteId,
          originCountry: _countryController.text,
          variety: _varietyController.text,
          process: _selectedProcess,
          roastingPoint: _selectedRoasting,
          method: _selectedMethod,
        );
        await DetailService.instance.createDetail(newDetail);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("날짜 형식이 올바르지 않거나 오류가 발생했습니다.")),
      );
    }
  }
}

