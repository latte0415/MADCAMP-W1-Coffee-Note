// lib/pages/ai_guide_page.dart
import 'package:flutter/material.dart';

class AiGuidePage extends StatelessWidget {
  const AiGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 가이드'),
      ),
      body: const Center(
        child: Text('AI 가이드 페이지'),
      ),
    );
  }
}