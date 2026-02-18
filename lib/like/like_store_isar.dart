import 'package:bible_read/db/isar_db.dart';
import 'package:bible_read/db/like_verse.dart';
import 'package:bible_read/model/like_verse_item.dart';
import 'package:isar/isar.dart';

import 'like_store_base.dart';

/// 모바일(iOS/Android): Isar(NoSQL DB)에 좋아요 저장
class IsarLikeStore implements LikeStore {
  Future<Isar>? _isarFuture;

  Future<Isar> _getIsar() async {
    _isarFuture ??= openAppIsar();
    try {
      return await _isarFuture!;
    } catch (_) {
      _isarFuture = null;
      rethrow;
    }
  }

  @override
  Future<void> init() async {
    await _getIsar();
  }

  @override
  Future<List<LikeVerseItem>> loadAll() async {
    final isar = await _getIsar();
    final entities = await isar.likeVerses.where().findAll();
    entities.sort((a, b) => b.id.compareTo(a.id)); // 최근 좋아요가 위
    return entities
        .map((e) => LikeVerseItem(
              book: e.book,
              chapter: e.chapter,
              verse: e.verse,
              content: e.content,
            ))
        .toList();
  }

  @override
  Future<void> upsert(LikeVerseItem item) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      final entity = LikeVerse()
        ..book = item.book
        ..chapter = item.chapter
        ..verse = item.verse
        ..content = item.content;
      await isar.likeVerses.putByBookChapterVerse(entity);
    });
  }

  @override
  Future<void> delete(String book, int chapter, int verse) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.likeVerses.deleteByBookChapterVerse(book, chapter, verse);
    });
  }
}

LikeStore createLikeStore() => IsarLikeStore();

