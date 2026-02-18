import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PracticeController extends GetxController {
  // 옥수색 테마 컬러
  final Color jadeGreen = const Color(0xFF00A86B);

  // 현재 구약이 선택되었는지 여부
  final RxBool isOldTestament = true.obs;

  // 선택된 책
  final RxString selectedBook = ''.obs;

  // 성경 전체 리스트
  final List<String> allBibles = [
    "창세기", "출애굽기", "레위기", "민수기", "신명기", "여호수아", "사사기", "룻기", "사무엘상", "사무엘하",
    "열왕기상", "열왕기하", "역대상", "역대하", "에스라", "느헤미야", "에스더", "욥기", "시편", "잠언",
    "전도서", "아가", "이사야", "예레미야", "예레미야 애가", "에스겔", "다니엘", "호세아", "요엘", "아모스",
    "오바댜", "요나", "미가", "나훔", "하박국", "스바냐", "학개", "스가랴", "말라기", // 구약 39권
    "마태복음", "마가복음", "누가복음", "요한복음", "사도행전", "로마서", "고린도전서", "고린도후서",
    "갈라디아서", "에베소서", "빌립보서", "골로새서", "데살로니가전서", "데살로니가후서", "디모데전서",
    "디모데후서", "디도서", "빌레몬서", "히브리서", "야고보서", "베드로전서", "베드로후서",
    "요한일서", "요한이서", "요한삼서", "유다서", "요한계시록" // 신약 27권
  ];

  // bible.json 데이터 캐시
  List<Map<String, dynamic>>? _bibleData;

  @override
  void onInit() {
    super.onInit();
    _loadBibleData();
  }

  // bible.json 파일에서 데이터 로드
  Future<void> _loadBibleData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/bible/bible.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _bibleData =
          jsonList.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      Get.log('bible.json 로드 실패: $e');
      _bibleData = [];
    }
  }

  // 현재 선택된 상태에 따른 리스트 반환
  List<String> get displayList {
    return isOldTestament.value
        ? allBibles.sublist(0, 39)
        : allBibles.sublist(39);
  }

  // 선택된 책의 장 목록 반환
  List<int> get chapterList {
    if (selectedBook.value.isEmpty || _bibleData == null) {
      return [];
    }

    try {
      // 선택된 책의 모든 항목 필터링
      final bookVerses = _bibleData!
          .where((verse) => verse['book'] == selectedBook.value)
          .toList();

      // 장 번호 추출 및 중복 제거, 정렬
      final chapters = bookVerses
          .map((verse) => verse['chapter'] as int)
          .toSet()
          .toList()
        ..sort();

      return chapters;
    } catch (e) {
      Get.log('장 목록 로드 실패: $e');
      return [];
    }
  }

  // 구약/신약 전환
  void toggleTestament(bool isOld) {
    isOldTestament.value = isOld;
    selectedBook.value = ''; // 전환 시 선택 초기화
  }

  // 성경 선택
  void selectBible(String bibleName) {
    selectedBook.value = bibleName;
    Get.log("$bibleName 선택됨 - 장 목록: ${chapterList.length}개");
  }

  // 선택된 책과 장의 모든 절 반환
  List<Map<String, dynamic>> getVersesByBookAndChapter(
      String book, int chapter) {
    if (_bibleData == null) {
      return [];
    }

    try {
      return _bibleData!
          .where(
              (verse) => verse['book'] == book && verse['chapter'] == chapter)
          .toList()
        ..sort((a, b) => (a['verse'] as int).compareTo(b['verse'] as int));
    } catch (e) {
      Get.log('절 목록 로드 실패: $e');
      return [];
    }
  }

  // 장 선택 및 페이지 이동
  void selectChapter(int chapter) {
    if (selectedBook.value.isEmpty) return;

    Get.toNamed(
      '/chapter-detail',
      arguments: {
        'book': selectedBook.value,
        'chapter': chapter,
      },
    );
  }
}
