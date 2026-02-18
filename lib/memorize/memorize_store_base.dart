import 'package:bible_read/model/memorize_verse_item.dart';

abstract class MemorizeStore {
  Future<void> init();
  Future<List<MemorizeVerseItem>> loadAll();
  Future<void> upsert(MemorizeVerseItem item);
  Future<void> delete(String book, int chapter, int verse);
  Future<void> clearAll();
}

