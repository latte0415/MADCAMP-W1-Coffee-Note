import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/note_service.dart';
import '../models/note.dart';
import '../models/sort_option.dart';

class DbTestPage extends StatefulWidget {
  const DbTestPage({super.key});

  @override
  State<DbTestPage> createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  List<Note> _notes = [];
  SortOption _currentSortOption = const DateSortOption(ascending: false);

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NoteService.instance.getAllNotes(_currentSortOption);
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _createTestData() async {
    final now = DateTime.now();
    final testNotes = [
      // 다양한 점수와 날짜를 가진 테스트 데이터
      Note(
        id: const Uuid().v4(),
        location: '스타벅스 강남점',
        menu: '아메리카노',
        levelAcidity: 5,
        levelBody: 3,
        levelBitterness: 4,
        comment: '맛있어요',
        score: 5,
        drankAt: now.subtract(const Duration(days: 10)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '투썸플레이스',
        menu: '카페라떼',
        levelAcidity: 3,
        levelBody: 5,
        levelBitterness: 2,
        comment: '그냥 그래요',
        score: 2,
        drankAt: now.subtract(const Duration(days: 5)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '이디야커피',
        menu: '바닐라라떼',
        levelAcidity: 2,
        levelBody: 4,
        levelBitterness: 3,
        comment: '최고예요!',
        score: 4,
        drankAt: now.subtract(const Duration(days: 15)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '할리스커피',
        menu: '콜드브루',
        levelAcidity: 4,
        levelBody: 5,
        levelBitterness: 5,
        comment: '별로예요',
        score: 1,
        drankAt: now.subtract(const Duration(days: 2)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '컴포즈커피',
        menu: '카푸치노',
        levelAcidity: 3,
        levelBody: 3,
        levelBitterness: 3,
        comment: '무난해요',
        score: 3,
        drankAt: now.subtract(const Duration(days: 7)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '메가커피',
        menu: '에스프레소',
        levelAcidity: 5,
        levelBody: 2,
        levelBitterness: 4,
        comment: '좋아요',
        score: 4,
        drankAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '빽다방',
        menu: '아이스 아메리카노',
        levelAcidity: 2,
        levelBody: 2,
        levelBitterness: 2,
        comment: '괜찮아요',
        score: 3,
        drankAt: now.subtract(const Duration(days: 20)),
      ),
      Note(
        id: const Uuid().v4(),
        location: '카페베네',
        menu: '카라멜 마키아토',
        levelAcidity: 1,
        levelBody: 4,
        levelBitterness: 1,
        comment: '최고!',
        score: 5,
        drankAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final note in testNotes) {
      await NoteService.instance.createNote(note);
    }

    _loadNotes();
  }

  Future<void> _sortByDate(bool ascending) async {
    setState(() {
      _currentSortOption = DateSortOption(ascending: ascending);
    });
    _loadNotes();
  }

  Future<void> _sortByScore(bool ascending) async {
    setState(() {
      _currentSortOption = ScoreSortOption(ascending: ascending);
    });
    _loadNotes();
  }

  Future<void> _createNote() async {
    final note = Note(
      id: const Uuid().v4(),
      location: '테스트 카페',
      menu: '아메리카노',
      levelAcidity: 3,
      levelBody: 4,
      levelBitterness: 2,
      comment: '테스트',
      score: 8,
      drankAt: DateTime.now(),
    );

    await NoteService.instance.createNote(note);
    _loadNotes();
  }

  Future<void> _updateNote(Note note) async {
    final updatedNote = Note(
      id: note.id,
      location: note.location,
      menu: '${note.menu} (수정됨)',
      levelAcidity: note.levelAcidity,
      levelBody: note.levelBody,
      levelBitterness: note.levelBitterness,
      comment: '${note.comment} - 업데이트 테스트',
      score: note.score + 1 > 5 ? 5 : note.score + 1,
      drankAt: note.drankAt,
      createdAt: note.createdAt,
    );

    await NoteService.instance.updateNote(updatedNote);
    _loadNotes();
  }

  Future<void> _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 노트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NoteService.instance.deleteNote(id);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DB 테스트')),
      body: Column(
        children: [
          // 테스트 데이터 생성 버튼
          ElevatedButton(
            onPressed: _createTestData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('테스트 데이터 생성 (다양한 점수/날짜)'),
          ),
          const SizedBox(height: 8),
          // 기본 노트 생성 버튼
          ElevatedButton(
            onPressed: _createNote,
            child: const Text('노트 생성'),
          ),
          const SizedBox(height: 8),
          // 정렬 옵션 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('날짜순', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _sortByDate(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentSortOption is DateSortOption && !_currentSortOption.ascending
                              ? Colors.green
                              : null,
                        ),
                        child: const Text('↓ 최신순'),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () => _sortByDate(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentSortOption is DateSortOption && _currentSortOption.ascending
                              ? Colors.green
                              : null,
                        ),
                        child: const Text('↑ 오래된순'),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('점수순', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _sortByScore(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentSortOption is ScoreSortOption && !_currentSortOption.ascending
                              ? Colors.green
                              : null,
                        ),
                        child: const Text('↓ 높은순'),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () => _sortByScore(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentSortOption is ScoreSortOption && _currentSortOption.ascending
                              ? Colors.green
                              : null,
                        ),
                        child: const Text('↑ 낮은순'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 현재 정렬 상태 표시
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Text(
              '현재 정렬: ${_currentSortOption is DateSortOption ? "날짜" : "점수"} (${_currentSortOption.ascending ? "오름차순" : "내림차순"})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('노트가 없습니다.'))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            note.menu,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${note.location} | 점수: ${note.score}/5'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('ID', note.id),
                                  _buildInfoRow('위치', note.location),
                                  _buildInfoRow('메뉴', note.menu),
                                  _buildInfoRow('산미', '${note.levelAcidity}/10'),
                                  _buildInfoRow('바디', '${note.levelBody}/10'),
                                  _buildInfoRow('쓴맛', '${note.levelBitterness}/10'),
                                  _buildInfoRow('점수', '${note.score}/5'),
                                  _buildInfoRow('코멘트', note.comment),
                                  _buildInfoRow(
                                    '마신 날짜',
                                    '${note.drankAt.year}-${note.drankAt.month.toString().padLeft(2, '0')}-${note.drankAt.day.toString().padLeft(2, '0')}',
                                  ),
                                  _buildInfoRow(
                                    '생성일',
                                    '${note.createdAt.year}-${note.createdAt.month.toString().padLeft(2, '0')}-${note.createdAt.day.toString().padLeft(2, '0')} ${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  _buildInfoRow(
                                    '수정일',
                                    '${note.updatedAt.year}-${note.updatedAt.month.toString().padLeft(2, '0')}-${note.updatedAt.day.toString().padLeft(2, '0')} ${note.updatedAt.hour.toString().padLeft(2, '0')}:${note.updatedAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  if (note.image != null)
                                    _buildInfoRow('이미지', note.image!),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _updateNote(note),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('수정'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _deleteNote(note.id),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('삭제'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}