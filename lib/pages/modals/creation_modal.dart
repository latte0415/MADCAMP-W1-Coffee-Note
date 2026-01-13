import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/image_service.dart';
import '../../services/detail_service.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widget/popup_widget.dart';

class NoteCreatePopup extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  
  const NoteCreatePopup({super.key, this.prefillData});

  @override
  State<NoteCreatePopup> createState() => _NoteCreatePopupState();
}

class _NoteCreatePopupState extends State<NoteCreatePopup> {

  // 입력 데이터 저장을 위한 상태 변수
  final TextEditingController _cafeController = TextEditingController();
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0]
  );
  XFile? _selectedImage;

  // detail table 추가를 위한 controller 변수
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _tastingNotesController = TextEditingController();
  
  // ETC 선택 시 직접 입력을 위한 controller 변수
  final TextEditingController _processTextController = TextEditingController();
  final TextEditingController _roastingPointTextController = TextEditingController();
  final TextEditingController _methodTextController = TextEditingController();

  // detail table 입력 섹션 표시 상태 변수
  bool _showDetailSection = false;

  ProcessType _selectedProcess = ProcessType.washed;
  RoastingPointType _selectedRoasting = RoastingPointType.medium;
  MethodType _selectedMethod = MethodType.filter;

  double _acidity = 5;
  double _body = 5;
  double _bitterness = 5;
  int _score = 3;

  List<String> _tastingNotesTags = [];

  // 스케일 팩터 계산
  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / AppSpacing.designWidth;
    // 최소/최대 스케일 팩터 제한 (0.3 ~ 1.2)
    return scaleFactor.clamp(0.3, 1.2);
  }

  @override
  void initState() {
    super.initState();
    // prefillData가 있으면 필드 자동 채우기
    if (widget.prefillData != null) {
      _fillDetailFields(widget.prefillData!);
    }
  }

  /// 상세 정보 필드를 데이터로 채우는 메서드
  void _fillDetailFields(Map<String, dynamic> data) {
    // 상세정보 섹션 자동 활성화
    _showDetailSection = true;
    
    // 국가/지역
    if (data['originLocation'] != null) {
      _countryController.text = data['originLocation'] as String;
    }
    
    // 품종
    if (data['variety'] != null) {
      _varietyController.text = data['variety'] as String;
    }
    
    // 가공 방식
    if (data['process'] != null && data['process'] is ProcessType) {
      _selectedProcess = data['process'] as ProcessType;
      if (_selectedProcess == ProcessType.etc && data['processText'] != null) {
        _processTextController.text = data['processText'] as String;
      }
    }
    
    // 로스팅 포인트
    if (data['roastingPoint'] != null && data['roastingPoint'] is RoastingPointType) {
      _selectedRoasting = data['roastingPoint'] as RoastingPointType;
      if (_selectedRoasting == RoastingPointType.etc && data['roastingPointText'] != null) {
        _roastingPointTextController.text = data['roastingPointText'] as String;
      }
    }
    
    // 추출 방식
    if (data['method'] != null && data['method'] is MethodType) {
      _selectedMethod = data['method'] as MethodType;
      if (_selectedMethod == MethodType.etc && data['methodText'] != null) {
        _methodTextController.text = data['methodText'] as String;
      }
    }
    
    // 테이스팅 노트
    if (data['tastingNotes'] != null && data['tastingNotes'] is List) {
      final notes = (data['tastingNotes'] as List).cast<String>();
      _tastingNotesTags = notes;
      _tastingNotesController.text = notes.join(', ');
    }
  }

  @override
  void dispose() {
    _cafeController.dispose();
    _menuController.dispose();
    _commentController.dispose();
    _dateController.dispose();
    _countryController.dispose();
    _varietyController.dispose();
    _tastingNotesController.dispose();
    _processTextController.dispose();
    _roastingPointTextController.dispose();
    _methodTextController.dispose();
    super.dispose();
  }

  void _updateTastingNotes() {
    final text = _tastingNotesController.text;
    if (text.isEmpty) {
      setState(() => _tastingNotesTags = []);
      return;
    }

    // 쉼표 또는 띄어쓰기로 구분
    final tags = text.split(RegExp(r'[,，\s]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(5) // 최대 5개
        .toList();
    
    setState(() => _tastingNotesTags = tags);
  }

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

  void _handleTastingNotes(String value) {
    if (value.isEmpty) return;

    // 공백(' ')이나 쉼표(',')가 포함되었는지 확인
    if (value.endsWith(' ') || value.endsWith(',')) {
      final newTag = value.trim().replaceAll(',', ''); // 공백/쉼표 제거

      if (newTag.isNotEmpty && !_tastingNotesTags.contains(newTag)) {
        setState(() {
          if (_tastingNotesTags.length < 5) { // 최대 5개 제한
            _tastingNotesTags.add(newTag);
          }
          _tastingNotesController.clear(); // 입력창 비우기 (태그화 완료)
        });
      } else {
        _tastingNotesController.clear(); // 중복이거나 빈값이면 그냥 비움
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        // 상단바와 스크롤 영역을 하나의 Column으로 묶음
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
            // const Divider(height: 20),

            // --- [2. 스크롤 가능한 컨텐츠 영역] ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 이미지 추가 영역
                    _buildImageSection(scale),
                    const SizedBox(height: 20),

                    // 2. 기본 텍스트 입력창 (popup_widget.dart 함수 사용)
                    buildField("메뉴명", _menuController, true),
                    buildField("카페명", _cafeController, true),
                    buildField("날짜", _dateController, true),
                    const SizedBox(height: 25),

                    // 3. 수치 조절 슬라이더 (popup_widget.dart 함수 사용)
                    buildSlider(context, "산미", _acidity, (v) => setState(() => _acidity = v), true),
                    buildSlider(context, "바디", _body, (v) => setState(() => _body = v), true),
                    buildSlider(context, "쓴맛", _bitterness, (v) => setState(() => _bitterness = v), true),
                    const SizedBox(height: 20),

                    // 4. 한줄평 및 별점
                    buildField("한줄평", _commentController, true),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => IconButton(
                        onPressed: () => setState(() => _score = index + 1),
                        icon: Icon(
                          index < _score ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
                        ),
                      )),
                    ),
                    const SizedBox(height: 25),

                    // 5. 상세정보 추가하기 토글 체크박스
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "상세정보 추가하기",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        Checkbox(
                          value: _showDetailSection,
                          onChanged: (value) => setState(() => _showDetailSection = value ?? false),
                          activeColor: AppColors.primaryDark,
                        ),
                      ],
                    ),

                    // --- 6. 상세 정보 섹션 (토글 상태에 따라 노출) ---
                    if (_showDetailSection) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight, // 오른쪽 정렬 [cite: 1-1-0]
                        child: SizedBox(
                          width: 90,
                          height: 28,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              elevation: 0,
                              padding: EdgeInsets.zero, // 내부 여백 제거하여 텍스트에 딱 맞게 설정
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () { //AI 자동생성 로직 추가
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
                      const SizedBox(height: 20),

                      buildField("국가/지역", _countryController, true),
                      buildField("품종", _varietyController, true),
                      const SizedBox(height: 10),

                      buildDropdown<ProcessType>("가공방식", _selectedProcess, ProcessType.values, (v) => setState(() => _selectedProcess = v!), etcController: _processTextController,),
                      buildDropdown<RoastingPointType>("로스팅포인트", _selectedRoasting, RoastingPointType.values, (v) => setState(() => _selectedRoasting = v!), etcController: _roastingPointTextController,),
                      buildDropdown<MethodType>("추출방식", _selectedMethod, MethodType.values, (v) => setState(() => _selectedMethod = v!), etcController: _methodTextController,),

                      const SizedBox(height: 15),
                      buildField(
                          "테이스팅 노트",
                          _tastingNotesController,
                          true,
                          onChanged: _handleTastingNotes // 실시간 변환 로직 연결
                      ),
                      const SizedBox(height: 10),
                      if (_tastingNotesTags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tastingNotesTags.map((tag) => GestureDetector(
                            onTap: () => setState(() => _tastingNotesTags.remove(tag)), // 터치 시 삭제 기능
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark, // 어두운 배경
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                  "#$tag",
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                            ),
                          )).toList(),
                        ),
                      const SizedBox(height: 15),
                    ],

                    const SizedBox(height: 40),

                    // 7. 기록하기 버튼
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

  Widget _buildImageSection(double scale) {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        height: 300 * scale,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.border, width: AppSpacing.borderWidth * scale),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: Image.file(
                  File(_selectedImage!.path),
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

  void _submitNote() async {
    if (_cafeController.text.isEmpty || _menuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("카페와 메뉴를 입력해주세요!")),
      );
      return;
    }

    try {
      DateTime parsedDate = DateTime.parse(_dateController.text);
      final String noteId = const Uuid().v4();
      String? savedImagePath;

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
        image: savedImagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await NoteService.instance.createNote(newNote);

      if (_showDetailSection) {
        final newDetail = Detail(
          id: const Uuid().v4(),
          noteId: noteId,
          originLocation: _countryController.text.isEmpty ? null : _countryController.text,
          variety: _varietyController.text.isEmpty ? null : _varietyController.text,
          process: _selectedProcess,
          processText: _selectedProcess == ProcessType.etc && _processTextController.text.isNotEmpty
              ? _processTextController.text
              : null,
          roastingPoint: _selectedRoasting,
          roastingPointText: _selectedRoasting == RoastingPointType.etc && _roastingPointTextController.text.isNotEmpty
              ? _roastingPointTextController.text
              : null,
          method: _selectedMethod,
          methodText: _selectedMethod == MethodType.etc && _methodTextController.text.isNotEmpty
              ? _methodTextController.text
              : null,
          tastingNotes: _tastingNotesTags.isNotEmpty ? _tastingNotesTags : null,
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
