import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 공통 데이터베이스 관리자
/// 모든 Repository가 공유하는 단일 DB 인스턴스를 관리합니다.
class DatabaseManager {
    static final DatabaseManager instance = DatabaseManager._init();
    static Database? _database;

    DatabaseManager._init();

    /// 데이터베이스 인스턴스 반환 (Singleton)
    Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDB('local_main.db');
        return _database!;
    }

    /// 데이터베이스 초기화
    Future<Database> _initDB(String filePath) async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);

        return await openDatabase(
            path,
            version: 1,
            onCreate: _createTables,
        );
    }

    /// 모든 테이블 생성
    Future<void> _createTables(Database db, int version) async {
        // notes 테이블 생성
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
                drank_at TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        ''');

        // details 테이블 생성
        await db.execute('''
            CREATE TABLE details (
                id TEXT PRIMARY KEY,
                note_id TEXT NOT NULL UNIQUE,
                origin_country TEXT,
                origin_region TEXT,
                variety TEXT,
                process TEXT NOT NULL,
                process_text TEXT,
                roasting_point TEXT NOT NULL,
                roasting_point_text TEXT,
                method TEXT NOT NULL,
                method_text TEXT
            )
        ''');
    }

    /// 데이터베이스 연결 종료 (테스트용)
    Future<void> close() async {
        if (_database != null) {
            await _database!.close();
            _database = null;
        }
    }
}
