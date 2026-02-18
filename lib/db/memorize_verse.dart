import 'package:isar/isar.dart';

part 'memorize_verse.g.dart';

/// 암송(체크박스 선택)한 성구를 Isar(내부 NoSQL DB)에 저장하기 위한 Entity.
///
/// - book/chapter/verse 조합이 **유일(unique)** 해야 중복 저장이 안 됩니다.
/// - 그래서 book에 복합(unique) 인덱스를 걸어서 (book, chapter, verse)로 유니크 처리합니다.
@collection
class MemorizeVerse {
  Id id = Isar.autoIncrement;

  // (book, chapter, verse) 복합 유니크 인덱스
  @Index(
    unique: true,
    composite: [
      CompositeIndex('chapter'),
      CompositeIndex('verse'),
    ],
  )
  late String book;

  late int chapter;
  late int verse;

  // 화면 표시/암송용 본문(한자 괄호 제거된 텍스트 저장)
  late String content;
}

