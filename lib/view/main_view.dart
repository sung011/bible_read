import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:bible_read/controller/main_controller.dart';
import 'package:bible_read/route/route_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX 스타일의 메인 화면 (GetView 사용)
class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272C25),
      appBar: AppBar(
        title: Obx(() {
          controller.bannerVersion.value;
          return controller.adMobService.bannerWidget ?? const SizedBox.shrink();
        }),
        //bottom: controller.adMobService.bannerWidget,
      ),
      body: SafeArea(
        child: Obx(
          () => RouteInfo.navBarPages[controller.navBarIdx.value],
        ),
      ),
      bottomNavigationBar: Obx(() {
        controller.navBarIdx.value;
        final screenWidth = MediaQuery.of(context).size.width;
        return SizedBox(
          width: screenWidth,
          child: AnimatedNotchBottomBar(
            notchBottomBarController: controller.notchController,
            showLabel: true,
            shadowElevation: 5,
            notchColor: const Color(0xFF00A86B),
            bottomBarWidth: screenWidth,
            removeMargins: true,
            onTap: (index) => controller.onChangeNavBar(index),
            bottomBarItems: [
              BottomBarItem(
                inActiveItem:
                    const Icon(Icons.home_max_outlined, color: Colors.blueGrey),
                activeItem: const Icon(Icons.home_max, color: Colors.white),
                itemLabel: 'navBar.home'.tr,
              ),
              BottomBarItem(
                inActiveItem: const Icon(Icons.search, color: Colors.blueGrey),
                activeItem: const Icon(Icons.search, color: Colors.white),
                itemLabel: 'navBar.search'.tr,
              ),
              BottomBarItem(
                inActiveItem: const Icon(Icons.auto_stories_outlined,
                    color: Colors.blueGrey),
                activeItem: const Icon(Icons.auto_stories, color: Colors.white),
                itemLabel: 'navBar.bible'.tr,
              ),
            ],
            kIconSize: 20,
            kBottomRadius: 20,
          ),
        );
      }),
    );
  }
}
