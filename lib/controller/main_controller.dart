import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:bible_read/service/admob_service_interface.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  // 하단 네비게이션 바 컨트롤러 (초기 인덱스 0)
  final NotchBottomBarController notchController =
      NotchBottomBarController(index: 0);

  IAdMobService get adMobService => Get.find<IAdMobService>();

  /// 배너 로드 시 AppBar 갱신용 (Obx에서 참조)
  final RxInt bannerVersion = 0.obs;

  RxString title = 'title'.tr.obs;
  RxInt navBarIdx = 0.obs;

  @override
  void onInit() {
    super.onInit();
    adMobService.loadBannerAd(onLoaded: () => bannerVersion.refresh());
  }

  void onChangeNavBar(int idx) {
    if (navBarIdx.value == idx) return;

    navBarIdx(idx);

    switch (idx) {
      case 0:
        title('home_title'.tr);
        break;
      case 1:
        title('search_title'.tr);
        break;
      case 2:
        title('bible_title'.tr);
        break;
      case 3:
        title('mylist_title'.tr);
        break;
    }
  }

  @override
  void onClose() {
    notchController.dispose();
    adMobService.dispose();
    super.onClose();
  }
}
