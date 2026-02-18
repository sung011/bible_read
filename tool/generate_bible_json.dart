import 'dart:convert';
import 'dart:io';

/// bible.json의 ( ) 안 한자를 일괄 처리해 "새 json"을 만드는 스크립트입니다.
///
/// 생성 파일:
/// 1) assets/json/bible/bible_clean.json
///    - 기존과 동일한 구조(List<Map>)인데
///    - content에서 괄호(...) 부분을 제거한 "한글 전용" content로 저장
///
/// 2) assets/json/bible/hanja_map.json
///    - 한자 단어 -> (단어 음독 + 글자별 훈/음/뜻) 형태
///    - 예:
///      {
///        "水面": {
///          "word": "水面",
///          "reading": "수면",
///          "notes": null,
///          "chars": [
///            {"hanja":"水","eum":["수"],"hun":["물"],"senses":[{"hun":"물","note":null}]},
///            {"hanja":"面","eum":["면"],"hun":["낯","밀가루"],"senses":[{"hun":"낯","note":"얼굴/겉"},{"hun":"밀가루","note":"가루/국수 의미"}]}
///          ]
///        }
///      }
///
/// 실행:
///   dart run tool/generate_bible_json.dart
void main() async {
  final input = File('assets/json/bible/bible.json');
  if (!input.existsSync()) {
    stderr.writeln('Input not found: ${input.path}');
    exit(1);
  }

  // 한자 글자 사전(훈/음) CSV (오프라인)
  // - rycont/hanja-grade-dataset 의 hanja.csv 를 tool/data/hanja.csv 로 다운받아둔 파일
  // - 이 데이터가 있어야 面:낯 면 / 行:다닐 행, 항렬 항 처럼 "훈/음"을 상세히 채울 수 있습니다.
  final hanjaCsv = File('tool/data/hanja.csv');
  // CJK 호환 한자(예: 樂, 勞 등)를 정규 한자(樂, 勞 등)로 매핑하는 파일
  // - python3(unicodedata.normalize NFKC)로 `tool/data/hanja_compat_map.json` 생성
  final compatMapFile = File('tool/data/hanja_compat_map.json');

  final raw = jsonDecode(input.readAsStringSync());
  if (raw is! List) {
    stderr.writeln('bible.json is not a List');
    exit(1);
  }

  final parenRegex = RegExp(r'\([^)]*\)');
  // "태초(太初)" 같은 패턴에서 "태초"와 "太初"를 뽑아 매핑에 사용
  // - bible.json에는 종종 호환 한자(예: 樂: U+F95C)가 섞여 있어 아래 범위를 포함합니다.
  final pairRegex = RegExp(r'([가-힣]+)\(([\u3400-\u9FFF\uF900-\uFAFF]+)\)');

  final cleanedList = <Map<String, dynamic>>[];
  // hanja -> (hangul word -> count)
  final counts = <String, Map<String, int>>{};

  for (final item in raw) {
    if (item is! Map) continue;
    final m = item.map((k, v) => MapEntry(k.toString(), v));

    final content = (m['content'] ?? '').toString();
    final clean = content
        .replaceAll(parenRegex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 한자-한글 매핑 수집
    for (final match in pairRegex.allMatches(content)) {
      final hangul = match.group(1) ?? '';
      final hanja = match.group(2) ?? '';
      if (hangul.isEmpty || hanja.isEmpty) continue;
      final inner = counts.putIfAbsent(hanja, () => <String, int>{});
      inner[hangul] = (inner[hangul] ?? 0) + 1;
    }

    cleanedList.add({
      'book': m['book'],
      'chapter': m['chapter'],
      'verse': m['verse'],
      'content': clean,
    });
  }

  final outDir = Directory('assets/json/bible');
  outDir.createSync(recursive: true);

  final cleanOut = File('${outDir.path}/bible_clean.json');
  cleanOut.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(cleanedList));

  final hanjaOut = File('${outDir.path}/hanja_map.json');
  final hanjaMapJson = <String, dynamic>{};

  List<String> _splitHangulSyllables(String s) =>
      s.runes.map((r) => String.fromCharCode(r)).toList();

  List<String> _splitHanjaChars(String s) =>
      s.runes.map((r) => String.fromCharCode(r)).toList();

  // 호환 한자 -> 정규 한자 매핑 로드 (없으면 빈 맵)
  Map<String, String> loadCompatMap(File f) {
    if (!f.existsSync()) return {};
    try {
      final raw = jsonDecode(f.readAsStringSync());
      if (raw is! Map) return {};
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  final compatMap = loadCompatMap(compatMapFile);
  String normalizeCompatChar(String ch) => compatMap[ch] ?? ch;

  String? _bestByCount(Map<String, int> m) {
    if (m.isEmpty) return null;
    final entries = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  /// CSV에서 한자 글자 사전을 만들어 (hun/eum/senses)를 채웁니다.
  ///
  /// hanja.csv의 meaning 컬럼은 아래 같은 형태(문자열)입니다:
  /// - [[['낯'], ['면']]]
  /// - [[['다닐'], ['행']], [['항렬'], ['항']]]
  ///
  /// => senses = [{hun:'낯', eum:['면'], note:null}, ...] 로 변환
  Map<String, Map<String, dynamic>> buildCharDictFromCsv(File csvFile) {
    if (!csvFile.existsSync()) {
      stderr.writeln('WARNING: hanja.csv not found: ${csvFile.path}');
      return {};
    }

    final text = csvFile.readAsStringSync();
    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty) return {};

    // 간단 CSV 파서 (따옴표 포함 케이스를 최대한 안전하게 처리)
    List<String> splitCsvLine(String line) {
      final out = <String>[];
      final buf = StringBuffer();
      var inQuotes = false;
      for (var i = 0; i < line.length; i++) {
        final ch = line[i];
        if (ch == '"') {
          inQuotes = !inQuotes;
          continue;
        }
        if (ch == ',' && !inQuotes) {
          out.add(buf.toString());
          buf.clear();
          continue;
        }
        buf.write(ch);
      }
      out.add(buf.toString());
      return out;
    }

    final header = splitCsvLine(lines.first);
    int idx(String name) => header.indexOf(name);
    final hanjaIdx = idx('hanja');
    final meaningIdx = idx('meaning');
    final mainSoundIdx = idx('main_sound');

    if (hanjaIdx < 0 || meaningIdx < 0) {
      stderr.writeln('WARNING: hanja.csv missing required columns');
      return {};
    }

    final dict = <String, Map<String, dynamic>>{};

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cols = splitCsvLine(line);
      if (cols.length <= hanjaIdx) continue;
      final hanja = cols[hanjaIdx].trim();
      if (hanja.isEmpty) continue;

      final meaningRaw =
          (cols.length > meaningIdx ? cols[meaningIdx] : '').trim();
      final mainSound =
          (mainSoundIdx >= 0 && cols.length > mainSoundIdx)
              ? cols[mainSoundIdx].trim()
              : '';

      final senses = <Map<String, dynamic>>[];
      final hunSet = <String>{};
      final eumSet = <String>{};

      if (meaningRaw.isNotEmpty && meaningRaw.toLowerCase() != 'none') {
        try {
          // python-literal 스타일의 single quote 리스트를 json으로 변환
          final jsonLike = meaningRaw.replaceAll("'", '"');
          final decoded = jsonDecode(jsonLike);
          if (decoded is List) {
            for (final sense in decoded) {
              if (sense is! List || sense.length < 2) continue;
              final hunList = (sense[0] is List)
                  ? (sense[0] as List).map((e) => e.toString()).toList()
                  : <String>[];
              final eumList = (sense[1] is List)
                  ? (sense[1] as List).map((e) => e.toString()).toList()
                  : <String>[];

              for (final h in hunList) {
                if (h.trim().isNotEmpty) hunSet.add(h.trim());
              }
              for (final e in eumList) {
                if (e.trim().isNotEmpty) eumSet.add(e.trim());
              }

              // hunList가 여러 개인 경우 '/'로 합쳐서 한 줄 의미로 저장
              final hunStr = hunList.where((s) => s.trim().isNotEmpty).join('/');
              if (hunStr.isNotEmpty) {
                senses.add({
                  'hun': hunStr,
                  'eum': eumList.where((s) => s.trim().isNotEmpty).toList(),
                  'note': null,
                });
              }
            }
          }
        } catch (_) {
          // 파싱 실패 시 무시
        }
      }

      // meaning이 없더라도 main_sound(대표 음독)이 있으면 eum으로 채움
      if (eumSet.isEmpty && mainSound.isNotEmpty) {
        eumSet.add(mainSound);
      }

      dict[hanja] = {
        'eum': eumSet.toList()..sort(),
        'hun': hunSet.toList()..sort(),
        'senses': senses,
      };
    }

    // dataset에 없는(혹은 누락되는) 글자들은 최소 수동 보강
    // 또는 CSV 데이터가 부정확한 경우 수정
    dict.putIfAbsent('不', () => {
          'eum': ['불'],
          'hun': ['아닐'],
          'senses': [
            {'hun': '아닐', 'eum': ['불'], 'note': null}
          ],
        });
    dict.putIfAbsent('車', () => {
          'eum': ['차'],
          'hun': ['수레'],
          'senses': [
            {'hun': '수레', 'eum': ['차'], 'note': null}
          ],
        });
    dict.putIfAbsent('率', () => {
          'eum': ['솔', '율'],
          'hun': ['거느릴', '비율'],
          'senses': [
            {'hun': '거느릴', 'eum': ['솔'], 'note': null},
            {'hun': '비율', 'eum': ['율'], 'note': null},
          ],
        });
    dict.putIfAbsent('樂', () => {
          'eum': ['락', '악'],
          'hun': ['즐거울', '풍류'],
          'senses': [
            {'hun': '즐거울', 'eum': ['락'], 'note': null},
            {'hun': '음악', 'eum': ['악'], 'note': null},
          ],
        });
    dict.putIfAbsent('塞', () => {
          'eum': ['색', '새'],
          'hun': ['막힐', '변방'],
          'senses': [
            {'hun': '막힐', 'eum': ['색'], 'note': null},
            {'hun': '변방', 'eum': ['새'], 'note': null},
          ],
        });
    dict.putIfAbsent('奬', () => {
          'eum': ['장'],
          'hun': ['장려할'],
          'senses': [
            {'hun': '장려할', 'eum': ['장'], 'note': null}
          ],
        });
    // "地"는 CSV에서 "따"로 되어 있지만, 표준적으로는 "땅"이 맞음
    dict['地'] = {
      'eum': ['지'],
      'hun': ['땅'],
      'senses': [
        {'hun': '땅', 'eum': ['지'], 'note': null}
      ],
    };
    // "面"은 "낯" 외에도 "밀가루" 의미가 있음
    if (dict.containsKey('面')) {
      final existing = dict['面']!;
      final hunList = (existing['hun'] as List).map((e) => e.toString()).toList();
      if (!hunList.contains('밀가루')) {
        hunList.add('밀가루');
        final senses = (existing['senses'] as List).cast<Map<String, dynamic>>();
        senses.add({
          'hun': '밀가루',
          'eum': ['면'],
          'note': '가루/국수 의미'
        });
        dict['面'] = {
          'eum': existing['eum'],
          'hun': hunList,
          'senses': senses,
        };
      }
    }

    return dict;
  }

  final charDict = buildCharDictFromCsv(hanjaCsv);

  // 주요 한자 단어의 실제 의미 사전 (notes 필드에 저장)
  // 필요에 따라 계속 추가 가능
  final wordDefinitions = <String, String>{
    '太初': '세상이 처음 열린 아주 먼 옛날',
    '天地': '하늘과 땅, 천지',
    '創造': '처음으로 만들어냄',
    '水面': '물의 표면',
    '天下': '하늘 아래, 온 세상',
    '喜樂': '기쁨과 즐거움',
    '和平': '화목하고 평화로움',
    '生命': '살아있는 생명',
    '智慧': '지혜',
    '知識': '알고 있는 지식',
    '記憶': '기억',
    '節期': '절기',
    '月朔': '초하루',
    '燔祭物': '번제물',
    '和睦': '화목',
    '祭物': '제물',
    '食物': '먹을 음식',
    '無花果': '무화과',
    '葡萄酒': '포도주',
    '城邑': '성읍',
    '榮光': '영광',
    '贖良': '속량',
    '萬代': '만대',
    '命定': '명정',
    '基礎': '기초',
    '萬軍': '만군',
    '禁食': '금식',
    '眞實': '진실',
    '舞蹈': '무도',
    '哀痛': '애통',
    '廢': '폐',
    '安息日': '안식일',
    '名節': '명절',
    '混沌': '마구 뒤섞여 있어 갈피를 잡을 수 없는 무질서한 상태',
    '空虛': '비어 있고 텅 빈 상태',
    '黑暗': '어둡고 캄캄함',
    '運行': '움직여 다님, 돌아감',
    '運行': '움직여 다님, 돌아감',
    '知覺': '알아차림, 느낌',
    '空虛': '비어 있고 텅 빈 상태',
  };

  for (final e in counts.entries) {
    final hanjaWord = e.key;
    final candidates = e.value;
    final hanjaChars = _splitHanjaChars(hanjaWord);

    final readingCounts = <String, int>{};
    final meaningCounts = <String, int>{};

    for (final kv in candidates.entries) {
      final hangul = kv.key;
      final cnt = kv.value;
      final syllables = _splitHangulSyllables(hangul).length;
      if (syllables == hanjaChars.length) {
        readingCounts[hangul] = (readingCounts[hangul] ?? 0) + cnt;
      } else {
        meaningCounts[hangul] = (meaningCounts[hangul] ?? 0) + cnt;
      }
    }

    // 대표 reading은 "길이 일치(음독)" 후보 중 최빈값으로 선택
    final reading = _bestByCount(readingCounts);

    // chars 분해: 대표 reading이 있으면 1:1로 글자-음독 매핑
    final charEntries = <Map<String, dynamic>>[];
    final readingSyllables =
        reading == null ? <String>[] : _splitHangulSyllables(reading);

    for (var i = 0; i < hanjaChars.length; i++) {
      final ch = hanjaChars[i];
      final inferredEum =
          (i < readingSyllables.length) ? readingSyllables[i] : null;
      // 호환 한자는 정규 한자로 변환해서 사전(훈/음) 조회
      final lookup = normalizeCompatChar(ch);
      final info = charDict[lookup] ?? const <String, dynamic>{};
      final infoEum = (info['eum'] is List)
          ? (info['eum'] as List).map((e) => e.toString()).toList()
          : <String>[];
      final infoHun = (info['hun'] is List)
          ? (info['hun'] as List).map((e) => e.toString()).toList()
          : <String>[];
      final infoSenses = (info['senses'] is List)
          ? (info['senses'] as List)
              .whereType<Map>()
              .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
              .toList()
              .cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];

      charEntries.add({
        'hanja': ch,
        // 글자 음독: 사전(eum) 우선, 없으면 단어 reading에서 추정한 글자 음독 사용
        'eum': infoEum.isNotEmpty
            ? infoEum
            : (inferredEum == null ? <String>[] : <String>[inferredEum]),
        'hun': infoHun,
        'senses': infoSenses,
        if (lookup != ch) 'normalized': lookup,
      });
    }

    List<String> _sortedKeysByCount(Map<String, int> m) {
      final entries = m.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return entries.map((e) => e.key).toList();
    }

    // 요청한 구조(예시)로 저장
    // notes 필드: 주요 단어의 실제 의미 (wordDefinitions에서 가져옴)
    hanjaMapJson[hanjaWord] = {
      'word': hanjaWord,
      'reading': reading,
      'notes': wordDefinitions[hanjaWord],
      'chars': charEntries,
      // 디버깅/확장용(원하면 앱에서 숨기면 됨)
      'readings': _sortedKeysByCount(readingCounts),
      'meanings': _sortedKeysByCount(meaningCounts),
    };
  }

  hanjaOut.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(hanjaMapJson));

  stdout.writeln('Done.');
  stdout.writeln('- ${cleanOut.path} (${cleanedList.length} verses)');
  stdout.writeln('- ${hanjaOut.path} (${hanjaMapJson.length} hanja entries)');
}

