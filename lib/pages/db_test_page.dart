import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/note_repository.dart';
import '../models/note.dart';

class DbTestPage extends StatefulWidget {
  const DbTestPage({super.key});

  @override
  State<DbTestPage> createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  final _repository = NoteRepository.instance;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _repository.getAllNotes();
    setState(() {
      _notes = notes;
    });
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

    await _repository.createNote(note);
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

    await _repository.updateNote(updatedNote);
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
      await _repository.deleteNote(id);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DB 테스트')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _createNote,
            child: const Text('노트 생성'),
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