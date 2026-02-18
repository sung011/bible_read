// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_verse.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLikeVerseCollection on Isar {
  IsarCollection<LikeVerse> get likeVerses => this.collection();
}

const LikeVerseSchema = CollectionSchema(
  name: r'LikeVerse',
  id: -4944544261332606981,
  properties: {
    r'book': PropertySchema(
      id: 0,
      name: r'book',
      type: IsarType.string,
    ),
    r'chapter': PropertySchema(
      id: 1,
      name: r'chapter',
      type: IsarType.long,
    ),
    r'content': PropertySchema(
      id: 2,
      name: r'content',
      type: IsarType.string,
    ),
    r'verse': PropertySchema(
      id: 3,
      name: r'verse',
      type: IsarType.long,
    )
  },
  estimateSize: _likeVerseEstimateSize,
  serialize: _likeVerseSerialize,
  deserialize: _likeVerseDeserialize,
  deserializeProp: _likeVerseDeserializeProp,
  idName: r'id',
  indexes: {
    r'book_chapter_verse': IndexSchema(
      id: -9202441771574013676,
      name: r'book_chapter_verse',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'book',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'chapter',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'verse',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _likeVerseGetId,
  getLinks: _likeVerseGetLinks,
  attach: _likeVerseAttach,
  version: '3.1.0+1',
);

int _likeVerseEstimateSize(
  LikeVerse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.book.length * 3;
  bytesCount += 3 + object.content.length * 3;
  return bytesCount;
}

void _likeVerseSerialize(
  LikeVerse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.book);
  writer.writeLong(offsets[1], object.chapter);
  writer.writeString(offsets[2], object.content);
  writer.writeLong(offsets[3], object.verse);
}

LikeVerse _likeVerseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LikeVerse();
  object.book = reader.readString(offsets[0]);
  object.chapter = reader.readLong(offsets[1]);
  object.content = reader.readString(offsets[2]);
  object.id = id;
  object.verse = reader.readLong(offsets[3]);
  return object;
}

