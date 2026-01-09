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
}