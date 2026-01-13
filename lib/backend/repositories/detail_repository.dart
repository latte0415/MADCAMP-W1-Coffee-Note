import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../../models/detail.dart';
import '../../models/enums/process_type.dart';
import '../../models/enums/roasting_point_type.dart';
import '../../models/enums/method_type.dart';
import '../../database/database_manager.dart';

class DetailRepository {
    final DatabaseManager databaseManager;

    DetailRepository({required this.databaseManager});

    /// DatabaseManager를 통해 공통 DB 인스턴스 사용
    Future<Database> get database async {
        return await databaseManager.database;
    }

    // CRUD 메서드들
    Future<Detail?> getDetailByNoteId(String noteId) async {
        final db = await database;
        final maps = await db.query(
            'details',
            where: 'note_id = ?',
            whereArgs: [noteId],
        );

        if (maps.isEmpty) return null;
        if (maps.length > 1) {
            throw Exception('Multiple details found for note_id: $noteId');
        }

        return _mapToDetail(maps.first);
    }

    Future<Detail?> getDetailById(String id) async {
        final db = await database;
        final maps = await db.query(
            'details',
            where: 'id = ?',
            whereArgs: [id],
        );

        if (maps.isEmpty) return null;
        if (maps.length > 1) {
            throw Exception('Multiple details found for id: $id');
        }

        return _mapToDetail(maps.first);
    }

    Future<Detail> createDetail(Detail detail) async {
        final db = await database;

        final existingDetail = await getDetailByNoteId(detail.noteId);
        if (existingDetail != null) {
            throw Exception('Detail already exists for note_id: ${detail.noteId}');
        }

        final detailMap = _detailToMap(detail);
        await db.insert('details', detailMap);
        return detail;
    }

    Future<Detail> updateDetail(Detail detail) async {
        final db = await database;
        final detailMap = _detailToMap(detail);
        await db.update(
            'details',
            detailMap,
            where: 'id = ?',
            whereArgs: [detail.id],
        );
        return detail;
    }

    Future<bool> deleteDetail(String id) async {
        final db = await database;
        final result = await db.delete(
            'details',
            where: 'id = ?',
            whereArgs: [id],
        );
        return result > 0;
    }

    Future<bool> deleteDetailByNoteId(String noteId) async {
        final db = await database;
        final result = await db.delete(
            'details',
            where: 'note_id = ?',
            whereArgs: [noteId],
        );
        return result > 0;
    }

    // 매핑용 헬퍼 메서드들
    Map<String, dynamic> _detailToMap(Detail detail) {
        return {
            'id': detail.id,
            'note_id': detail.noteId,
            'origin_location': detail.originLocation,
            'variety': detail.variety,
            'process': detail.process?.toDbValue(),  // enum을 DB 값으로 변환 (nullable)
            'process_text': detail.processText,
            'roasting_point': detail.roastingPoint?.toDbValue(),  // enum을 DB 값으로 변환 (nullable)
            'roasting_point_text': detail.roastingPointText,
            'method': detail.method?.toDbValue(),  // enum을 DB 값으로 변환 (nullable)
            'method_text': detail.methodText,
            'tasting_notes': detail.tastingNotes != null && detail.tastingNotes!.isNotEmpty
                ? jsonEncode(detail.tastingNotes)
                : null,
        };
    }

    Detail _mapToDetail(Map<String, dynamic> map) {
        List<String>? tastingNotes;
        final tastingNotesStr = map['tasting_notes'] as String?;
        if (tastingNotesStr != null && tastingNotesStr.isNotEmpty) {
            try {
                final decoded = jsonDecode(tastingNotesStr);
                if (decoded is List) {
                    tastingNotes = decoded.cast<String>();
                }
            } catch (e) {
                // JSON 파싱 실패 시 null로 설정 (기존 데이터 호환성)
                tastingNotes = null;
            }
        }

        return Detail(
            id: map['id'] as String,
            noteId: map['note_id'] as String,
            originLocation: map['origin_location'] as String?,
            variety: map['variety'] as String?,
            process: map['process'] != null 
                ? ProcessType.fromDbValue(map['process'] as String)  // DB 값에서 enum으로 변환
                : null,
            processText: map['process_text'] as String?,
            roastingPoint: map['roasting_point'] != null
                ? RoastingPointType.fromDbValue(map['roasting_point'] as String)  // DB 값에서 enum으로 변환
                : null,
            roastingPointText: map['roasting_point_text'] as String?,
            method: map['method'] != null
                ? MethodType.fromDbValue(map['method'] as String)  // DB 값에서 enum으로 변환
                : null,
            methodText: map['method_text'] as String?,
            tastingNotes: tastingNotes,
        );
    }
}