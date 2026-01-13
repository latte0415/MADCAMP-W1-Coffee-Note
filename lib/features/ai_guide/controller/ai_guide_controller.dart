import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../backend/providers.dart';
import '../../../backend/services/api_service.dart';
import '../state/ai_guide_state.dart';

/// UI에 전달할 뷰 모델
class AiGuideViewData {
  final AiGuideState state;
  final Map<String, dynamic>? mappingResult;
  final String sensoryGuide;
  final Object? error;

  const AiGuideViewData({
    required this.state,
    this.mappingResult,
    this.sensoryGuide = '',
    this.error,
  });

  AiGuideViewData copyWith({
    AiGuideState? state,
    Map<String, dynamic>? mappingResult,
    String? sensoryGuide,
    Object? error,
    bool clearError = false,
  }) {
    return AiGuideViewData(
      state: state ?? this.state,
      mappingResult: mappingResult ?? this.mappingResult,
      sensoryGuide: sensoryGuide ?? this.sensoryGuide,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// AI 가이드 화면 상태를 관리하는 AsyncNotifier
final aiGuideControllerProvider =
    AsyncNotifierProvider<AiGuideController, AiGuideViewData>(
  () => AiGuideController(),
);

class AiGuideController extends AsyncNotifier<AiGuideViewData> {
  late final APIService _apiService;

  @override
  Future<AiGuideViewData> build() async {
    _apiService = ref.read(apiServiceProvider);
    return const AiGuideViewData(
      state: AiGuideState(),
    );
  }

  /// 가이드 요청
  Future<void> requestGuide(String inputText) async {
    if (inputText.trim().isEmpty) {
      return;
    }

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(
          state: current.state.copyWith(
            inputText: inputText,
            isLoading: true,
            hasResult: false,
          ),
          clearError: true,
        ),
      );
    }

    final result = await AsyncValue.guard(() async {
      final response = await _apiService.chatForSensoryGuide(inputText);
      return {
        'mappingResult': response['mappingResult'] as Map<String, dynamic>?,
        'sensoryGuide': response['sensoryGuide'] as String? ?? '',
      };
    });

    state = result.when(
      data: (data) {
        final current = state.valueOrNull;
        return AsyncValue.data(
          current?.copyWith(
            state: current.state.copyWith(
              isLoading: false,
              hasResult: true,
            ),
            mappingResult: data['mappingResult'],
            sensoryGuide: data['sensoryGuide'],
          ) ??
              AiGuideViewData(
                state: const AiGuideState(),
                mappingResult: data['mappingResult'],
                sensoryGuide: data['sensoryGuide'],
              ),
        );
      },
      error: (e, st) {
        final current = state.valueOrNull;
        return AsyncValue.data(
          current?.copyWith(
            state: current.state.copyWith(isLoading: false),
            error: e,
          ) ??
              AiGuideViewData(
                state: const AiGuideState(),
                error: e,
              ),
        );
      },
      loading: () => const AsyncValue.loading(),
    );
  }

  /// 입력 텍스트 변경 시 결과 초기화
  void clearResult() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(
          state: current.state.copyWith(hasResult: false),
        ),
      );
    }
  }
}
