import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 상단 정렬 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _sortButton(context, "날짜순"),
              const SizedBox(width: 8),
              _sortButton(context, "Score순"),
            ],
          ),
        ),

        // 2. FutureBuilder 영역
        Expanded(
          child: FutureBuilder<List<Note>>(
            future: NoteService.instance.getAllNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView(
                  children: [
                    _buildEmptyGuideCard(),
                  ],
                );
              }

              final notes = snapshot.data!;
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return _buildCoffeeCard(notes[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGuideCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.coffee_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "아직 작성된 노트가 없어요",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "하단의 + 버튼을 눌러\n첫 번째 커피 노트를 만들어보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoffeeCard(Note note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(note.menu, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(" ${note.score}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.comment, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(note.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _levelText("산미", note.levelAcidity),
                _levelText("바디", note.levelBody),
                _levelText("쓴맛", note.levelBitterness),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.drankAt.toString().split(' ')[0],
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _levelText(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Text("$label $value", style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _sortButton(BuildContext context, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}