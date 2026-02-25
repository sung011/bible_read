import 'dart:convert';

import 'package:bible_read/model/memorize_verse_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'memorize_store_base.dart';

/// iOS: SharedPreferences로 암송(저장) 데이터 저장 (iOS에서 저장이 안정적으로 동작).
class SharedPrefsMemorizeStore implements MemorizeStore {
  static const String _key = 'memorize_verses';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> init() async {
    await _getPrefs();
  }

  @override
  Future<List<MemorizeVerseItem>> loadAll() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List?;
      if (list == null) return [];
      final out = <MemorizeVerseItem>[];
      final keys = <String>{};
      for (final r in list) {
        final item = MemorizeVerseItem.fromJson(r);
        if (item == null) continue;
        if (keys.add(item.key)) out.add(item);
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> upsert(MemorizeVerseItem item) async {
    final list = await loadAll();
    list.removeWhere((v) => v.key == item.key);
    list.insert(0, item);
    final prefs = await _getPrefs();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> delete(String book, int chapter, int verse) async {
    final list = await loadAll();
    list.removeWhere((v) => v.book == book && v.chapter == chapter && v.verse == verse);
    final prefs = await _getPrefs();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}

MemorizeStore createMemorizeStore() => SharedPrefsMemorizeStore();