P _likeVerseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _likeVerseGetId(LikeVerse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _likeVerseGetLinks(LikeVerse object) {
  return [];
}

void _likeVerseAttach(IsarCollection<dynamic> col, Id id, LikeVerse object) {
  object.id = id;
}

extension LikeVerseByIndex on IsarCollection<LikeVerse> {
  Future<LikeVerse?> getByBookChapterVerse(
      String book, int chapter, int verse) {
    return getByIndex(r'book_chapter_verse', [book, chapter, verse]);
  }

  LikeVerse? getByBookChapterVerseSync(String book, int chapter, int verse) {
    return getByIndexSync(r'book_chapter_verse', [book, chapter, verse]);
  }

  Future<bool> deleteByBookChapterVerse(String book, int chapter, int verse) {
    return deleteByIndex(r'book_chapter_verse', [book, chapter, verse]);
  }

  bool deleteByBookChapterVerseSync(String book, int chapter, int verse) {
    return deleteByIndexSync(r'book_chapter_verse', [book, chapter, verse]);
  }

  Future<List<LikeVerse?>> getAllByBookChapterVerse(
      List<String> bookValues, List<int> chapterValues, List<int> verseValues) {
    final len = bookValues.length;
    assert(chapterValues.length == len && verseValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([bookValues[i], chapterValues[i], verseValues[i]]);
    }

    return getAllByIndex(r'book_chapter_verse', values);
  }

  List<LikeVerse?> getAllByBookChapterVerseSync(
      List<String> bookValues, List<int> chapterValues, List<int> verseValues) {
    final len = bookValues.length;
    assert(chapterValues.length == len && verseValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([bookValues[i], chapterValues[i], verseValues[i]]);
    }

    return getAllByIndexSync(r'book_chapter_verse', values);
  }

  Future<int> deleteAllByBookChapterVerse(
      List<String> bookValues, List<int> chapterValues, List<int> verseValues) {
    final len = bookValues.length;
    assert(chapterValues.length == len && verseValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([bookValues[i], chapterValues[i], verseValues[i]]);
    }

    return deleteAllByIndex(r'book_chapter_verse', values);
  }

  int deleteAllByBookChapterVerseSync(
      List<String> bookValues, List<int> chapterValues, List<int> verseValues) {
    final len = bookValues.length;
    assert(chapterValues.length == len && verseValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([bookValues[i], chapterValues[i], verseValues[i]]);
    }

    return deleteAllByIndexSync(r'book_chapter_verse', values);
  }

  Future<Id> putByBookChapterVerse(LikeVerse object) {
    return putByIndex(r'book_chapter_verse', object);
  }

  Id putByBookChapterVerseSync(LikeVerse object, {bool saveLinks = true}) {
    return putByIndexSync(r'book_chapter_verse', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBookChapterVerse(List<LikeVerse> objects) {
    return putAllByIndex(r'book_chapter_verse', objects);
  }

  List<Id> putAllByBookChapterVerseSync(List<LikeVerse> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'book_chapter_verse', objects,
        saveLinks: saveLinks);
  }
}

extension LikeVerseQueryWhereSort
    on QueryBuilder<LikeVerse, LikeVerse, QWhere> {
  QueryBuilder<LikeVerse, LikeVerse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LikeVerseQueryWhere
    on QueryBuilder<LikeVerse, LikeVerse, QWhereClause> {
  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookEqualToAnyChapterVerse(String book) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'book_chapter_verse',
        value: [book],
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookNotEqualToAnyChapterVerse(String book) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [],
              upper: [book],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [],
              upper: [book],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookChapterEqualToAnyVerse(String book, int chapter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'book_chapter_verse',
        value: [book, chapter],
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookEqualToChapterNotEqualToAnyVerse(String book, int chapter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book],
              upper: [book, chapter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter],
              includeLower: false,
              upper: [book],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter],
              includeLower: false,
              upper: [book],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book],
              upper: [book, chapter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookEqualToChapterGreaterThanAnyVerse(
    String book,
    int chapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book, chapter],
        includeLower: include,
        upper: [book],
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookEqualToChapterLessThanAnyVerse(
    String book,
    int chapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book],
        upper: [book, chapter],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookEqualToChapterBetweenAnyVerse(
    String book,
    int lowerChapter,
    int upperChapter, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book, lowerChapter],
        includeLower: includeLower,
        upper: [book, upperChapter],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause> bookChapterVerseEqualTo(
      String book, int chapter, int verse) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'book_chapter_verse',
        value: [book, chapter, verse],
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookChapterEqualToVerseNotEqualTo(String book, int chapter, int verse) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter],
              upper: [book, chapter, verse],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter, verse],
              includeLower: false,
              upper: [book, chapter],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter, verse],
              includeLower: false,
              upper: [book, chapter],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'book_chapter_verse',
              lower: [book, chapter],
              upper: [book, chapter, verse],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookChapterEqualToVerseGreaterThan(
    String book,
    int chapter,
    int verse, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book, chapter, verse],
        includeLower: include,
        upper: [book, chapter],
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookChapterEqualToVerseLessThan(
    String book,
    int chapter,
    int verse, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book, chapter],
        upper: [book, chapter, verse],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterWhereClause>
      bookChapterEqualToVerseBetween(
    String book,
    int chapter,
    int lowerVerse,
    int upperVerse, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'book_chapter_verse',
        lower: [book, chapter, lowerVerse],
        includeLower: includeLower,
        upper: [book, chapter, upperVerse],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LikeVerseQueryFilter
    on QueryBuilder<LikeVerse, LikeVerse, QFilterCondition> {
  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'book',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'book',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'book',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'book',
        value: '',
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> bookIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'book',
        value: '',
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> chapterEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapter',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> chapterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapter',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> chapterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapter',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> chapterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> verseEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verse',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> verseGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verse',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> verseLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verse',
        value: value,
      ));
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterFilterCondition> verseBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verse',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LikeVerseQueryObject
    on QueryBuilder<LikeVerse, LikeVerse, QFilterCondition> {}

extension LikeVerseQueryLinks
    on QueryBuilder<LikeVerse, LikeVerse, QFilterCondition> {}

extension LikeVerseQuerySortBy on QueryBuilder<LikeVerse, LikeVerse, QSortBy> {
  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByBook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'book', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByBookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'book', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapter', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapter', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByVerse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verse', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> sortByVerseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verse', Sort.desc);
    });
  }
}

extension LikeVerseQuerySortThenBy
    on QueryBuilder<LikeVerse, LikeVerse, QSortThenBy> {
  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByBook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'book', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByBookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'book', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapter', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapter', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByVerse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verse', Sort.asc);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QAfterSortBy> thenByVerseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verse', Sort.desc);
    });
  }
}

extension LikeVerseQueryWhereDistinct
    on QueryBuilder<LikeVerse, LikeVerse, QDistinct> {
  QueryBuilder<LikeVerse, LikeVerse, QDistinct> distinctByBook(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'book', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QDistinct> distinctByChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapter');
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LikeVerse, LikeVerse, QDistinct> distinctByVerse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verse');
    });
  }
}

extension LikeVerseQueryProperty
    on QueryBuilder<LikeVerse, LikeVerse, QQueryProperty> {
  QueryBuilder<LikeVerse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LikeVerse, String, QQueryOperations> bookProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'book');
    });
  }

  QueryBuilder<LikeVerse, int, QQueryOperations> chapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapter');
    });
  }

  QueryBuilder<LikeVerse, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<LikeVerse, int, QQueryOperations> verseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verse');
    });
  }
}
