import 'package:bible_read/model/memorize_verse_item.dart';
import 'package:get_storage/get_storage.dart';

import 'memorize_store_base.dart';

// Web(또는 Isar를 못 쓰는 플랫폼)에서는 GetStorage로 fallback 합니다.
// - 데이터 구조는 기존 legacy 키와 동일하게 유지해서 호환됩니다.
class GetStorageMemorizeStore implements MemorizeStore {
  static const String _key = 'memorize_verses';
  final GetStorage _storage = GetStorage();

  @override
  Future<void> init() async {
    await GetStorage.init();
  }

  @override
  Future<List<MemorizeVerseItem>> loadAll() async {
    final raw = _storage.read(_key);
    if (raw is! List) return const [];
    final out = <MemorizeVerseItem>[];
    final keys = <String>{};
    for (final r in raw) {
      final item = MemorizeVerseItem.fromJson(r);
      if (item == null) continue;
      if (keys.add(item.key)) out.add(item);
    }
    return out;
  }

  @override
  Future<void> upsert(MemorizeVerseItem item) async {
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

  @override
  Future<void> clearAll() async {
    _storage.remove(_key);
  }
}

@override
MemorizeStore createMemorizeStore() => GetStorageMemorizeStore();

