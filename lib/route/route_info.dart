import 'package:bible_read/controller/chapter_detail_controller.dart';
import 'package:bible_read/view/main_view.dart';
import 'package:bible_read/view/pegeview/chapter_detail_page.dart';
import 'package:bible_read/view/pegeview/home_page.dart';
import 'package:bible_read/view/pegeview/practice_page.dart';
import 'package:bible_read/view/pegeview/search_page.dart';
import 'package:get/get.dart';

class RouteInfo {
  static const String routRoot = '/';
  static const String chapterDetail = '/chapter-detail';

  static List<GetPage> pages = [
    GetPage(name: routRoot, page: () => MainView()),
    GetPage(
      name: chapterDetail,
      page: () => const ChapterDetailPage(),
      binding: BindingsBuilder(() {
        Get.put(ChapterDetailController());
      }),
    ),
  ];

  static List navBarPages = const [
    HomePage(),
    SearchPage(),
    PracticePage(),
  ];
}
