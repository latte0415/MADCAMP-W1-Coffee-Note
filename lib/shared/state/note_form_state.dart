import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../models/note.dart';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
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
  
  // AI 자동생성 관련 상태
  bool isGenerating = false;
  Future<Map<String, dynamic>>? aiGenerationFuture;
  CancelToken? aiGenerationCancelToken;

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

  /// 상세정보 필드만 초기화
  void resetDetailFields() {
    countryController.clear();
    varietyController.clear();
    processTextController.clear();
    roastingPointTextController.clear();
    methodTextController.clear();
    tastingNotesController.clear();
    selectedProcess = ProcessType.etc;
    selectedRoasting = RoastingPointType.etc;
    selectedMethod = MethodType.etc;
    tastingNotesTags.clear();
  }

  /// AI 생성 취소
  void cancelAiGeneration() {
    aiGenerationCancelToken?.cancel('사용자 취소');
    aiGenerationCancelToken = null;
    aiGenerationFuture = null;
    isGenerating = false;
  }

  /// isGenerating 상태 업데이트 (상태 동기화를 위한 메서드)
  void updateIsGenerating(bool value) {
    isGenerating = value;
    if (!value) {
      // false로 설정 시 관련 리소스 정리
      aiGenerationFuture = null;
      aiGenerationCancelToken = null;
    }
  }

  /// AI 생성 시작 (CancelToken 설정 포함)
  void startAiGeneration(CancelToken cancelToken) {
    if (isGenerating) {
      cancelAiGeneration();
    }
    aiGenerationCancelToken = cancelToken;
    isGenerating = true;
  }

  /// AI 생성 완료 처리
  void completeAiGeneration() {
    isGenerating = false;
    aiGenerationFuture = null;
    aiGenerationCancelToken = null;
  }

  /// AI 응답 데이터를 폼에 적용 (기존 정보 전부 덮어쓰기)
  void applyAiResponse(Map<String, dynamic> aiData, VoidCallback setState) {
    // originLocation - null이면 빈 문자열로 덮어쓰기
    countryController.text = aiData['originLocation'] as String? ?? '';
    
    // variety - null이면 빈 문자열로 덮어쓰기
    varietyController.text = aiData['variety'] as String? ?? '';
    
    // process
    if (aiData['process'] != null && aiData['process'] is ProcessType) {
      selectedProcess = aiData['process'] as ProcessType;
      processTextController.text = (selectedProcess == ProcessType.etc && aiData['processText'] != null)
          ? aiData['processText'] as String
          : '';
    } else {
      selectedProcess = ProcessType.etc;
      processTextController.text = '';
    }
    
    // roastingPoint
    if (aiData['roastingPoint'] != null && aiData['roastingPoint'] is RoastingPointType) {
      selectedRoasting = aiData['roastingPoint'] as RoastingPointType;
      roastingPointTextController.text = (selectedRoasting == RoastingPointType.etc && aiData['roastingPointText'] != null)
          ? aiData['roastingPointText'] as String
          : '';
    } else {
      selectedRoasting = RoastingPointType.etc;
      roastingPointTextController.text = '';
    }
    
    // method
    if (aiData['method'] != null && aiData['method'] is MethodType) {
      selectedMethod = aiData['method'] as MethodType;
      methodTextController.text = (selectedMethod == MethodType.etc && aiData['methodText'] != null)
          ? aiData['methodText'] as String
          : '';
    } else {
      selectedMethod = MethodType.etc;
      methodTextController.text = '';
    }
    
    // tastingNotes - null이면 빈 리스트로 덮어쓰기
    if (aiData['tastingNotes'] != null && aiData['tastingNotes'] is List) {
      final notes = (aiData['tastingNotes'] as List).cast<String>();
      tastingNotesTags = notes.take(5).toList(); // 최대 5개
      tastingNotesController.text = tastingNotesTags.join(', ');
    } else {
      tastingNotesTags = [];
      tastingNotesController.text = '';
    }
    
    setState();
  }

}
