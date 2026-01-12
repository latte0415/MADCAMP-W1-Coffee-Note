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
import 'dart:convert';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

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

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50 * scale),
            topRight: Radius.circular(50 * scale),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 49 * scale, vertical: 20 * scale),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryDark, size: 30 * scale),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "상세 정보",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * scale),
                ],
              ),
            ),
            Divider(height: 1 * scale),
            
            // 스크롤 가능한 컨텐츠
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 49 * scale, vertical: 20 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 추가하기
                    _buildImageSection(scale),
                    SizedBox(height: 30 * scale),
                    
                    // 텍스트 입력창
                    _buildTextField("메뉴명", "메뉴명을 입력하세요.", _menuController, scale),
                    SizedBox(height: 20 * scale),
                    _buildTextField("카페명", "카페명을 입력하세요.", _cafeController, scale),
                    SizedBox(height: 20 * scale),
                    _buildTextField("날짜명", "날짜를 입력하세요.", _dateController, scale),
                    SizedBox(height: 20 * scale),
                    _buildTextField("한줄평", "한줄평을 입력하세요.", _commentController, scale),
                    SizedBox(height: 30 * scale),
                    
                    // 슬라이더
                    _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v), scale),
                    SizedBox(height: 20 * scale),
                    _buildSlider("바디", _body, (v) => setState(() => _body = v), scale),
                    SizedBox(height: 20 * scale),
                    _buildSlider("쓴맛", _bitterness, (v) => setState(() => _bitterness = v), scale),
                    SizedBox(height: 30 * scale),
                    
                    // 별점
                    _buildStarRating(scale),
                    SizedBox(height: 30 * scale),
                    
                    // 상세정보 추가하기 체크박스
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "상세정보 추가하기",
                          style: TextStyle(
                            fontSize: 30 * scale,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                        Checkbox(
                          value: _showDetailSection,
                          onChanged: (value) => setState(() => _showDetailSection = value ?? false),
                          activeColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),
                    
                    // 상세 정보 섹션
                    if (_showDetailSection) ...[
                      // AI 자동생성 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 70 * scale,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20 * scale),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("NotImplemented")),
                            );
                          },
                          child: Text(
                            "AI 자동생성",
                            style: TextStyle(
                              fontSize: 30 * scale,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      
                      // 국가/지역, 품종
                      _buildTextField("국가/지역", "국가/지역을 입력하세요.", _countryController, scale),
                      SizedBox(height: 20 * scale),
                      _buildTextField("품종", "품종을 입력하세요.", _varietyController, scale),
                      SizedBox(height: 20 * scale),
                      
                      // 드롭다운 + 텍스트 입력
                      _buildDropdownWithText<ProcessType>(
                        "가공방식",
                        _selectedProcess,
                        ProcessType.values,
                        _processTextController,
                        (v) => setState(() {
                          _selectedProcess = v!;
                          if (v != ProcessType.etc) {
                            _processTextController.clear();
                          }
                        }),
                        scale,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildDropdownWithText<RoastingPointType>(
                        "로스팅포인트",
                        _selectedRoasting,
                        RoastingPointType.values,
                        _roastingPointTextController,
                        (v) => setState(() {
                          _selectedRoasting = v!;
                          if (v != RoastingPointType.etc) {
                            _roastingPointTextController.clear();
                          }
                        }),
                        scale,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildDropdownWithText<MethodType>(
                        "추출방식",
                        _selectedMethod,
                        MethodType.values,
                        _methodTextController,
                        (v) => setState(() {
                          _selectedMethod = v!;
                          if (v != MethodType.etc) {
                            _methodTextController.clear();
                          }
                        }),
                        scale,
                      ),
                      SizedBox(height: 20 * scale),
                      
                      // 테이스팅 노트
                      _buildTextField(
                        "테이스팅 노트",
                        "테이스팅 노트를 입력하세요 (쉼표 또는 띄어쓰기로 구분, 최대 5개)",
                        _tastingNotesController,
                        scale,
                        onChanged: (_) => _updateTastingNotes(),
                      ),
                      SizedBox(height: 15 * scale),
                      // 해시태그 표시
                      if (_tastingNotesTags.isNotEmpty)
                        Wrap(
                          spacing: 10 * scale,
                          runSpacing: 10 * scale,
                          children: _tastingNotesTags.map((tag) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(20 * scale),
                            ),
                            child: Text(
                              "#$tag",
                              style: TextStyle(
                                fontSize: 30 * scale,
                                fontWeight: FontWeight.w400,
                                color: AppColors.background,
                                letterSpacing: 0.1,
                              ),
                            ),
                          )).toList(),
                        ),
                      SizedBox(height: 30 * scale),
                    ],
                    
                    SizedBox(height: 30 * scale),
                    
                    // 기록하기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 131 * scale,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50 * scale),
                          ),
                        ),
                        onPressed: _submitNote,
                        child: Text(
                          "기록하기",
                          style: TextStyle(
                            fontSize: 50 * scale,
                            fontWeight: FontWeight.w400,
                            color: AppColors.background,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
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

  Widget _buildTextField(String label, String hint, TextEditingController controller, double scale, {ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 10 * scale),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
            letterSpacing: 0.1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 30 * scale,
              color: Colors.grey[400],
              letterSpacing: 0.1,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.border, width: AppSpacing.borderWidth * scale),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.border, width: AppSpacing.borderWidth * scale),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.primaryDark, width: AppSpacing.borderWidth * scale),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 15 * scale),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 30 * scale,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryDark,
                letterSpacing: 0.1,
              ),
            ),
            Text(
              "${value.toInt()}",
              style: TextStyle(
                fontSize: 30 * scale,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryDark,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.primaryDark,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStarRating(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "별점",
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 10 * scale),
        Row(
          children: List.generate(5, (index) => IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              index < _score ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 50 * scale,
            ),
            onPressed: () => setState(() => _score = index + 1),
          )),
        ),
      ],
    );
  }

  Widget _buildDropdownWithText<T>(
    String label,
    T value,
    List<T> items,
    TextEditingController textController,
    ValueChanged<T?> onChanged,
    double scale,
  ) {
    bool isEtc = false;
    if (value is ProcessType && value == ProcessType.etc) {
      isEtc = true;
    } else if (value is RoastingPointType && value == RoastingPointType.etc) {
      isEtc = true;
    } else if (value is MethodType && value == MethodType.etc) {
      isEtc = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 10 * scale),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.border, width: AppSpacing.borderWidth * scale),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.border, width: AppSpacing.borderWidth * scale),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: AppColors.primaryDark, width: AppSpacing.borderWidth * scale),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 15 * scale),
          ),
          style: TextStyle(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
            letterSpacing: 0.1,
          ),
          items: items.map((item) {
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
              child: Text(text),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        if (isEtc) ...[
          SizedBox(height: 15 * scale),
          _buildTextField("$label 직접 입력", "$label을 직접 입력하세요.", textController, scale),
        ],
      ],
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
        List<String>? tastingNotes = _tastingNotesTags.isNotEmpty ? _tastingNotesTags : null;
        
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
          tastingNotes: tastingNotes,
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
