import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class NoteRepository {
  static final NoteRepository instance = NoteRepository._init();
  static Database? _database;

  NoteRepository._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        location TEXT NOT NULL,
        menu TEXT NOT NULL,
        level_acidity INTEGER NOT NULL,
        level_body INTEGER NOT NULL,
        level_bitterness INTEGER NOT NULL,
        comment TEXT NOT NULL,
        image TEXT,
        score INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // CRUD 메서드들
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'created_at DESC');
    return _mapsToNotes(maps);
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    if (maps.length > 1) {
        throw Exception('Multiple notes found for id: $id');
    }

    return _mapToNote(maps.first);
  }

  Future<Note> createNote(Note note) async {
    final db = await database;
    final now = DateTime.now();
    final noteMap = _noteToMap(note);
    noteMap['created_at'] = now.toIso8601String();
    noteMap['updated_at'] = now.toIso8601String();
    await db.insert('notes', noteMap);
    
    // createdAt, updatedAt이 설정된 새 Note 객체 반환
    return Note(
      id: note.id,
      location: note.location,
      menu: note.menu,
      levelAcidity: note.levelAcidity,
      levelBody: note.levelBody,
      levelBitterness: note.levelBitterness,
      comment: note.comment,
      image: note.image,
      score: note.score,
      drankAt: note.drankAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Note> updateNote(Note note) async {
    final db = await database;
    final now = DateTime.now();
    final noteMap = _noteToMap(note);
    noteMap['updated_at'] = now.toIso8601String();
    await db.update(
      'notes',
      noteMap,
      where: 'id = ?',
      whereArgs: [note.id],
    );
    // updatedAt이 갱신된 새 Note 객체 반환
    return Note(
      id: note.id,
      location: note.location,
      menu: note.menu,
      levelAcidity: note.levelAcidity,
      levelBody: note.levelBody,
      levelBitterness: note.levelBitterness,
      comment: note.comment,
      image: note.image,
      score: note.score,
      drankAt: note.drankAt,
      createdAt: note.createdAt,
      updatedAt: now,
    );
  }

  Future<bool> deleteNote(String id) async {
    final db = await database;
    final result = await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

//   // 정렬 메서드
//   Future<List<Note>> getNotesSortedByDate({bool ascending = true}) async {
//     final db = await database;
//     final maps = await db.query(
//       'notes',
//       orderBy: 'recorded_at ${ascending ? 'ASC' : 'DESC'}',
//     );
//     return _mapsToNotes(maps);
//   }

//   Future<List<Note>> getNotesSortedByScore({bool ascending = true}) async {
//     final db = await database;
//     final maps = await db.query(
//       'notes',
//       orderBy: 'score ${ascending ? 'ASC' : 'DESC'}',
//     );
//     return _mapsToNotes(maps);
//   }

  // 매핑용 헬퍼 메서드들
  Map<String, dynamic> _noteToMap(Note note) {
        return {
            'id': note.id,
            'location': note.location,
            'menu': note.menu,
            'level_acidity': note.levelAcidity,
            'level_body': note.levelBody,
            'level_bitterness': note.levelBitterness,
            'comment': note.comment,
            'image': note.image,
            'score': note.score,
            'recorded_at': note.drankAt.toIso8601String(),
            'created_at': note.createdAt.toIso8601String(),
            'updated_at': note.updatedAt.toIso8601String(),
        };
    }

    Note _mapToNote(Map<String, dynamic> map) {
        return Note(
            id: map['id'] as String,
            location: map['location'] as String,
            menu: map['menu'] as String,
            levelAcidity: map['level_acidity'] as int,
            levelBody: map['level_body'] as int,
            levelBitterness: map['level_bitterness'] as int,
            comment: map['comment'] as String,    
            image: map['image'] as String?,
            score: map['score'] as int,
            drankAt: DateTime.parse(map['recorded_at']),
            createdAt: DateTime.parse(map['created_at']),
            updatedAt: DateTime.parse(map['updated_at']),
        );
    }

    List<Note> _mapsToNotes(List<Map<String, dynamic>> maps) {
        return maps.map((map) => _mapToNote(map)).toList();
    }

    List<Map<String, dynamic>> _notesToMaps(List<Note> notes) {
        return notes.map((note) => _noteToMap(note)).toList();
    }
}