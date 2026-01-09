sealed class SortOption {
    final bool ascending;

    const SortOption(this.ascending);

    String toSqlOrderBy();
}

class DateSortOption extends SortOption {
    const DateSortOption({bool ascending = false}) : super(ascending);

    @override
    String toSqlOrderBy() {
        return 'drank_at ${ascending ? 'ASC' : 'DESC'}';
    }
}

class ScoreSortOption extends SortOption {
    const ScoreSortOption({bool ascending = false}) : super(ascending);

    @override
    String toSqlOrderBy() {
        return 'score ${ascending ? 'ASC' : 'DESC'}';
    }
}