/// AI 가이드 화면의 상태
class AiGuideState {
  final String inputText;
  final bool isLoading;
  final bool hasResult;

  const AiGuideState({
    this.inputText = '',
    this.isLoading = false,
    this.hasResult = false,
  });

  AiGuideState copyWith({
    String? inputText,
    bool? isLoading,
    bool? hasResult,
  }) {
    return AiGuideState(
      inputText: inputText ?? this.inputText,
      isLoading: isLoading ?? this.isLoading,
      hasResult: hasResult ?? this.hasResult,
    );
  }
}
