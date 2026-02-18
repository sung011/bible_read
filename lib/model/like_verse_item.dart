class LikeVerseItem {
  final String book;
  final int chapter;
  final int verse;
  final String content;

  LikeVerseItem({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.content,
  });

  String get reference => '$book $chapter:$verse';
  String get key => '$book|$chapter|$verse';

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'content': content,
      };

  static LikeVerseItem? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final book = (raw['book'] ?? '').toString();
    final chapter = raw['chapter'] is int
        ? raw['chapter'] as int
        : int.tryParse((raw['chapter'] ?? '').toString());
    final verse = raw['verse'] is int
        ? raw['verse'] as int
        : int.tryParse((raw['verse'] ?? '').toString());
    final content = (raw['content'] ?? '').toString();
    if (book.isEmpty || chapter == null || verse == null) return null;
    return LikeVerseItem(
      book: book,
      chapter: chapter,
      verse: verse,
      content: content,
    );
  }
}

String removeHanjaInParenthesesForLike(String text) {
  return text.replaceAll(RegExp(r'\([^)]*\)'), '');
}

