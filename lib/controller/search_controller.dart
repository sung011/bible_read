import 'dart:async';
import 'dart:convert';

import 'package:bible_read/controller/practice_controller.dart';
import 'package:bible_read/route/route_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BibleSearchController extends GetxController {
  final PracticeController practiceController = Get.find<PracticeController>();

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RxBool loading = true.obs;
  final RxBool searching = false.obs; // 디바운스/검색 수행 중
  final RxString query = ''.obs;
  final RxList<int> resultIndexes = <int>[].obs;

  List<Map<String, dynamic>> _allVerses = const [];
  List<String> _allDisplayContents = const [];
  List<String> _allNormalizedContents = const [];

  Timer? _debounce;

  List<Map<String, dynamic>> get allVerses => _allVerses;
  List<String> get allDisplayContents => _allDisplayContents;

  @override
  void onInit() {
    super.onInit();
    loadBible();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> loadBible() async {
    loading.value = true;
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/bible/bible.json');
      final raw = jsonDecode(jsonString);
      if (raw is! List) {
        throw Exception('bible.json is not a List');
      }

      final verses = raw
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList()
          .cast<Map<String, dynamic>>();

      final display = <String>[];
      final normalized = <String>[];

      for (final v in verses) {
        final content = (v['content'] ?? '').toString();
        final d = _removeHanjaInParentheses(content).trim();
        display.add(d);
        normalized.add(_normalizeForSearch(d));
      }

      _allVerses = verses;
      _allDisplayContents = display;
      _allNormalizedContents = normalized;
    } catch (e) {
      Get.log('BibleSearchController bible.json load failed: $e');
      _allVerses = const [];
      _allDisplayContents = const [];
      _allNormalizedContents = const [];
    } finally {
      loading.value = false;
      // 로딩이 끝난 뒤 현재 query로 즉시 재검색
      runSearch(query.value);
    }
  }

  void onQueryChanged(String value) {
    query.value = value;
    searching.value = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      runSearch(value);
    });
  }

  void clearQuery() {
    textController.clear();
    focusNode.requestFocus();
    searching.value = false;
    onQueryChanged('');
  }

  void setQuery(String value) {
    textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.fromPosition(TextPosition(offset: value.length)),
    );
    onQueryChanged(value);
  }

  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void runSearch(String q) {
    final queryTrimmed = q.trim();
    if (queryTrimmed.isEmpty) {
      resultIndexes.assignAll(const []);
      searching.value = false;
      return;
    }

    final nq = _normalizeForSearch(queryTrimmed);
    if (nq.isEmpty) {
      resultIndexes.assignAll(const []);
      searching.value = false;
      return;
    }

    final hits = <int>[];
    for (var i = 0; i < _allVerses.length; i++) {
      final v = _allVerses[i];
      final book = (v['book'] ?? '').toString();
      final chapter = (v['chapter'] ?? '').toString();
      final verse = (v['verse'] ?? '').toString();

      final contentMatch = _allNormalizedContents[i].contains(nq);

      final ref = '$book $chapter:$verse';
      final refMatch = _normalizeForSearch(ref).contains(nq);

      final bookMatch = _normalizeForSearch(book).contains(nq);

      if (contentMatch || refMatch || bookMatch) {
        hits.add(i);
      }
    }

    resultIndexes.assignAll(hits);
    searching.value = false;
  }

  void openVerse(Map<String, dynamic> v) {
    dismissKeyboard();

    final book = (v['book'] ?? '').toString();
    final chapter = v['chapter'] is int
        ? v['chapter'] as int
        : int.tryParse((v['chapter'] ?? '').toString());
    final verse = v['verse'] is int
        ? v['verse'] as int
        : int.tryParse((v['verse'] ?? '').toString());

    if (book.isEmpty || chapter == null) return;

    Get.toNamed(
      RouteInfo.chapterDetail,
      arguments: {
        'book': book,
        'chapter': chapter,
        // 검색 결과에서 눌렀을 때 해당 절로 자동 스크롤되도록 전달
        if (verse != null) 'verse': verse,
      },
    );
  }

  String _removeHanjaInParentheses(String text) {
    return text.replaceAll(RegExp(r'\([^)]*\)'), '');
  }

  String _normalizeForSearch(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\wㄱ-ㅎ가-힣]'), '');
  }
}

