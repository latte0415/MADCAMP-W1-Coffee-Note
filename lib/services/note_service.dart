import 'dart:math';
import '../repositories/note_repository.dart';
import '../models/note.dart';
import '../models/sort_option.dart';
import '../services/image_service.dart';

class NoteService {
    /// 기본 싱글턴은 유지하되, 주입식 생성을 허용한다.
    static final NoteService instance = NoteService(
        noteRepository: NoteRepository.instance,
        imageService: ImageService.instance,
    );

    final NoteRepository noteRepository;
    final ImageService imageService;

    NoteService({
        required this.noteRepository,
        required this.imageService,
    });

    /// 검색/정렬/필터 요청을 한번에 처리
    Future<List<Note>> getNotes(NoteQuery query) async {
        List<Note> notes;
        if (query.query != null && query.query!.isNotEmpty) {
            notes = await searchNotes(query.query!, query.sortOption);
        } else {
            notes = await getAllNotes(query.sortOption);
        }

        if (query.showDetailFilter) {
            notes = await filterRecommendedNotes(
              notes,
              acidity: query.acidity ?? 5,
              body: query.body ?? 5,
              bitterness: query.bitterness ?? 5,
              limit: 5,
            );
        }

        return notes;
    }

    /// 이미지가 있는 노트만 가져오기 (갤러리용)
    Future<List<Note>> getImageNotes({SortOption sortOption = const DateSortOption(ascending: false)}) async {
        final notes = await getAllNotes(sortOption);
        return notes
            .where((note) => note.image != null && note.image!.isNotEmpty)
            .toList();
    }

    Future<List<Note>> getAllNotes(SortOption sortOption) async {
        return await noteRepository.getAllNotes(sortOption);
    }

    Future<List<Note>> searchNotes(String query, SortOption sortOption) async {
        return await noteRepository.searchNotes(query, sortOption);
    }

    Future<Note?> getNoteById(String id) async {
        return await noteRepository.getNoteById(id);
    }

    Future<Note> createNote(Note note) async {
        return await noteRepository.createNote(note);
    }

    Future<Note> updateNote(Note note) async {
        // 기존 노트의 이미지 경로 확인
        final existingNote = await noteRepository.getNoteById(note.id);
        
        // 기존 이미지가 있고, 새 이미지와 다른 경우 기존 이미지만 삭제
        if (existingNote != null && 
            existingNote.image != null && 
            existingNote.image != note.image) {
            // 기존 이미지 파일만 삭제 (새 이미지는 이미 저장되어 있음)
            await imageService.deleteImage(existingNote.image);
        }
        
        return await noteRepository.updateNote(note);
    }

    Future<bool> deleteNote(String id) async {
        // 노트 삭제 전에 이미지 경로 가져오기
        final note = await noteRepository.getNoteById(id);
        if (note != null && note.image != null) {
            // 이미지 파일도 삭제
            await imageService.deleteImage(note.image);
        }
        
        // DB에서 노트 삭제
        return await noteRepository.deleteNote(id);
    }

    /// 전달받은 노트 리스트를 맛 필터(acidity/body/bitterness)로 유사도 정렬 후 반환
    Future<List<Note>> filterRecommendedNotes(
        List<Note> notes, {
        required int acidity,
        required int body,
        required int bitterness,
        int limit = 5,
    }) async {
        // final allNotes = await getAllNotes(const ScoreSortOption(ascending: false));

        final notesWithSimilarity = notes.map((note) {
            final similarity = _calculateSimilarity(note, acidity, body, bitterness);
            return (note: note, similarity: similarity);
        }).toList();

        notesWithSimilarity.sort((a, b) => b.similarity.compareTo(a.similarity));
        
        return notesWithSimilarity
            .take(limit)
            .map((item) => item.note)
            .toList();
    }

    double _calculateSimilarity(Note note, int acidity, int body, int bitterness) {
        final diffAcidity = pow(note.levelAcidity - acidity, 2).toDouble();
        final diffBody = pow(note.levelBody - body, 2).toDouble();
        final diffBitterness = pow(note.levelBitterness - bitterness, 2).toDouble();

        final diff = sqrt(diffAcidity + diffBody + diffBitterness);
        
        // 각 값이 1-10 범위이므로 최대 차이는 9지만 10으로 가정
        final maxDiff = sqrt(300.0);
        
        // 유사도: 1.0 (완전 일치) ~ 0.0 (완전 불일치)
        final similarity = 1.0 - (diff / maxDiff);
        
        // 음수 방지 (이론적으로는 발생하지 않지만 안전장치)
        return similarity.clamp(0.0, 1.0);
    }

}