import 'package:flutter/material.dart';

/// Note 모달의 기본 레이아웃 구조
class NoteModalScaffold extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Widget? Function()? floatingButtonBuilder;
  final double bottomPadding;

  const NoteModalScaffold({
    super.key,
    required this.header,
    required this.content,
    this.floatingButtonBuilder,
    this.bottomPadding = 75,
  });

  @override
  Widget build(BuildContext context) {
    // floatingButtonBuilder를 매번 호출하여 최신 상태 반영
    final floatingButton = floatingButtonBuilder?.call();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        content,
                        SizedBox(height: bottomPadding),
                      ],
                    ),
                  ),
                  if (floatingButton != null) floatingButton,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
