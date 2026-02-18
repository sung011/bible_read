import 'package:get/get.dart';
import 'package:bible_read/controller/memorize_controller.dart';
import 'package:bible_read/model/memorize_verse_item.dart';

class StudyScriptureItem {
  final String content;
  final String book;
  final int chapter;
  final int verse;

  StudyScriptureItem({
    required this.content,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  String get reference => '$book $chapter:$verse';
}

class StudyScriptureController extends GetxController {
  // 최근 학습한 성구 리스트
  final RxList<StudyScriptureItem> studyVerses = <StudyScriptureItem>[].obs;
  late MemorizeController _memorizeController;
  Worker? _memorizeWorker;

  @override
  void onInit() {
    super.onInit();
    // 필드 초기화 시점이 아니라 onInit에서 찾아야, Binding 주입 순서 문제로 크래시가 나지 않습니다.
    _memorizeController = Get.find<MemorizeController>();

    // "암송 체크(체크박스)"한 성구를 최근 학습 리스트에 바로 반영
    _memorizeWorker = ever<List<MemorizeVerseItem>>(
      _memorizeController.verses,
      (list) => _syncFromMemorize(list),
    );
    loadStudyVerses();
  }

  @override
  void onClose() {
    _memorizeWorker?.dispose();
    super.onClose();
  }

  // DB에서 최근 학습한 성구 로드
  Future<void> loadStudyVerses() async {
    // 현재 앱에서는 "암송 체크한 성구"를 최근 학습 리스트로 사용합니다.
    // (추후 별도 '학습' DB를 만들면 여기에서 DB를 읽어오도록 확장하면 됩니다.)
    _syncFromMemorize(_memorizeController.verses);
  }

  void _syncFromMemorize(List<MemorizeVerseItem> list) {
    // 체크된 성구 목록을 "최근 학습한 성구" 리스트에 그대로 매핑
    studyVerses.assignAll(
      list.map(
        (v) => StudyScriptureItem(
          content: v.content,
          book: v.book,
          chapter: v.chapter,
          verse: v.verse,
        ),
      ),
    );
  }

  // 학습한 성구 추가
  void addStudyVerse(StudyScriptureItem verse) {
    studyVerses.insert(0, verse); // 최신이 맨 위로
    // TODO: DB에 저장
  }

  // 학습한 성구 제거
  void removeStudyVerse(int index) {
    studyVerses.removeAt(index);
    // TODO: DB에서 삭제
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    await loadStudyVerses();
  }
}




