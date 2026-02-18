import 'package:bible_read/service/admob_service_interface.dart';
import 'package:flutter/material.dart';

/// 메인 화면 진입을 빠르게 하기 위해, 실제 AdMob은 나중에 주입하는 프록시.
/// 앱 시작 시 이걸 먼저 등록하고 메인을 띄운 뒤, 백그라운드에서 실제 서비스를 주입합니다.
class DeferredAdMobService implements IAdMobService {
  IAdMobService? _delegate;
  void Function()? _pendingOnLoaded;

  void setDelegate(IAdMobService service) {
    if (_delegate != null) return;
    _delegate = service;
    service.loadBannerAd(onLoaded: () {
      _pendingOnLoaded?.call();
      _pendingOnLoaded = null;
    });
  }

  @override
  PreferredSizeWidget? get bannerWidget => _delegate?.bannerWidget;

  @override
  void loadBannerAd({void Function()? onLoaded}) {
    if (_delegate != null) {
      _delegate!.loadBannerAd(onLoaded: onLoaded);
    } else {
      _pendingOnLoaded = onLoaded;
    }
  }

  @override
  void dispose() {
    _delegate?.dispose();
    _delegate = null;
    _pendingOnLoaded = null;
  }
}
