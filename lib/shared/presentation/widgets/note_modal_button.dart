import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// Note 모달의 하단 floating 버튼 위젯
class NoteModalButton extends StatelessWidget {
  final bool isValid;
  final bool isGenerating;
  final String buttonText;
  final VoidCallback? onPressed;
  final VoidCallback? onValidationError;

  const NoteModalButton({
    super.key,
    required this.isValid,
    required this.isGenerating,
    required this.buttonText,
    this.onPressed,
    this.onValidationError,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 그라데이션 오버레이
          Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(1.0),
                ],
              ),
            ),
          ),
          // 버튼
          Container(
            padding: const EdgeInsets.only(top: 10),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // AI 생성 중이거나 유효하지 않으면 비활성화 색상
                  backgroundColor: isGenerating
                      ? Colors.grey
                      : (!isValid ? Colors.grey : AppColors.primaryDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: (isValid && !isGenerating) 
                    ? onPressed 
                    : (isGenerating ? null : onValidationError),
                child: Text(
                  isGenerating 
                      ? "AI 생성 중..." 
                      : buttonText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
