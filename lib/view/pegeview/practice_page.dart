import 'package:bible_read/controller/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PracticePage extends GetView<PracticeController> {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF272C25),
        body: Column(
          children: [
            // 1. 상단 전환 버튼 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildToggleButton(
                        "구약 성경",
                        controller.isOldTestament.value,
                        () => controller.toggleTestament(true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _buildToggleButton(
                        "신약 성경",
                        !controller.isOldTestament.value,
                        () => controller.toggleTestament(false),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. 성경 목록 그리드 영역
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1 / 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey
                                  .shade200, // 흰색 배경에 흰색 선은 안 보이니 연한 회색으로 추천
                            ),
                          ),
                          child: Obx(
                            () => ListView.builder(
                              itemCount: controller.displayList.length,
                              itemBuilder: (context, index) {
                                if (index >= controller.displayList.length) {
                                  return const SizedBox.shrink();
                                }
                                final bookName = controller.displayList[index];

                                return Obx(
                                  () {
                                    final isSelected =
                                        controller.selectedBook.value ==
                                            bookName;
                                    return TextButton(
                                      onPressed: () =>
                                          controller.selectBible(bookName),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: isSelected
                                            ? controller.jadeGreen
                                            : Colors.white,
                                        /*side: BorderSide(
                                        color: isSelected
                                            ? controller.jadeGreen
                                            : Colors.grey.shade300,
                                      ),*/
                                        /*shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),*/
                                      ),
                                      child: Text(
                                        bookName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1 / 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Obx(
                            () {
                              final chapters = controller.chapterList;
                              if (controller.selectedBook.value.isEmpty) {
                                return const Center(
                                  child: Text(
                                    '책을 선택하세요',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }
                              if (chapters.isEmpty) {
                                return const Center(
                                  child: Text(
                                    '장 데이터를 불러올 수 없습니다',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }
                              return GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: chapters.length,
                                itemBuilder: (context, index) {
                                  if (index >= chapters.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return TextButton(
                                    onPressed: () {
                                      controller.selectChapter(chapters[index]);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      '${chapters[index]}장',
                                      style: const TextStyle(
                                          color: Colors.black87, fontSize: 14),
                                    ),
                                  );
                                },
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.5,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 구약/신약 선택 버튼 위젯
  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        // 선택되었을 때 옥수색 배경과 테두리 적용
        backgroundColor: isSelected ? controller.jadeGreen : Colors.white,
        side: BorderSide(
            color: isSelected ? controller.jadeGreen : Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
