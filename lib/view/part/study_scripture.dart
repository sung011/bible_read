import 'package:bible_read/controller/study_scripture_controller.dart';
import 'package:bible_read/route/route_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudyScripture extends GetView<StudyScriptureController> {
  const StudyScripture({super.key});

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
            "최근에 학습한 성구",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // DB에서 가져온 데이터를 Obx로 반응형으로 표시
          Obx(
            () => controller.studyVerses.isEmpty
                ? const SizedBox(
                    height: 70,
                    child: Center(
                      child: Text('학습한 성구가 없습니다'),
                    ),
                  )
                : Column(
                    children: controller.studyVerses
                        .take(5) // 홈 화면에서는 최근 5개만 표시
                        .map(
                          (verse) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(
                                  RouteInfo.chapterDetail,
                                  arguments: {
                                    'book': verse.book,
                                    'chapter': verse.chapter,
                                    'verse': verse.verse,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        verse.content,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text("- ${verse.reference}"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
