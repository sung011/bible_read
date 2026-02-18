import 'package:bible_read/common/color_schemes.g.dart';
import 'package:bible_read/view/part/like_scripture.dart';
import 'package:bible_read/view/part/study_scripture.dart';
import 'package:bible_read/view/part/today.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size; // 화면 크기

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Today(),
              const SizedBox(height: 16),
              // 아래 영역을 카드 형태(밝은 배경 + 둥근 모서리)로 구성
              LikeScripture(),
              const SizedBox(height: 16),
              // 아래 영역을 카드 형태(밝은 배경 + 둥근 모서리)로 구성
              StudyScripture()
            ],
          ),
        ),
      ),
    );
  }
}
