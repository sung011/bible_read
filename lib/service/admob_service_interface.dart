import 'package:flutter/material.dart';

/// AdMob 배너 서비스 인터페이스 (Android / iOS 공통)
abstract class IAdMobService {
  PreferredSizeWidget? get bannerWidget;
  void loadBannerAd({void Function()? onLoaded});
  void dispose();
}
