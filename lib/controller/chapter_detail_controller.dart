import 'dart:convert';
import 'dart:io' show Platform;
import 'package:bible_read/controller/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;

class ChapterDetailController extends GetxController {
  final PracticeController practiceController = Get.find<PracticeController>();

  // 책과 장 정보
  late final String book;
  late final int chapter;
  int? _initialVerseToScroll;

  // ScrollController
  final ScrollController scrollController = ScrollController();

  // 각 절의 GlobalKey
  final Map<int, GlobalKey> verseKeys = {};

  // Speech to Text
  late stt.SpeechToText _speech;
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;
  final RxBool isMatched = false.obs;
  final RxBool showResult = false.obs;
  final RxDouble matchRate = 0.0.obs; // 0~100 (%)
  String? currentVerseContent;

  // TTS
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;
  bool _ttsHandlersBound = false;
  bool _isSpeaking = false;

  // 모달(듣기/마이크) 선택 상태를 자동 해제하기 위한 콜백
  VoidCallback? _onActionFinishedForModal;

  // --- Hanja map (assets/json/bible/hanja_map.json) ---
  // 한자(太初) -> 한글 후보(["태초", ...]) 형태의 매핑을 로딩해서,
  // 화면에서 한자 부분을 탭하면 모달로 뜻/번역을 보여주기 위한 데이터입니다.
  Map<String, dynamic> _hanjaMap = const {};
  Future<void>? _hanjaLoadFuture;

  // "(任)" 처럼 단일 한자 키가 없을 수 있어, 문자 단위 인덱스를 구성합니다.
  Map<String, Map<String, dynamic>> _hanjaCharIndex = const {};

  void _setOnActionFinishedForModal(VoidCallback? callback) {
    _onActionFinishedForModal = callback;
  }

  void _notifyActionFinishedForModal() {
    _onActionFinishedForModal?.call();
  }

  Future<void> _ensureHanjaMapLoaded() async {
    if (_hanjaMap.isNotEmpty) return;
    _hanjaLoadFuture ??= () async {
      final jsonString =
          await rootBundle.loadString('assets/json/bible/hanja_map.json');
      final raw = jsonDecode(jsonString);
      if (raw is! Map) {
        _hanjaMap = const {};
        _hanjaCharIndex = const {};
        return;
      }

      _hanjaMap = raw.map((k, v) => MapEntry(k.toString(), v));

      // char index build (best-effort)
      final idx = <String, Map<String, dynamic>>{};
      for (final v in _hanjaMap.values) {
        if (v is! Map) continue;
        final entry = v.map((k, val) => MapEntry(k.toString(), val));
        final rawChars = entry['chars'];
        if (rawChars is! List) continue;
        for (final c in rawChars) {
          if (c is! Map) continue;
          final cm = c.map((k, val) => MapEntry(k.toString(), val));
          final ch = (cm['hanja'] ?? '').toString();
          if (ch.isEmpty || !_containsHanja(ch)) continue;
          idx.putIfAbsent(ch, () => cm.cast<String, dynamic>());
        }
      }
      _hanjaCharIndex = idx;
    }();
    await _hanjaLoadFuture!;
  }

  bool _containsHanja(String s) {
    // CJK Unified Ideographs 범위(대부분 한자)
    // - bible.json에는 호환 한자(예: 樂)도 섞여 있어 범위를 확장합니다.
    return RegExp(r'[\u3400-\u9FFF\uF900-\uFAFF]').hasMatch(s);
  }

