import 'package:bible_read/controller/like_scripture_controller.dart';
import 'package:bible_read/route/route_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikeScripture extends GetView<LikeScriptureController> {
  const LikeScripture({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "좋아하는 성구",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // 높이를 고정하지 않고, 카드 높이에 맞춰지도록 구성
          Obx(
            () => controller.likedVerses.isEmpty
                ? const SizedBox(
                    height: 45,
                    child: Center(
                      child: Text('좋아하는 성구가 없습니다'),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.likedVerses
                          .map(
                            (verse) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    RouteInfo.chapterDetail,
                                    arguments: {
                                      'book': verse.book,
                                      'chapter': verse.chapter,
                                      'verse': verse.verse, // 해당 절로 이동
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  width: 90,
                                  height: 45,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        "- ${verse.reference}",
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
