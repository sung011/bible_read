import 'package:bible_read/controller/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends GetView<BibleSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF272C25),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.dismissKeyboard,
          child: Column(
            children: [
              // 헤더 + 검색바
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '성경 검색',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: controller.practiceController.jadeGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: controller.textController,
                              focusNode: controller.focusNode,
                              onChanged: controller.onQueryChanged,
                              textInputAction: TextInputAction.search,
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              decoration: const InputDecoration(
                                hintText: '단어/구절/참조(예: 태초, 사랑, 창세기 1:1)',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.searching.value) {
                              return const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }

                            if (controller.query.value.trim().isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return IconButton(
                              onPressed: controller.clearQuery,
                              icon: const Icon(Icons.close),
                              tooltip: '지우기',
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 결과 영역
              Expanded(
                child: Obx(() {
                  // NOTE: 디바운스(180ms) 후에는 query는 그대로인데 resultIndexes만 바뀝니다.
                  // 이 값을 여기서 읽어야 Obx가 결과 변화에도 반응해서 "검색이 안 되는 것처럼" 보이지 않습니다.
                  final _ = controller.resultIndexes.length;

                  if (controller.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A86B),
                      ),
                    );
                  }

                  if (controller.query.value.trim().isEmpty) {
                    return _buildEmptyState();
                  }

                  // 검색 중에는 로딩을 보여주고, 완료되면 결과를 렌더링
                  if (controller.searching.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A86B),
                      ),
                    );
                  }

                  return _buildResults();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Text(
              '검색어를 입력하면 실시간으로 결과가 표시됩니다.\n\n예) 태초, 하나님, 사랑, 믿음, 창세기 1:1',
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildChip('태초'),
              _buildChip('사랑'),
              _buildChip('믿음'),
              _buildChip('기도'),
              _buildChip('창세기 1:1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return InkWell(
      onTap: () {
        controller.setQuery(text);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final count = controller.resultIndexes.length;

    if (count == 0) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Text(
                '결과 $count개',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: controller.resultIndexes.length,
            itemBuilder: (context, idx) {
              final i = controller.resultIndexes[idx];
              final v = controller.allVerses[i];
              final book = (v['book'] ?? '').toString();
              final chapter = (v['chapter'] ?? '').toString();
              final verse = (v['verse'] ?? '').toString();
              final ref = '$book $chapter:$verse';
              final content = controller.allDisplayContents[i];

              return InkWell(
                onTap: () => controller.openVerse(v),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: controller.practiceController.jadeGreen
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              ref,
                              style: TextStyle(
                                color: controller.practiceController.jadeGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right,
                              color: Colors.black45),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildHighlightedText(
                        content,
                        controller.query.value.trim(),
                        const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                        TextStyle(
                          color: controller.practiceController.jadeGreen,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle normal,
    TextStyle highlight,
  ) {
    if (query.isEmpty) return Text(text, style: normal);

    // 단순 포함 하이라이트(대소문자 무시)
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    var start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: normal));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: normal));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlight,
      ));
      start = index + query.length;
      if (start >= text.length) break;
    }

    return Text.rich(TextSpan(children: spans));
  }
}
