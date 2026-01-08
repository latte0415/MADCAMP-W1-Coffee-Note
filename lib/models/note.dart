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
    final DateTime recordedAt;
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
        required this.recordedAt,
    })
}