// lib/pages/gallery_page.dart
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('갤러리'),
      ),
      body: const Center(
        child: Text('갤러리 페이지'),
      ),
    );
  }
}