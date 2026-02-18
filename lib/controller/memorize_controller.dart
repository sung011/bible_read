import 'package:get/get.dart';

import 'package:bible_read/memorize/memorize_store.dart';
import 'package:bible_read/model/memorize_verse_item.dart';

class MemorizeController extends GetxController {
  final MemorizeStore _store = createMemorizeStore();

  final RxList<MemorizeVerseItem> verses = <MemorizeVerseItem>[].obs;
  final RxSet<String> _selectedKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  bool isSelected(String book, int chapter, int verse) =>
      _selectedKeys.contains('$book|$chapter|$verse');

  /// 체크박스 토글:
  /// - 체크하면 Isar DB에 upsert(없으면 insert, 있으면 update)
  /// - 해제하면 Isar DB에서 delete
  ///
  /// ✅ 즉, **현재는 GetStorage가 아니라 Isar(내부 NoSQL DB)에 저장**됩니다.
  Future<void> toggle({
    required String book,
    required int chapter,
    required int verse,
    required String content,
  }) async {
    final cleaned = removeHanjaInParentheses(content).trim();
    final item = MemorizeVerseItem(
      book: book,
      chapter: chapter,
      verse: verse,
      content: cleaned,
    );
    final key = item.key;

    final wasSelected = _selectedKeys.contains(key);
    MemorizeVerseItem? removedItem;

    if (_selectedKeys.contains(key)) {
      _selectedKeys.remove(key);
      removedItem = verses.firstWhereOrNull(
          (v) => v.book == book && v.chapter == chapter && v.verse == verse);
      verses.removeWhere(
          (v) => v.book == book && v.chapter == chapter && v.verse == verse);
    } else {
      _selectedKeys.add(key);
      // 최근에 선택한 성구가 "맨 위"에 보이도록 insert(0)
      verses.insert(0, item);
    }

    try {
      await _store.init();
      if (wasSelected) {
        await _store.delete(book, chapter, verse);
      } else {
        await _store.upsert(item);
      }
    } catch (e) {
      // 저장 실패 시 UI 롤백
      Get.log('MemorizeController store error: $e');
      if (wasSelected) {
        _selectedKeys.add(key);
        if (removedItem != null) {
          verses.insert(0, removedItem);
        }
      } else {
        _selectedKeys.remove(key);
        verses.removeWhere((v) => v.key == key);
      }
      Get.snackbar('오류', '저장에 실패했습니다.');
    }
  }

  Future<void> remove(MemorizeVerseItem item) async {
    _selectedKeys.remove(item.key);
    verses.removeWhere((v) => v.key == item.key);
    try {
      await _store.init();
      await _store.delete(item.book, item.chapter, item.verse);
    } catch (e) {
      Get.log('MemorizeController store error: $e');
    }
  }

  Future<void> clearAll() async {
    _selectedKeys.clear();
    verses.clear();
    try {
      await _store.init();
      await _store.clearAll();
    } catch (e) {
      Get.log('MemorizeController store error: $e');
    }
  }

  /// 앱 시작 시 DB 로드:
  /// 1) Isar DB에서 암송 성구 로드
  /// 2) (최초 1회) 예전 GetStorage 데이터가 있으면 Isar로 마이그레이션 후 삭제
  Future<void> load() async {
    try {
      await _store.init();
    } catch (e) {
      Get.log('MemorizeController store init failed: $e');
      return;
    }

    final items = await _store.loadAll();
    verses.assignAll(items);
    _selectedKeys
      ..clear()
      ..addAll(items.map((e) => e.key));
  }
}

