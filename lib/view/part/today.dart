import 'package:bible_read/controller/today_controller.dart';
import 'package:bible_read/controller/practice_controller.dart';
import 'package:bible_read/view/widget/hanja_clickable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Today extends GetView<TodayController> {
  const Today({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 화면 크기
    final practiceController = Get.find<PracticeController>();
    return Center(
      child: Container(
        // 가로는 화면 비율(90%), 세로는 글 길이에 따라 자동으로 늘어나도록 설정
        width: size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          //color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용(텍스트) 길이에 맞춰 높이 결정
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 말씀:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // 다크/라이트 모드에 따라 자동 전환
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => HanjaClickableText(
                text: controller.verseContent.value,
                accentColor: practiceController.jadeGreen,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                '- ${controller.verseReference.value}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
