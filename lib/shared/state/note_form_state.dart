import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
import '../../backend/providers.dart';
import '../../theme/theme.dart';

/// Note 생성/수정 폼의 공통 상태 관리 클래스
/// Creation과 Details modal이 공유하는 상태 변수와 메서드를 관리
class NoteFormState {
  // Controllers
  final TextEditingController cafeController;
  final TextEditingController menuController;
  final TextEditingController commentController;
  final TextEditingController dateController;
  final TextEditingController countryController;
  final TextEditingController varietyController;
  final TextEditingController tastingNotesController;
  final TextEditingController processTextController;
  final TextEditingController roastingPointTextController;
  final TextEditingController methodTextController;

  // State variables (mutable)
  XFile? selectedImage; // 새로 선택한 이미지
  String? existingImagePath; // 기존 이미지 경로 (Details용)
  ProcessType selectedProcess;
  RoastingPointType selectedRoasting;
  MethodType selectedMethod;
  double acidity;
  double body;
  double bitterness;
  int score;
  List<String> tastingNotesTags;

  /// 내부 생성자
  NoteFormState._({
    required this.cafeController,
    required this.menuController,
    required this.commentController,
    required this.dateController,
    required this.countryController,
    required this.varietyController,
    required this.tastingNotesController,
    required this.processTextController,
    required this.roastingPointTextController,
    required this.methodTextController,
    this.selectedImage,
    this.existingImagePath,
    required this.selectedProcess,
    required this.selectedRoasting,
    required this.selectedMethod,
    required this.acidity,
    required this.body,
    required this.bitterness,
    required this.score,
    required this.tastingNotesTags,
  });

  /// Creation modal용 factory 생성자
  factory NoteFormState.forCreation({Map<String, dynamic>? prefillData}) {
    final cafeController = TextEditingController();
    final menuController = TextEditingController();
    final commentController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final countryController = TextEditingController();
    final varietyController = TextEditingController();
    final tastingNotesController = TextEditingController();
    final processTextController = TextEditingController();
    final roastingPointTextController = TextEditingController();
    final methodTextController = TextEditingController();

    ProcessType selectedProcess = ProcessType.etc;
    RoastingPointType selectedRoasting = RoastingPointType.etc;
    MethodType selectedMethod = MethodType.etc;
    List<String> tastingNotesTags = [];

    // prefillData가 있으면 필드 자동 채우기
    if (prefillData != null) {
      if (prefillData['originLocation'] != null) {
        countryController.text = prefillData['originLocation'] as String;
      }
      if (prefillData['variety'] != null) {
        varietyController.text = prefillData['variety'] as String;
      }
      if (prefillData['process'] != null && prefillData['process'] is ProcessType) {
        selectedProcess = prefillData['process'] as ProcessType;
        if (selectedProcess == ProcessType.etc && prefillData['processText'] != null) {
          processTextController.text = prefillData['processText'] as String;
        }
      }
      if (prefillData['roastingPoint'] != null && prefillData['roastingPoint'] is RoastingPointType) {
        selectedRoasting = prefillData['roastingPoint'] as RoastingPointType;
        if (selectedRoasting == RoastingPointType.etc && prefillData['roastingPointText'] != null) {
          roastingPointTextController.text = prefillData['roastingPointText'] as String;
        }
      }
      if (prefillData['method'] != null && prefillData['method'] is MethodType) {
        selectedMethod = prefillData['method'] as MethodType;
        if (selectedMethod == MethodType.etc && prefillData['methodText'] != null) {
          methodTextController.text = prefillData['methodText'] as String;
        }
      }
      if (prefillData['tastingNotes'] != null && prefillData['tastingNotes'] is List) {
        final notes = (prefillData['tastingNotes'] as List).cast<String>();
        tastingNotesTags = notes;
        tastingNotesController.text = notes.join(', ');
      }
    }

    return NoteFormState._(
      cafeController: cafeController,
      menuController: menuController,
      commentController: commentController,
      dateController: dateController,
      countryController: countryController,
      varietyController: varietyController,
      tastingNotesController: tastingNotesController,
      processTextController: processTextController,
      roastingPointTextController: roastingPointTextController,
      methodTextController: methodTextController,
      selectedProcess: selectedProcess,
      selectedRoasting: selectedRoasting,
      selectedMethod: selectedMethod,
      acidity: 5.0,
      body: 5.0,
      bitterness: 5.0,
      score: 3,
      tastingNotesTags: tastingNotesTags,
    );
  }

  /// Details modal용 factory 생성자
  factory NoteFormState.forDetails(Note note, Detail? detail) {
    final cafeController = TextEditingController(text: note.location);
    final menuController = TextEditingController(text: note.menu);
    final commentController = TextEditingController(text: note.comment);
    final dateController = TextEditingController(text: note.drankAt.toString().split(' ')[0]);
    final countryController = TextEditingController(text: detail?.originLocation ?? '');
    final varietyController = TextEditingController(text: detail?.variety ?? '');
    final tastingNotesController = TextEditingController();
    final processTextController = TextEditingController(text: detail?.processText ?? '');
    final roastingPointTextController = TextEditingController(text: detail?.roastingPointText ?? '');
    final methodTextController = TextEditingController(text: detail?.methodText ?? '');

    final tastingNotesTags = detail?.tastingNotes ?? [];
    if (tastingNotesTags.isNotEmpty) {
      tastingNotesController.text = tastingNotesTags.join(', ');
    }

    return NoteFormState._(
      cafeController: cafeController,
      menuController: menuController,
      commentController: commentController,
      dateController: dateController,
      countryController: countryController,
      varietyController: varietyController,
      tastingNotesController: tastingNotesController,
      processTextController: processTextController,
      roastingPointTextController: roastingPointTextController,
      methodTextController: methodTextController,
      existingImagePath: note.image,
      selectedProcess: detail?.process ?? ProcessType.etc,
      selectedRoasting: detail?.roastingPoint ?? RoastingPointType.etc,
      selectedMethod: detail?.method ?? MethodType.etc,
      acidity: note.levelAcidity.toDouble(),
      body: note.levelBody.toDouble(),
      bitterness: note.levelBitterness.toDouble(),
      score: note.score,
      tastingNotesTags: List<String>.from(tastingNotesTags),
    );
  }

