// lib/pages/list_page.dart
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리스트'),
      ),
      body: const Center(
        child: Text('리스트 페이지'),
      ),
    );
  }
}