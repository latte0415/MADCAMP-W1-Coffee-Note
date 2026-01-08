class NoteService {
    Future<List<Note>> getAllNotes() async {
        // DB CRUD 로직
        return [];
    }

    Future<Note> getNoteById(String id) async {
        // DB CRUD 로직
        return Note();
    }

    Future<Note> createNote(Note note) async {
        // DB CRUD 로직
        return note;
    }

    Future<Note> updateNote(Note note) async {
        // DB CRUD 로직
        return note;
    }

    Future<Note> deleteNote(String id) async {
        // DB CRUD 로직
        return Note();
    }
}