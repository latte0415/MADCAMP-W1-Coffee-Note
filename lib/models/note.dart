import 'sort_option.dart';

class Note {
    final String id;
    final String location;
    final String menu;
    final int levelAcidity;
    final int levelBody;
    final int levelBitterness;
    final String comment;
    final String? image;
    final int score;
    final DateTime drankAt;
    final DateTime createdAt;
    final DateTime updatedAt;

    Note({
        required this.id,
        required this.location,
        required this.menu,
        required this.levelAcidity,
        required this.levelBody,
        required this.levelBitterness,
        required this.comment,
        this.image,
        required this.score,
        required this.drankAt,
        DateTime? createdAt,
        DateTime? updatedAt,
        }) : this.createdAt = createdAt ?? DateTime.now(),
             this.updatedAt = updatedAt ?? DateTime.now();

}

class NoteQuery {
    final String? query;
    final SortOption sortOption;
    final bool showDetailFilter;
    final int? acidity;
    final int? body;
    final int? bitterness;

    NoteQuery({
        this.query,
        required this.sortOption,
        required this.showDetailFilter,
        this.acidity,
        this.body,
        this.bitterness,
    });
}