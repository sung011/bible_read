import 'dart:io';

import 'package:bible_read/service/admob_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Android / iOS 실제 AdMob 배너 구현
class AdMobServiceImpl implements IAdMobService {
  BannerAd? _bannerAd;
  bool _isLoading = false;
  void Function()? _onLoaded;

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-4141290006816152/3529037962';
      }
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isIOS) {
      if (kReleaseMode) {
        return 'ca-app-pub-4141290006816152/3504987234';
      }
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  PreferredSizeWidget? get bannerWidget {
    if (_bannerAd == null) return null;
    return PreferredSize(
      preferredSize: Size.fromHeight(_bannerAd!.size.height.toDouble()),
      child: Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void loadBannerAd({void Function()? onLoaded}) {
    if (_bannerAd != null || _isLoading) return;
    _onLoaded = onLoaded;
    _isLoading = true;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isLoading = false;
          _onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _isLoading = false;
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoading = false;
    _onLoaded = null;
  }
}
