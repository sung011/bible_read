import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TodayController extends GetxController {
  // UI 바인딩 변수
  final RxString verseContent = '말씀을 불러오는 중...'.obs;
  final RxString verseReference = ''.obs;
  final RxBool isLoading = false.obs;

  // JSON 데이터를 담아둘 리스트 (클래스 대신 Map 사용)
  List<dynamic>? _bibleVerses;
  Timer? _midnightTimer;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initTodayVerse();
    _scheduleMidnightUpdate();
  }

  @override
  void onClose() {
    _midnightTimer?.cancel();
    super.onClose();
  }

  // 초기화: 저장된 날짜 확인 및 로드
  Future<void> _initTodayVerse() async {
    await GetStorage.init(); // 메인 진입 후 여기서 초기화 완료 대기
    String? savedDate = _storage.read('last_update_date');
    String today = DateTime.now().toIso8601String().split('T')[0];

    // 날짜가 바뀌었으면 새로 랜덤 추출, 아니면 저장된 데이터 사용
    if (savedDate != today) {
      await loadRandomVerse();
      _storage.write('last_update_date', today);
    } else {
      verseContent.value = _storage.read('last_content') ?? '';
      verseReference.value = _storage.read('last_reference') ?? '';
    }
  }

  // 자정 자동 갱신 타이머
  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () async {
      await loadRandomVerse();
      _storage.write(
          'last_update_date', tomorrow.toIso8601String().split('T')[0]);
      _scheduleMidnightUpdate(); // 다음 날 자정 재예약
    });
  }

  // 랜덤 말씀 추출 핵심 로직
  Future<void> loadRandomVerse() async {
    isLoading.value = true;
    try {
      if (_bibleVerses == null) {
        final String jsonString =
            await rootBundle.loadString('assets/json/bible/bible.json');
        _bibleVerses = jsonDecode(jsonString) as List<dynamic>;
      }

      if (_bibleVerses != null && _bibleVerses!.isNotEmpty) {
        final random = Random();
        final Map<String, dynamic> selected =
            _bibleVerses![random.nextInt(_bibleVerses!.length)];

        // Map에서 직접 키로 접근
        final content = selected['content'] ?? '';
        final reference =
            "${selected['book']} ${selected['chapter']}:${selected['verse']}";

        verseContent.value = content;
        verseReference.value = reference;

        // 로컬 저장소 업데이트
        _storage.write('last_content', content);
        _storage.write('last_reference', reference);
      }
    } catch (e) {
      Get.log('데이터 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
