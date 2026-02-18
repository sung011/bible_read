import 'package:bible_read/service/admob_service_interface.dart';
import 'package:flutter/material.dart';

/// 웹 등 광고 미지원 플랫폼용 스텁
class StubAdMobService implements IAdMobService {
  @override
  PreferredSizeWidget? get bannerWidget => null;

  @override
  void loadBannerAd({void Function()? onLoaded}) {}

  @override
  void dispose() {}
}
