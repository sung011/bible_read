import 'package:bible_read/model/like_verse_item.dart';

abstract class LikeStore {
  Future<void> init();
  Future<List<LikeVerseItem>> loadAll();
  Future<void> upsert(LikeVerseItem item);
  Future<void> delete(String book, int chapter, int verse);
}