  String _guessReadingFromCharEntry(Map<String, dynamic> c) {
    final eumList = (c['eum'] is List)
        ? (c['eum'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    if (eumList.isNotEmpty) return eumList.join('/');

    final sensesRaw = c['senses'];
    if (sensesRaw is List && sensesRaw.isNotEmpty) {
      final first = sensesRaw.first;
      if (first is Map) {
        final m = first.map((k, v) => MapEntry(k.toString(), v));
        final sEumList = (m['eum'] is List)
            ? (m['eum'] as List).map((e) => e.toString()).toList()
            : const <String>[];
        if (sEumList.isNotEmpty) return sEumList.join('/');
      }
    }
    return '';
  }

  Future<void> _showHanjaBottomSheet(
    String hanja, {
    BuildContext? context,
  }) async {
    final h = hanja.trim();
    if (h.isEmpty) return;

    await _ensureHanjaMapLoaded();

    final entry = _hanjaMap[h];
    String? wordReading;
    List<Map<String, dynamic>> charEntries = const [];
    List<String> wordMeanings = const [];

    if (entry is Map) {
      wordReading = (entry['reading'] ?? '').toString();
      final rawChars = entry['chars'];
      if (rawChars is List) {
        charEntries = rawChars
            .whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
            .toList()
            .cast<Map<String, dynamic>>();
      }
      // 단어 전체의 뜻(meanings) 추출
      final tempMeanings = <String>[];

      // 1) notes 필드에 실제 의미가 있으면 우선 사용 (예: "太初" → "세상이 처음 열린 아주 먼 옛날")
      final notes = (entry['notes'] ?? '').toString().trim();
      if (notes.isNotEmpty) {
        tempMeanings.add(notes);
      }

      // 2) meanings 배열에 있는 값들 추가
      final rawMeanings = entry['meanings'];
      if (rawMeanings is List) {
        for (final m in rawMeanings) {
          final s = m.toString().trim();
          if (s.isNotEmpty && !tempMeanings.contains(s)) {
            tempMeanings.add(s);
          }
        }
      }

      // 3) notes나 meanings가 없으면 각 글자의 훈을 조합 (예: "天"(하늘) + "下"(아래) → "하늘 아래")
      if (tempMeanings.isEmpty && charEntries.isNotEmpty) {
        final combinedHun = <String>[];
        for (final c in charEntries) {
          final hunList = (c['hun'] is List)
              ? (c['hun'] as List).map((e) => e.toString()).toList()
              : const <String>[];
          if (hunList.isNotEmpty) {
            // 각 글자의 첫 번째 훈을 사용 (가장 일반적인 의미)
            combinedHun.add(hunList.first);
          }
        }
        if (combinedHun.isNotEmpty) {
          final combined = combinedHun.join(' ');
          if (combined.trim().isNotEmpty) {
            tempMeanings.add(combined);
          }
        }
      }

      wordMeanings = tempMeanings;
    }

    // "(任)" 같은 단일/복수 한자 키가 없을 때 → 문자 단위 인덱스로 풀이
    if (charEntries.isEmpty && _containsHanja(h)) {
      final built = <Map<String, dynamic>>[];
      for (final r in h.runes) {
        final ch = String.fromCharCode(r);
        if (!_containsHanja(ch)) continue;
        final c = _hanjaCharIndex[ch];
        if (c != null) built.add(c);
      }
      if (built.isNotEmpty) {
        charEntries = built;
        if (built.length == 1) {
          wordReading = _guessReadingFromCharEntry(built.first);
        }
      }
    }

    final ctx = context ?? Get.context;
    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      wordReading != null && wordReading.trim().isNotEmpty
                          ? '$h : $wordReading'
                          : h,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // 단어 전체의 뜻 표시 (예: "天下" -> "천하", "하늘 아래" 등)
                if (wordMeanings.isNotEmpty) ...[
                  const Text(
                    '단어 풀이',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...wordMeanings.map((meaning) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $meaning',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (charEntries.isNotEmpty) ...[
                  const Text(
                    '글자 풀이',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ...charEntries.expand((c) {
                    final ch = (c['hanja'] ?? '').toString();
                    final eumList = (c['eum'] is List)
                        ? (c['eum'] as List).map((e) => e.toString()).toList()
                        : const <String>[];
                    final eum = eumList.isEmpty ? '' : eumList.join('/');

                    final sensesRaw = c['senses'];
                    final senses = (sensesRaw is List)
                        ? sensesRaw
                            .whereType<Map>()
                            .map((m) =>
                                m.map((k, v) => MapEntry(k.toString(), v)))
                            .toList()
                            .cast<Map<String, dynamic>>()
                        : const <Map<String, dynamic>>[];

                    // senses가 있으면 각 의미를 개별 라인으로 출력
                    if (senses.isNotEmpty) {
                      return senses.map((s) {
                        final hun = (s['hun'] ?? '').toString();
                        final senseEumList = (s['eum'] is List)
                            ? (s['eum'] as List)
                                .map((e) => e.toString())
                                .toList()
                            : const <String>[];
                        final senseEum =
                            senseEumList.isEmpty ? eum : senseEumList.join('/');
                        final note =
                            s['note'] == null ? '' : s['note'].toString();
                        final main = hun.isNotEmpty
                            ? '$ch  $hun  $senseEum'.trim()
                            : '$ch : $senseEum'.trim();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                main,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (note.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    note,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      });
                    }

                    // senses가 없으면 hun 리스트를 하나로 합쳐 출력
                    final hunList = (c['hun'] is List)
                        ? (c['hun'] as List).map((e) => e.toString()).toList()
                        : const <String>[];
                    final hun = hunList.isEmpty ? '' : hunList.join('/');
                    final main =
                        hun.isNotEmpty ? '$ch  $hun  $eum' : '$ch : $eum';
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          main.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    ];
                  }),
                ] else ...[
                  const Text(
                    '이 한자의 번역 데이터가 없습니다.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: `tool/generate_bible_json.dart`로 만든 hanja_map.json은\n'
                    '괄호 앞 한글 단어를 후보로 모은 것이어서, 경우에 따라 누락될 수 있어요.',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 성구 텍스트에서 "(太初)" 같은 괄호 한자 부분만 탭 가능하게 보여줍니다.
  Widget buildHanjaClickableText(
    String content, {
    TextStyle? style,
    BuildContext? context,
  }) {
    final baseStyle = style ??
        const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        );

    final spans = <InlineSpan>[];
    // 괄호(...)를 기준으로 파싱하되, 괄호 바로 앞의 한글 단어도 같이 탭 가능하게 처리합니다.
    // (주의) 일부 본문은 "희락(喜樂)"처럼 호환 한자(樂)가 포함될 수 있어 _containsHanja 범위를 확장해둠.
    final reg = RegExp(r'\(([^)]*)\)');
    var cursor = 0;

    for (final m in reg.allMatches(content)) {
      if (m.start > cursor) {
        final before = content.substring(cursor, m.start);
        // "단어(한자)"에서 괄호 바로 앞의 마지막 한글 단어를 추출
        final wordMatch = RegExp(r'([가-힣]+)$').firstMatch(before);
        final innerPeek = (m.group(1) ?? '').trim();
        final canTapWord = innerPeek.isNotEmpty && _containsHanja(innerPeek);

        if (canTapWord && wordMatch != null) {
          final prefix = before.substring(0, wordMatch.start);
          final hangulWord = wordMatch.group(1) ?? '';
          if (prefix.isNotEmpty) {
            spans.add(TextSpan(text: prefix, style: baseStyle));
          }
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showHanjaBottomSheet(innerPeek, context: context),
                child: Text(
                  hangulWord,
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: before, style: baseStyle));
        }
      }

      spans.add(TextSpan(text: '(', style: baseStyle));

      final inner = (m.group(1) ?? '').trim();
      if (inner.isNotEmpty && _containsHanja(inner)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showHanjaBottomSheet(inner, context: context),
              child: Text(
                inner,
                style: baseStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: inner, style: baseStyle));
      }

      spans.add(TextSpan(text: ')', style: baseStyle));
      cursor = m.end;
    }

    if (cursor < content.length) {
      spans.add(TextSpan(
        text: content.substring(cursor),
        style: baseStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }

  @override
  void onInit() {
    super.onInit();
    // Get.arguments에서 book과 chapter 받기
    final args = Get.arguments as Map<String, dynamic>;
    book = args['book'] as String;
    chapter = args['chapter'] as int;
    _initialVerseToScroll = args['verse'] is int
        ? args['verse'] as int
        : int.tryParse((args['verse'] ?? '').toString());

    // verseKeys 초기화
    final verses = getVerses();
    for (var verse in verses) {
      verseKeys[verse['verse'] as int] = GlobalKey();
    }

    // Speech to Text 초기화
    _speech = stt.SpeechToText();
    _initSpeech();
    _initTts();
  }

  @override
  void onReady() {
    super.onReady();
    final v = _initialVerseToScroll;
    if (v != null) {
      // 첫 빌드 이후에 호출해야 scrollController.hasClients가 true가 되는 경우가 많습니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToVerse(v);
      });
    }
  }

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    _ttsInitialized = true;

    // 사람 말투에 가깝게 들리도록:
    // - 기기에서 제공하는 "더 자연스러운(Enhanced/Neural/Premium)" 한국어 voice를 우선 선택
    // - 너무 빠르지 않게 speechRate 조절
    await _tts.awaitSpeakCompletion(true);

    // 듣기가 "끝났을 때" 토글 하이라이트를 자동으로 지우기 위해 완료/취소/에러 콜백 연결
    if (!_ttsHandlersBound) {
      _ttsHandlersBound = true;
      _tts.setCompletionHandler(() {
        if (!_isSpeaking) return;
        _isSpeaking = false;
        _notifyActionFinishedForModal();
      });
      _tts.setCancelHandler(() {
        if (!_isSpeaking) return;
        _isSpeaking = false;
        _notifyActionFinishedForModal();
      });
      _tts.setErrorHandler((_) {
        if (!_isSpeaking) return;
        _isSpeaking = false;
        _notifyActionFinishedForModal();
      });
    }

    // 오디오 세션/오디오 포커스 설정
    // - iOS: 마이크(음성인식) 세션과 충돌 시 출력이 먹먹/잡음처럼 들릴 수 있어 playback으로 고정
    // - Android: TTS용 오디오 어트리뷰트 지정(다른 스트림과 충돌/잡음 완화에 도움)
    if (GetPlatform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    } else if (GetPlatform.isAndroid) {
      await _tts.setAudioAttributesForNavigation();
    }

    await _tts.setLanguage('ko-KR'); // 한국어
    await _tts.setSpeechRate(0.42); // 말하기 속도(너무 빠르면 기계 같아짐)
    await _tts.setPitch(0.98); // 톤(살짝 낮추면 덜 기계적으로 들리는 편)
    await _tts.setVolume(0.95); // 과한 볼륨은 왜곡/거슬림(잡음)처럼 들릴 수 있어 살짝 낮춤

    await _trySelectBestKoreanVoice();
  }

  Future<void> _trySelectBestKoreanVoice() async {
    try {
      final dynamic voicesDyn = await _tts.getVoices;
      if (voicesDyn is! List) return;

      final koVoices = voicesDyn
          .where((v) {
            if (v is! Map) return false;
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            return locale.startsWith('ko');
          })
          .cast<Map>()
          .toList();

      if (koVoices.isEmpty) return;

      int score(Map v) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final locale = (v['locale'] ?? '').toString().toLowerCase();
        var s = 0;

        // locale 우선순위
        if (locale == 'ko-kr' || locale == 'ko_kr') s += 20;
        if (locale.startsWith('ko')) s += 5;

        // 더 자연스러운 음성 키워드(기기/엔진마다 다를 수 있음)
        if (name.contains('neural')) s += 40;
        if (name.contains('premium')) s += 30;
        if (name.contains('enhanced')) s += 30;
        if (name.contains('wavenet')) s += 25;
        if (name.contains('natural')) s += 20;

        // 너무 "robot" 같은 키워드는 감점(있을 경우)
        if (name.contains('robot')) s -= 10;

        return s;
      }

      koVoices.sort((a, b) => score(b).compareTo(score(a)));
      final best = koVoices.first;

      final bestName = (best['name'] ?? '').toString();
      final bestLocale = (best['locale'] ?? '').toString();
      if (bestName.isEmpty || bestLocale.isEmpty) return;

      await _tts.setVoice({'name': bestName, 'locale': bestLocale});
      Get.log('TTS voice selected: name=$bestName, locale=$bestLocale');
    } catch (e) {
      // 기기/엔진에 따라 getVoices 지원이 다르거나 포맷이 달라질 수 있어 안전하게 무시
      Get.log('TTS voice selection skipped: $e');
    }
  }

  Future<void> speakVerse(String verseContent) async {
    await _initTts(); // 혹시 onInit보다 먼저 호출되는 경우 대비
    // 마이크가 켜진 상태에서 스피커를 틀면(에코/하울링) "잡음"처럼 들릴 수 있어 우선 종료
    stopListening();

    final text = _makeTtsFriendlyText(verseContent);
    Get.log('TTS speak: $text');
    // 기존 재생이 있으면 먼저 끊고, "이번" 재생이 끝났을 때만 토글을 지우도록 상태 갱신
    _isSpeaking = false;
    await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  Future<bool> _initSpeech() async {
    try {
      final ok = await _speech.initialize(
        onError: (error) {
          Get.log('Speech recognition error: $error');
          if (isListening.value) {
            stopListening();
            // 에러로 종료된 경우에도 하이라이트 해제
            _notifyActionFinishedForModal();
          }
        },
        onStatus: (status) {
          Get.log('Speech recognition status: $status');

          // 플러그인이 done/notListening으로 바뀌었는데 UI는 아직 "듣는 중"이면 종료로 처리
          if (!isListening.value) return;
          // notListening은 중간 상태로 들어오는 경우가 있어 너무 빨리 종료될 수 있으니,
          // 실제로 종료를 의미하는 done 상태만 처리합니다.
          if (status == stt.SpeechToText.doneStatus) {
            stopListening();
            if (recognizedText.value.isNotEmpty) {
              compareWithVerse();
            } else {
              showResult.value = false;
            }
            _notifyActionFinishedForModal();
          }
        },
      );
      return ok;
    } catch (e) {
      Get.log('Speech initialization error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    _tts.stop();
    super.onClose();
  }

  // 해당 책과 장의 모든 절 가져오기
  List<Map<String, dynamic>> getVerses() {
    return practiceController.getVersesByBookAndChapter(book, chapter);
  }

  // 특정 절로 스크롤 (화면 가운데로)
  void scrollToVerse(int verseNum) {
    if (!scrollController.hasClients) return;

    final verses = getVerses();
    final index = verses.indexWhere((v) => v['verse'] == verseNum);
    if (index == -1) return;

    // 프레임 완료 후 실행 (렌더링 완료 보장)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final key = verseKeys[verseNum];

      // 방법 1: Scrollable.ensureVisible 시도 (가운데 정렬)
      if (key?.currentContext != null) {
        try {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5, // 화면 가운데
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          );
          return;
        } catch (e) {
          // ensureVisible 실패 시 방법 2로 진행
        }
      }

      // 방법 2: 인덱스 기반 계산으로 화면 가운데에 오도록 스크롤
      final screenHeight = Get.height;
      final appBarHeight = AppBar().preferredSize.height;
      final navigationHeight = 60.0;
      final safeAreaTop = Get.mediaQuery.padding.top;
      final safeAreaBottom = Get.mediaQuery.padding.bottom;

      // 실제 사용 가능한 화면 높이
      final availableHeight = screenHeight -
          appBarHeight -
          navigationHeight -
          safeAreaTop -
          safeAreaBottom;

      // 각 항목의 대략적인 높이 (Container + margin + padding)
      const double itemHeight = 150.0;
      const double padding = 12.0;

      // 항목의 상단 위치
      final itemTop = (index * itemHeight) + padding;

      // 화면 가운데에 오도록 계산
      final targetOffset = itemTop - (availableHeight / 2) + (itemHeight / 2);
      final maxScroll = scrollController.position.maxScrollExtent;

      scrollController.animateTo(
        targetOffset.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // 구절 모달 표시
  void showVerseModal(Map<String, dynamic> verse) {
    // 선택된 버튼 인덱스 (0: 마이크, 1: 듣기, 2: 좋아요, -1: 선택 없음)
    int selectedIndex = -1;
    bool isModalOpen = true;

    // 모달 열 때마다 초기화
    resetRecognition();

    final sheet = showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void clearSelection() {
            if (!isModalOpen) return;
            setState(() {
              selectedIndex = -1;
            });
          }

          // 마이크/듣기가 "자동으로 끝났을 때" 선택 모션(하이라이트) 해제
          _setOnActionFinishedForModal(clearSelection);

          return Obx(
            () => Container(
              height: Get.height * 1,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // 드래그 핸들
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$book $chapter:${verse['verse']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: practiceController.jadeGreen,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // 구절 내용
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHanjaClickableText(
                            (verse['content'] ?? '').toString(),
                            context: context,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.8,
                              color: Colors.black87,
                            ),
                          ),
                          // 음성 인식 결과 표시
                          if (showResult.value &&
                              recognizedText.value.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isMatched.value
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isMatched.value
                                      ? Colors.green.shade300
                                      : Colors.red.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isMatched.value
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isMatched.value
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isMatched.value
                                            ? '정확합니다!'
                                            : '다시 시도해보세요',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isMatched.value
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '인식된 내용:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    recognizedText.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '일치율: ${matchRate.value.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isMatched.value
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 음성 인식 중 표시
                          if (isListening.value)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue.shade700),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '듣고 있습니다...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 하단 ToggleButtons (마이크, 듣기, 좋아요) - 단일 선택 모드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 버튼 2개가 화면 가로를 꽉 채우도록 폭을 균등 분배
                        const gap = 12.0;
                        final buttonWidth = (constraints.maxWidth - gap) / 2.0;

                        return Center(
                          child: ToggleButtons(
                            isSelected: [
                              selectedIndex == 0,
                              selectedIndex == 1,
                            ],
                            onPressed: (index) {
                              setState(() {
                                // 같은 버튼을 다시 누르면 선택 해제, 아니면 해당 버튼만 선택
                                if (selectedIndex == index) {
                                  selectedIndex = -1; // 선택 해제
                                  if (index == 0) {
                                    stopListening();
                                  }
                                  if (index == 1) {
                                    stopSpeaking();
                                  }
                                } else {
                                  selectedIndex = index; // 새로 선택
                                  // 마이크 버튼 클릭 시 음성 인식 시작
                                  if (index == 0) {
                                    // TTS가 켜져 있으면 마이크에 소리가 들어가 "잡음/에코"처럼 될 수 있어 먼저 멈춤
                                    stopSpeaking();
                                    startListening(verse['content'] as String);
                                  }
                                  // 듣기 버튼 클릭 시 해당 성구 읽기
                                  if (index == 1) {
                                    // 마이크가 켜져 있으면 스피커 소리를 함께 들어 잡음처럼 될 수 있어 먼저 멈춤
                                    stopListening();
                                    speakVerse(verse['content'] as String);
                                  }
                                }
                              });
                              // index 2: 좋아요 기능은 추후 DB 저장 등으로 연결
                            },
                            borderRadius: BorderRadius.circular(12),
                            borderColor: Colors.grey.shade300,
                            selectedBorderColor: practiceController.jadeGreen,
                            borderWidth: 1.5,
                            selectedColor: Colors.white,
                            color: Colors.black87,
                            fillColor: practiceController.jadeGreen,
                            constraints: BoxConstraints(
                              minWidth: buttonWidth,
                              minHeight: 56,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.mic, size: 24),
                                    SizedBox(height: 6),
                                    Text(
                                      '마이크',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.volume_up, size: 24),
                                    SizedBox(height: 6),
                                    Text(
                                      '듣기',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    sheet.whenComplete(() {
      isModalOpen = false;
      _setOnActionFinishedForModal(null);
      stopListening();
      stopSpeaking();
    });
  }

  // 괄호 안의 한자 제거
  String removeHanjaInParentheses(String text) {
    return text.replaceAll(RegExp(r'\([^)]*\)'), '');
  }

  // TTS가 더 자연스럽게 읽도록 텍스트를 약간 정리
  String _makeTtsFriendlyText(String text) {
    // 문장부호를 과하게 건드리면(특히 '.'), 기기/엔진에 따라 "쩜"처럼 읽히거나 거슬리는 소리가 날 수 있어
    // 최소한의 정리만 합니다.
    return removeHanjaInParentheses(text)
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // 음성 인식 시작
  void startListening(String verseContent) async {
    if (!await _initSpeech()) {
      Get.snackbar(
        '오류',
        '음성 인식을 사용할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    currentVerseContent = removeHanjaInParentheses(verseContent);
    recognizedText.value = '';
    showResult.value = false;
    isMatched.value = false;
    matchRate.value = 0.0;
    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          stopListening();
          compareWithVerse();
          // 자동 종료(최종 결과) 시 토글 하이라이트 해제
          _notifyActionFinishedForModal();
        }
      },
      localeId: 'ko_KR',
      // 인식 시간 제한(전체 최대 시간)
      listenFor: const Duration(seconds: 90),
      // 사용자가 아무 말도 하지 않거나 말을 멈춘 뒤
      // 2초 동안 추가 입력이 없으면 자동 종료
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
    );
  }

  // 음성 인식 중지
  void stopListening() {
    isListening.value = false;
    _speech.stop();
  }

  // 음성과 성경 구절 비교
  void compareWithVerse() {
    if (currentVerseContent == null || recognizedText.value.isEmpty) {
      showResult.value = false;
      return;
    }

    // 1) 글자 기반 유사도(공백/문장부호 제거) + 2) 단어(띄어쓰기) 기반 커버리지
    // - “하나님이” 같은 단어가 통째로 빠지면 단어 커버리지에서 크게 감점되어 false positive 방지
    final cleanedVerse = _cleanText(currentVerseContent!);
    final cleanedRecognized = _cleanText(recognizedText.value);

    final charSim =
        _calculateSimilarity(cleanedVerse, cleanedRecognized); // 0~1
    final tokenSim = _calculateTokenSimilarity(
        currentVerseContent!, recognizedText.value); // 0~1

    final lenRatio = (cleanedVerse.isEmpty || cleanedRecognized.isEmpty)
        ? 0.0
        : (math.min(cleanedVerse.length, cleanedRecognized.length) /
            math.max(cleanedVerse.length, cleanedRecognized.length));

    // 최종 점수: 글자 70% + 단어 30%, 그리고 길이 비율로 패널티
    double score = (0.7 * charSim) + (0.3 * tokenSim);
    score *= (0.8 + 0.2 * lenRatio); // 길이 차이가 크면 약간 감점

    matchRate.value = (score * 100).clamp(0.0, 100.0);

    // 판정 기준:
    // - 최종 점수 92% 이상
    // - 길이 비율 0.80 이상(너무 많이 빠지면 불일치)
    isMatched.value = score >= 0.90 && lenRatio >= 0.80;
    showResult.value = true;

    Get.log('원문(정제): $cleanedVerse');
    Get.log('인식(정제): $cleanedRecognized');
    Get.log(
        'charSim=${(charSim * 100).toStringAsFixed(1)}%, tokenSim=${(tokenSim * 100).toStringAsFixed(1)}%, lenRatio=${(lenRatio * 100).toStringAsFixed(1)}%, score=${matchRate.value.toStringAsFixed(1)}%');
  }

  // 텍스트 정제 (공백, 문장부호 제거)
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\sㄱ-ㅎ가-힣]'), '') // 특수문자 제거
        .replaceAll(RegExp(r'\s+'), '') // 공백 제거
        .toLowerCase();
  }

  // 레벤슈타인 거리 기반 유사도 계산
  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int distance = _levenshteinDistance(s1, s2);
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLength);
  }

  // 레벤슈타인 거리 계산
  int _levenshteinDistance(String s1, String s2) {
    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // 삭제
          matrix[i][j - 1] + 1, // 삽입
          matrix[i - 1][j - 1] + cost, // 치환
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  // 결과 초기화
  void resetRecognition() {
    recognizedText.value = '';
    showResult.value = false;
    isMatched.value = false;
    matchRate.value = 0.0;
    currentVerseContent = null;
  }

  // 단어(띄어쓰기) 기반 유사도: 토큰 LCS(순서 유지) 기반 커버리지
  double _calculateTokenSimilarity(String verse, String recognized) {
    final a = _tokenizeKorean(verse);
    final b = _tokenizeKorean(recognized);
    if (a.isEmpty || b.isEmpty) return 0.0;

    final lcs = _lcsLength(a, b);
    final verseCoverage = lcs / a.length; // 정답 대비 얼마나 맞췄는지
    final recogCoverage = lcs / b.length; // 말한 내용 중 얼마나 정답에 포함되는지
    return ((verseCoverage + recogCoverage) / 2).clamp(0.0, 1.0);
  }

  List<String> _tokenizeKorean(String text) {
    // 한자 괄호 제거 후, 공백은 살리고 특수문자만 제거
    final s = removeHanjaInParentheses(text)
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'[^\w\sㄱ-ㅎ가-힣]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (s.isEmpty) return const [];
    return s.split(' ').where((t) => t.trim().isNotEmpty).toList();
  }

  int _lcsLength(List<String> a, List<String> b) {
    // 토큰 수가 크지 않아서 O(n*m) DP로 충분
    final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }
    return dp[a.length][b.length];
  }
}
