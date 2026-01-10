import 'dart:math';
import '../repositories/note_repository.dart';
import '../models/note.dart';
import '../models/sort_option.dart';
import '../services/image_service.dart';

class NoteService {
    static final NoteService instance = NoteService._init();

    NoteService._init();

    Future<List<Note>> getAllNotes(SortOption sortOption) async {
        return await NoteRepository.instance.getAllNotes(sortOption);
    }

    Future<Note?> getNoteById(String id) async {
        return await NoteRepository.instance.getNoteById(id);
    }

    Future<Note> createNote(Note note) async {
        return await NoteRepository.instance.createNote(note);
    }

    Future<Note> updateNote(Note note) async {
        // 기존 노트의 이미지 경로 확인
        final existingNote = await NoteRepository.instance.getNoteById(note.id);
        
        // 기존 이미지가 있고, 새 이미지와 다른 경우 기존 이미지만 삭제
        if (existingNote != null && 
            existingNote.image != null && 
            existingNote.image != note.image) {
            // 기존 이미지 파일만 삭제 (새 이미지는 이미 저장되어 있음)
            await ImageService.instance.deleteImage(existingNote.image);
        }
        
        return await NoteRepository.instance.updateNote(note);
    }

    Future<bool> deleteNote(String id) async {
        // 노트 삭제 전에 이미지 경로 가져오기
        final note = await NoteRepository.instance.getNoteById(id);
        if (note != null && note.image != null) {
            // 이미지 파일도 삭제
            await ImageService.instance.deleteImage(note.image);
        }
        
        // DB에서 노트 삭제
        return await NoteRepository.instance.deleteNote(id);
    }

    Future<List<Note>> searchNotes(String query, SortOption sortOption) async {
        return await NoteRepository.instance.searchNotes(query, sortOption);
    }

    Future<List<Note>> getRecommendedNotes(
        int acidity,
        int body,
        int bitterness, {
        int limit = 5,
    }) async {
        final allNotes = await getAllNotes(const ScoreSortOption(ascending: false));

        final notesWithSimilarity = allNotes.map((note) {
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