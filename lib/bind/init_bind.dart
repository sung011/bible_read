import 'package:bible_read/controller/like_scripture_controller.dart';
import 'package:bible_read/controller/main_controller.dart';
import 'package:bible_read/controller/memorize_controller.dart';
import 'package:bible_read/controller/practice_controller.dart';
import 'package:bible_read/controller/search_controller.dart';
import 'package:bible_read/controller/study_scripture_controller.dart';
import 'package:bible_read/controller/today_controller.dart';
import 'package:get/get.dart';

class InitBind implements Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
    Get.put(TodayController());
    Get.put(PracticeController());
    // StudyScriptureController가 내부에서 참조하므로 먼저 주입해야 함
    Get.put(MemorizeController());
    Get.put(LikeScriptureController());
    Get.put(StudyScriptureController());
    Get.lazyPut<BibleSearchController>(() => BibleSearchController(),
        fenix: true);
  }
}
