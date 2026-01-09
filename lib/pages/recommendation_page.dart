// lib/pages/recommendation_page.dart
import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천'),
      ),
      body: const Center(
        child: Text('추천 페이지'),
      ),
    );
  }
}