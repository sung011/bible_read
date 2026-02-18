import 'package:get/get.dart';
import 'package:bible_read/like/like_store.dart';
import 'package:bible_read/model/like_verse_item.dart';

class LikeScriptureController extends GetxController {
  final LikeStore _store = createLikeStore();

  // 좋아하는 성구 리스트 (최근 좋아요가 위)
  final RxList<LikeVerseItem> likedVerses = <LikeVerseItem>[].obs;
  final RxSet<String> _likedKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadLikedVerses();
  }

  bool isLiked(String book, int chapter, int verse) =>
      _likedKeys.contains('$book|$chapter|$verse');

  // NoSQL(Isar)에서 좋아하는 성구 로드
  Future<void> loadLikedVerses() async {
    try {
      await _store.init();
      final list = await _store.loadAll();
      likedVerses.assignAll(list);
      _likedKeys
        ..clear()
        ..addAll(list.map((e) => e.key));
    } catch (e) {
      Get.log('LikeScriptureController load failed: $e');
    }
  }

  Future<void> toggleLike({
    required String book,
    required int chapter,
    required int verse,
    required String content,
  }) async {
    final cleaned = removeHanjaInParenthesesForLike(content).trim();
    final item = LikeVerseItem(
      book: book,
      chapter: chapter,
      verse: verse,
      content: cleaned,
    );

    final key = item.key;
    final wasLiked = _likedKeys.contains(key);

    // UI 먼저 반영
    if (wasLiked) {
      _likedKeys.remove(key);
      likedVerses.removeWhere((v) => v.key == key);
    } else {
      _likedKeys.add(key);
      likedVerses.insert(0, item);
    }

    try {
      await _store.init();
      if (wasLiked) {
        await _store.delete(book, chapter, verse);
      } else {
        await _store.upsert(item);
      }
    } catch (e) {
      // 실패 시 롤백
      Get.log('LikeScriptureController store error: $e');
      if (wasLiked) {
        _likedKeys.add(key);
        likedVerses.insert(0, item);
      } else {
        _likedKeys.remove(key);
        likedVerses.removeWhere((v) => v.key == key);
      }
      Get.snackbar('오류', '좋아요 저장에 실패했습니다.');
    }
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    await loadLikedVerses();
  }
}




