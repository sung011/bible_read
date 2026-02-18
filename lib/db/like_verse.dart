import 'package:isar/isar.dart';

part 'like_verse.g.dart';

/// 좋아요(하트)로 저장한 성구를 Isar(NoSQL DB)에 저장하기 위한 Entity.
///
/// - (book, chapter, verse)가 유일(unique)하도록 복합 인덱스를 둬서 중복 저장을 막습니다.
@collection
class LikeVerse {
  Id id = Isar.autoIncrement;

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

  // 화면 표시/검색 확장에 대비해서 본문도 같이 저장(한자 괄호 제거된 텍스트)
  late String content;
}

