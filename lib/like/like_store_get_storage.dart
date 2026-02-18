import 'package:bible_read/model/like_verse_item.dart';
import 'package:get_storage/get_storage.dart';

import 'like_store_base.dart';

/// Web(또는 Isar를 못 쓰는 플랫폼)에서는 GetStorage fallback.
class GetStorageLikeStore implements LikeStore {
  static const String _key = 'liked_verses';
  final GetStorage _storage = GetStorage();

  @override
  Future<void> init() async {
    await GetStorage.init();
  }

  @override
  Future<List<LikeVerseItem>> loadAll() async {
    final raw = _storage.read(_key);
    if (raw is! List) return const [];
    final out = <LikeVerseItem>[];
    final keys = <String>{};
    for (final r in raw) {
      final item = LikeVerseItem.fromJson(r);
      if (item == null) continue;
      if (keys.add(item.key)) out.add(item);
    }
    return out;
  }

  @override
  Future<void> upsert(LikeVerseItem item) async {
    final list = await loadAll();
    list.removeWhere((v) => v.key == item.key);
    list.insert(0, item);
    _storage.write(_key, list.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> delete(String book, int chapter, int verse) async {
    final list = await loadAll();
    list.removeWhere((v) => v.book == book && v.chapter == chapter && v.verse == verse);
    _storage.write(_key, list.map((e) => e.toJson()).toList());
  }
}

LikeStore createLikeStore() => GetStorageLikeStore();

