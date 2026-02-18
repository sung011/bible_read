import 'package:bible_read/db/isar_db.dart';
import 'package:bible_read/db/memorize_verse.dart';
import 'package:bible_read/model/memorize_verse_item.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';

import 'memorize_store_base.dart';

/// 모바일(iOS/Android)에서는 Isar(내부 NoSQL DB) 사용.
class IsarMemorizeStore implements MemorizeStore {
  static const String _legacyKey = 'memorize_verses';
  final GetStorage _storage = GetStorage();

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
    final isar = await _getIsar();
    await _migrateLegacyIfNeeded(isar);
  }

  @override
  Future<List<MemorizeVerseItem>> loadAll() async {
    final isar = await _getIsar();
    final entities = await isar.memorizeVerses.where().findAll();
    entities.sort((a, b) => b.id.compareTo(a.id)); // 최근 저장이 위로
    return entities
        .map((e) => MemorizeVerseItem(
              book: e.book,
              chapter: e.chapter,
              verse: e.verse,
              content: e.content,
            ))
        .toList();
  }

  @override
  Future<void> upsert(MemorizeVerseItem item) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      final entity = MemorizeVerse()
        ..book = item.book
        ..chapter = item.chapter
        ..verse = item.verse
        ..content = item.content;
      await isar.memorizeVerses.putByBookChapterVerse(entity);
    });
  }

  @override
  Future<void> delete(String book, int chapter, int verse) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.memorizeVerses.deleteByBookChapterVerse(book, chapter, verse);
    });
  }

  @override
  Future<void> clearAll() async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.memorizeVerses.clear();
    });
  }

  Future<void> _migrateLegacyIfNeeded(Isar isar) async {
    final legacyRaw = _storage.read(_legacyKey);
    if (legacyRaw is! List || legacyRaw.isEmpty) return;

    // 이미 Isar에 데이터가 있으면 legacy는 삭제만
    final hasAny = await isar.memorizeVerses.where().limit(1).findFirst();
    if (hasAny != null) {
      _storage.remove(_legacyKey);
      return;
    }

    final legacyItems = <MemorizeVerseItem>[];
    for (final r in legacyRaw) {
      final item = MemorizeVerseItem.fromJson(r);
      if (item == null) continue;
      legacyItems.add(item);
    }

    if (legacyItems.isEmpty) {
      _storage.remove(_legacyKey);
      return;
    }

    await isar.writeTxn(() async {
      for (final it in legacyItems) {
        final entity = MemorizeVerse()
          ..book = it.book
          ..chapter = it.chapter
          ..verse = it.verse
          ..content = it.content;
        await isar.memorizeVerses.putByBookChapterVerse(entity);
      }
    });

    _storage.remove(_legacyKey);
  }
}

@override
MemorizeStore createMemorizeStore() => IsarMemorizeStore();

