import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../models/sort_option.dart'; // [추가]
import '../../services/note_service.dart';
import '../pages/modals/details_modal.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  // 외부(MainPage)에서 이 함수를 부르면 리스트가 새로고침됩니다.
  void refreshNotes() {
    setState(() {
      // FutureBuilder가 _getSortedNotes()를 다시 호출하게 유도합니다.
    });
  }

  // [추가] 현재 선택된 정렬 옵션 상태 (기본값: 날짜 최신순)
  SortOption _currentSort = const DateSortOption(ascending: false);

  // [추가] 데이터를 가져와서 현재 옵션에 맞게 정렬하는 함수
  Future<List<Note>> _getSortedNotes() async {
    final notes = await NoteService.instance.getAllNotes(_currentSort);

    if (_currentSort is DateSortOption) {
      notes.sort((a, b) => _currentSort.ascending
          ? a.drankAt.compareTo(b.drankAt)
          : b.drankAt.compareTo(a.drankAt));
    } else if (_currentSort is ScoreSortOption) {
      notes.sort((a, b) => _currentSort.ascending
          ? a.score.compareTo(b.score)
          : b.score.compareTo(a.score));
    }
    return notes;
  }

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
              // [변경] 각 버튼에 정렬 객체를 전달
              _sortButton("날짜순", const DateSortOption(ascending: false)),
              const SizedBox(width: 8),
              _sortButton("Score순", const ScoreSortOption(ascending: false)),
            ],
          ),
        ),

        // 2. FutureBuilder 영역
        Expanded(
          child: FutureBuilder<List<Note>>(
            // [변경] 직접 Service를 부르지 않고 정렬 로직이 포함된 함수 호출
            future: _getSortedNotes(),
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

  // [변경] context를 직접 쓰지 않고 클래스 멤버로 사용하며, 정렬 옵션을 인자로 받음
  Widget _sortButton(String label, SortOption option) {
    // 현재 선택된 정렬 타입인지 확인 (is 연산자로 타입 비교)
    bool isSelected = (_currentSort.runtimeType == option.runtimeType);
    Color primaryColor = Theme.of(context).primaryColor;

    return OutlinedButton(
      onPressed: () {
        // [핵심] 버튼 클릭 시 상태 변경 및 UI 갱신
        setState(() {
          _currentSort = option;
        });
      },
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        // 선택되었을 때 배경색을 보라색으로 채움
        backgroundColor: isSelected ? primaryColor : Colors.transparent,
        side: BorderSide(color: primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          // 선택되었을 때 글자색을 흰색으로 변경
          color: isSelected ? Colors.white : primaryColor,
          fontSize: 12,
        ),
      ),
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
            const Text("아직 작성된 노트가 없어요",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("하단의 + 버튼을 눌러\n첫 번째 커피 노트를 만들어보세요!",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoffeeCard(Note note) {
      // 리스트 노트 클릭 시 detail modal 연결
      return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent, // 모서리 곡선을 위해 투명 배경 설정
              builder: (context) => NoteDetailsModal(note: note),
            ).then((result) {
              // 수정 후 '저장'을 눌러 true가 반환되면 목록을 새로고침합니다.
              if (result == true) {
                refreshNotes();
              }
            });
          },
      child: Card(
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
      ),
    );
  }

  // 수치 정보를 표시하는 스타일을 재사용 가능하게 모듈화
  Widget _levelText(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Text("$label $value", style: const TextStyle(fontSize: 12)),
    );
  }
}