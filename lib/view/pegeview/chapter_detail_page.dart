import 'package:bible_read/controller/chapter_detail_controller.dart';
import 'package:bible_read/controller/like_scripture_controller.dart';
import 'package:bible_read/controller/memorize_controller.dart';
import 'package:bible_read/controller/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterDetailPage extends GetView<ChapterDetailController> {
  const ChapterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    final memorizeController = Get.find<MemorizeController>();
    final likeController = Get.find<LikeScriptureController>();

    return Scaffold(
      backgroundColor: const Color(0xFF272C25),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272C25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '${controller.book} ${controller.chapter}장',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final verses = controller.getVerses();

            if (verses.isEmpty) {
              return const Center(
                child: Text(
                  '절 데이터를 불러올 수 없습니다',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Column(
              children: [
                // 절 번호 네비게이션
                Container(
                  height: 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF272C25),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verseNum = verses[index]['verse'] as int;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: () {
                            controller.scrollToVerse(verseNum);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(45, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            '$verseNum',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: practiceController.jadeGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 구절 리스트
                Expanded(
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];
                      final verseNum = verse['verse'] as int;
                      return Container(
                        key: controller.verseKeys[verseNum],
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$verseNum절',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: practiceController.jadeGreen,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        controller.showVerseModal(verse);
                                      },
                                      icon: const Icon(
                                        Icons.mic,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Obx(() {
                                      final liked = likeController.isLiked(
                                        controller.book,
                                        controller.chapter,
                                        verseNum,
                                      );
                                      return IconButton(
                                        onPressed: () {
                                          likeController.toggleLike(
                                            book: controller.book,
                                            chapter: controller.chapter,
                                            verse: verseNum,
                                            content: (verse['content'] ?? '')
                                                .toString(),
                                          );
                                        },
                                        icon: Icon(
                                          liked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 20,
                                          color: liked
                                              ? Colors.redAccent
                                              : Colors.black54,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      );
                                    }),
                                    Obx(() {
                                      final checked =
                                          memorizeController.isSelected(
                                        controller.book,
                                        controller.chapter,
                                        verseNum,
                                      );
                                      return Checkbox(
                                        value: checked,
                                        onChanged: (_) {
                                          memorizeController.toggle(
                                            book: controller.book,
                                            chapter: controller.chapter,
                                            verse: verseNum,
                                            content: (verse['content'] ?? '')
                                                .toString(),
                                          );
                                        },
                                        activeColor:
                                            practiceController.jadeGreen,
                                        checkColor: Colors.white,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            controller.buildHanjaClickableText(
                              (verse['content'] ?? '').toString(),
                              context: context,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
