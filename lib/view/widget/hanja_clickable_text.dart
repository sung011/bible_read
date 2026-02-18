import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 괄호 안 한자(예: 태초(太初)의 太初)를 탭 가능하게 표시하고,
/// 탭하면 assets/json/bible/hanja_map.json 기반으로 상세 풀이 모달을 띄우는 위젯.
class HanjaClickableText extends StatelessWidget {
  const HanjaClickableText({
    super.key,
    required this.text,
    required this.style,
    required this.accentColor,
  });

  final String text;
  final TextStyle style;
  final Color accentColor;

  static Map<String, dynamic>? _cache;
  static Future<void>? _loadFuture;
  // hanja_map.json이 "단어(太初)" 키 중심이라, "(任)" 같은 단일 한자 키가 없을 수 있습니다.
  // 그런 경우를 위해 전체 맵을 한 번 훑어 "한 글자 한자 -> char entry" 인덱스를 구성합니다.
  static Map<String, Map<String, dynamic>>? _charIndex;

  static bool _containsHanja(String s) {
    // - 기본 한자 범위 + CJK Compatibility Ideographs(예: 樂)
    return RegExp(r'[\u3400-\u9FFF\uF900-\uFAFF]').hasMatch(s);
  }

  static Map<String, dynamic> _toStringKeyMap(Map raw) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }

  static Future<Map<String, dynamic>> _loadMap() async {
    if (_cache != null) return _cache!;
    _loadFuture ??= () async {
      final jsonString =
          await rootBundle.loadString('assets/json/bible/hanja_map.json');
      final raw = jsonDecode(jsonString);
      _cache = raw is Map ? raw.map((k, v) => MapEntry(k.toString(), v)) : {};

      // char index build (best-effort)
      final idx = <String, Map<String, dynamic>>{};
      for (final v in (_cache ?? const {}).values) {
        if (v is! Map) continue;
        final entry = _toStringKeyMap(v);
        final rawChars = entry['chars'];
        if (rawChars is! List) continue;
        for (final c in rawChars) {
          if (c is! Map) continue;
          final cm = _toStringKeyMap(c);
          final ch = (cm['hanja'] ?? '').toString();
          if (ch.isEmpty || !_containsHanja(ch)) continue;
          idx.putIfAbsent(ch, () => cm);
        }
      }
      _charIndex = idx;
    }();
    await _loadFuture!;
    return _cache ?? {};
  }

  static String _guessReadingFromCharEntry(Map<String, dynamic> c) {
    final eumList = (c['eum'] is List)
        ? (c['eum'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    if (eumList.isNotEmpty) return eumList.join('/');

    final sensesRaw = c['senses'];
    if (sensesRaw is List && sensesRaw.isNotEmpty) {
      final first = sensesRaw.first;
      if (first is Map) {
        final m = _toStringKeyMap(first);
        final sEumList = (m['eum'] is List)
            ? (m['eum'] as List).map((e) => e.toString()).toList()
            : const <String>[];
        if (sEumList.isNotEmpty) return sEumList.join('/');
      }
    }
    return '';
  }

  Future<void> _showBottomSheet(BuildContext context, String hanja) async {
    final h = hanja.trim();
    if (h.isEmpty) return;

    final map = await _loadMap();
    final entry = map[h];

    String reading = '';
    List<Map<String, dynamic>> chars = const [];
    List<String> wordMeanings = const [];

    Map<String, dynamic>? entryMap;
    if (entry is Map) {
      entryMap = _toStringKeyMap(entry);
    }

    // 1) 기본: 단어 키가 있으면 그대로 사용
    if (entryMap != null) {
      reading = (entryMap['reading'] ?? '').toString();
      final rawChars = entryMap['chars'];
      if (rawChars is List) {
        chars = rawChars
            .whereType<Map>()
            .map((m) => _toStringKeyMap(m))
            .toList()
            .cast<Map<String, dynamic>>();
      }
      // 단어 전체의 뜻(meanings) 추출
      final tempMeanings = <String>[];
      
      // 1) notes 필드에 실제 의미가 있으면 우선 사용 (예: "太初" → "세상이 처음 열린 아주 먼 옛날")
      final notes = (entryMap['notes'] ?? '').toString().trim();
      if (notes.isNotEmpty) {
        tempMeanings.add(notes);
      }
      
      // 2) meanings 배열에 있는 값들 추가
      final rawMeanings = entryMap['meanings'];
      if (rawMeanings is List) {
        for (final m in rawMeanings) {
          final s = m.toString().trim();
          if (s.isNotEmpty && !tempMeanings.contains(s)) {
            tempMeanings.add(s);
          }
        }
      }
      
      // 3) notes나 meanings가 없으면 각 글자의 훈을 조합 (예: "天"(하늘) + "下"(아래) → "하늘 아래")
      if (tempMeanings.isEmpty && chars.isNotEmpty) {
        final combinedHun = <String>[];
        for (final c in chars) {
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

    // 2) 보강: "(任)" 같이 단일/복수 한자지만 키가 없을 때 → 문자 단위 인덱스로 풀이
    if (chars.isEmpty && _containsHanja(h)) {
      final idx = _charIndex ?? const <String, Map<String, dynamic>>{};
      final built = <Map<String, dynamic>>[];
      for (final r in h.runes) {
        final ch = String.fromCharCode(r);
        if (!_containsHanja(ch)) continue;
        final c = idx[ch];
        if (c != null) built.add(c);
      }
      if (built.isNotEmpty) {
        chars = built;
        if (built.length == 1) {
          reading = _guessReadingFromCharEntry(built.first);
        }
      }
    }

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
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
                      reading.trim().isNotEmpty ? '$h : $reading' : h,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
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
                if (chars.isNotEmpty) ...[
                  const Text(
                    '글자 풀이',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ...chars.expand((c) {
                    final ch = (c['hanja'] ?? '').toString();
                    final eumList = (c['eum'] is List)
                        ? (c['eum'] as List).map((e) => e.toString()).toList()
                        : const <String>[];
                    final defaultEum = eumList.isEmpty ? '' : eumList.join('/');

                    final sensesRaw = c['senses'];
                    final senses = (sensesRaw is List)
                        ? sensesRaw
                            .whereType<Map>()
                            .map((m) =>
                                m.map((k, v) => MapEntry(k.toString(), v)))
                            .toList()
                            .cast<Map<String, dynamic>>()
                        : const <Map<String, dynamic>>[];

                    if (senses.isNotEmpty) {
                      return senses.map((s) {
                        final hun = (s['hun'] ?? '').toString();
                        final senseEumList = (s['eum'] is List)
                            ? (s['eum'] as List)
                                .map((e) => e.toString())
                                .toList()
                            : const <String>[];
                        final senseEum = senseEumList.isEmpty
                            ? defaultEum
                            : senseEumList.join('/');
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

                    final hunList = (c['hun'] is List)
                        ? (c['hun'] as List).map((e) => e.toString()).toList()
                        : const <String>[];
                    final hun = hunList.isEmpty ? '' : hunList.join('/');
                    final main = hun.isNotEmpty
                        ? '$ch  $hun  $defaultEum'
                        : '$ch : $defaultEum';

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
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 괄호(...)를 기준으로 파싱하되,
    // 괄호 바로 앞의 마지막 한글 단어도 같이 탭 가능하게 처리합니다.
    //
    // (주의) 일부 본문은 "희락(喜樂)"처럼 호환 한자(樂)가 포함될 수 있어
    // _containsHanja 범위를 확장해둠.
    final spans = <InlineSpan>[];
    final reg = RegExp(r'\(([^)]*)\)');
    var cursor = 0;

    for (final m in reg.allMatches(text)) {
      if (m.start > cursor) {
        final before = text.substring(cursor, m.start);
        final innerPeek = (m.group(1) ?? '').trim();
        final canTapWord = innerPeek.isNotEmpty && _containsHanja(innerPeek);
        final wordMatch = RegExp(r'([가-힣]+)$').firstMatch(before);

        if (canTapWord && wordMatch != null) {
          final prefix = before.substring(0, wordMatch.start);
          final hangulWord = wordMatch.group(1) ?? '';
          if (prefix.isNotEmpty) {
            spans.add(TextSpan(text: prefix, style: style));
          }
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showBottomSheet(context, innerPeek),
                child: Text(
                  hangulWord,
                  style: style.copyWith(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: before, style: style));
        }
      }

      spans.add(TextSpan(text: '(', style: style));

      final inner = (m.group(1) ?? '').trim();
      if (inner.isNotEmpty && _containsHanja(inner)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showBottomSheet(context, inner),
              child: Text(
                inner,
                style: style.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: inner, style: style));
      }

      spans.add(TextSpan(text: ')', style: style));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }

    return Text.rich(TextSpan(children: spans));
  }
}
