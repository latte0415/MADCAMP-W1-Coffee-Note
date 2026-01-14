import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// Note 모달의 상단 헤더 위젯
class NoteModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget? actionButton;

  const NoteModalHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryDark, size: 24),
          onPressed: onClose,
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actionButton ?? const SizedBox(width: 48), // 대칭을 위한 공간
      ],
    );
  }
}
