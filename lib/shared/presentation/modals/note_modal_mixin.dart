import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/theme.dart';
import '../../state/note_form_state.dart';

/// Note 모달의 공통 로직을 제공하는 Mixin
mixin NoteModalMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// 검증 에러 표시
  void showValidationError(BuildContext context, NoteFormState formState) {
    final missingFields = <String>[];
    if (formState.cafeController.text.trim().isEmpty) {
      missingFields.add('카페명');
    }
    if (formState.menuController.text.trim().isEmpty) {
      missingFields.add('메뉴명');
    }
    
    if (missingFields.isNotEmpty) {
      _showErrorOverlay(context, '${missingFields.first}을(를) 입력해주세요');
    }
  }

  /// 메뉴명 검증 에러 표시 (AI 자동생성용)
  void showMenuValidationError(BuildContext context) {
    _showErrorOverlay(context, '메뉴명을(를) 입력해주세요');
  }

  /// API 에러 표시 (네트워크 에러, 서버 에러 등)
  void showApiError(BuildContext context, dynamic error) {
    String errorMessage;
    if (error is Exception) {
      // Exception의 메시지만 추출 (예: "Exception: 메시지" -> "메시지")
      final errorString = error.toString();
      if (errorString.startsWith('Exception: ')) {
        errorMessage = errorString.substring(11);
      } else {
        errorMessage = errorString;
      }
    } else {
      errorMessage = error.toString();
    }
    _showErrorOverlay(context, errorMessage);
  }

  /// 에러 오버레이 표시 (공통)
  void _showErrorOverlay(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    overlay.insert(overlayEntry);
    
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

}