  /// 모든 컨트롤러 해제
  void dispose() {
    cafeController.dispose();
    menuController.dispose();
    commentController.dispose();
    dateController.dispose();
    countryController.dispose();
    varietyController.dispose();
    tastingNotesController.dispose();
    processTextController.dispose();
    roastingPointTextController.dispose();
    methodTextController.dispose();
  }

  /// 테이스팅 노트 입력 핸들러
  void handleTastingNotes(String value, VoidCallback setState) {
    if (value.isEmpty) return;

    // 공백(' ')이나 쉼표(',')가 포함되었는지 확인
    if (value.endsWith(' ') || value.endsWith(',')) {
      final newTag = value.trim().replaceAll(',', ''); // 공백/쉼표 제거

      if (newTag.isNotEmpty && !tastingNotesTags.contains(newTag)) {
        if (tastingNotesTags.length < 5) { // 최대 5개 제한
          tastingNotesTags.add(newTag);
        }
        tastingNotesController.clear(); // 입력창 비우기 (태그화 완료)
        setState();
      } else {
        tastingNotesController.clear(); // 중복이거나 빈값이면 그냥 비움
      }
    }
  }

  /// 이미지 선택 bottom sheet 표시
  void showImagePicker(BuildContext context, VoidCallback setState) {
    final container = ProviderScope.containerOf(context);
    final imageService = container.read(imageServiceProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                final img = await imageService.pickImage(ImageSource.gallery);
                if (img != null) {
                  selectedImage = img;
                  existingImagePath = null; // 새 이미지 선택 시 기존 경로 제거
                  setState();
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                final img = await imageService.pickImage(ImageSource.camera);
                if (img != null) {
                  selectedImage = img;
                  existingImagePath = null; // 새 이미지 선택 시 기존 경로 제거
                  setState();
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 스케일 팩터 계산
  double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / AppSpacing.designWidth;
    // 최소/최대 스케일 팩터 제한 (0.3 ~ 1.2)
    return scaleFactor.clamp(0.3, 1.2);
  }

  /// 현재 표시할 이미지 경로 반환 (기존 경로 또는 새로 선택한 이미지 경로)
  String? get currentImagePath => selectedImage?.path ?? existingImagePath;

  /// 이미지가 있는지 확인 (기존 경로 또는 새로 선택한 이미지)
  bool get hasImage => selectedImage != null || existingImagePath != null;

  /// Form 데이터로부터 Detail 객체 생성
  /// 모든 필드가 NULL이면 null을 반환 (detail 저장 생략)
  Detail? createDetailFromForm(String noteId, {String? existingId}) {
    // "직접입력"(etc) 선택 시 텍스트가 빈칸이면 NULL로 처리
    final processText = selectedProcess == ProcessType.etc && processTextController.text.trim().isNotEmpty
        ? processTextController.text.trim()
        : null;
    final roastingPointText = selectedRoasting == RoastingPointType.etc && roastingPointTextController.text.trim().isNotEmpty
        ? roastingPointTextController.text.trim()
        : null;
    final methodText = selectedMethod == MethodType.etc && methodTextController.text.trim().isNotEmpty
        ? methodTextController.text.trim()
        : null;
    
    // "직접입력"이 아닌 경우 enum 값 사용, "직접입력"이면 null
    final process = selectedProcess == ProcessType.etc ? null : selectedProcess;
    final roastingPoint = selectedRoasting == RoastingPointType.etc ? null : selectedRoasting;
    final method = selectedMethod == MethodType.etc ? null : selectedMethod;
    
    final originLocation = countryController.text.trim().isEmpty ? null : countryController.text.trim();
    final variety = varietyController.text.trim().isEmpty ? null : varietyController.text.trim();
    final tastingNotes = tastingNotesTags.isNotEmpty ? tastingNotesTags : null;
    
    // 모든 필드가 NULL인지 확인
    if (originLocation == null &&
        variety == null &&
        process == null &&
        processText == null &&
        roastingPoint == null &&
        roastingPointText == null &&
        method == null &&
        methodText == null &&
        tastingNotes == null) {
      return null; // 모든 필드가 NULL이면 detail 저장 생략
    }
    
    return Detail(
      id: existingId ?? const Uuid().v4(),
      noteId: noteId,
      originLocation: originLocation,
      variety: variety,
      process: process,
      processText: processText,
      roastingPoint: roastingPoint,
      roastingPointText: roastingPointText,
      method: method,
      methodText: methodText,
      tastingNotes: tastingNotes,
    );
  }
}
