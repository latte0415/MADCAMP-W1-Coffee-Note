import '../repositories/note_repository.dart';
import '../models/note.dart';

class NoteService {
    Future<List<Note>> getAllNotes() async {
        await NoteRepository.instance.getAllNotes();
        return [];
    }

    Future<Note> getNoteById(String id) async {
        await NoteRepository.instance.getNoteById(id);
        return Note();
    }

    Future<Note> createNote(Note note) async {
        await NoteRepository.instance.createNote(note);
        return note;
    }

    Future<Note> updateNote(Note note) async {
        await NoteRepository.instance.updateNote(note);
        return note;
    }

    Future<Note> deleteNote(String id) async {
        await NoteRepository.instance.deleteNote(id);
        return Note();
    }
}