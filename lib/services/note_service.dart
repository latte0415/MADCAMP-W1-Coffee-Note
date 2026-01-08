import '../repositories/note_repository.dart';
import '../models/note.dart';

class NoteService {
    static final NoteService instance = NoteService._init();

    NoteService._init();

    Future<List<Note>> getAllNotes() async {
        return await NoteRepository.instance.getAllNotes();
    }

    Future<Note?> getNoteById(String id) async {
        return await NoteRepository.instance.getNoteById(id);
    }

    Future<Note> createNote(Note note) async {
        return await NoteRepository.instance.createNote(note);
    }

    Future<Note> updateNote(Note note) async {
        return await NoteRepository.instance.updateNote(note);
    }

    Future<bool> deleteNote(String id) async {
        return await NoteRepository.instance.deleteNote(id);
    }
}