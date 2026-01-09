import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 정렬 버튼 영역 (피그마 1-0-0 상단)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text("날짜순")),
              TextButton(onPressed: () {}, child: const Text("Score순")),
            ],
          ),
        ),
        // 2. 실제 리스트 (임시 데이터)
        const Expanded(
          child: Center(child: Text('여기에 커피 리스트 카드들이 들어갑니다')),
        ),
      ],
    );
  }
}