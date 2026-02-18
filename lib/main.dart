import 'dart:async';

import 'package:bible_read/bind/init_bind.dart';
import 'package:bible_read/common/translations_info.dart';
import 'package:bible_read/route/route_info.dart';
import 'package:bible_read/service/admob_factory.dart';
import 'package:bible_read/service/admob_service_deferred.dart';
import 'package:bible_read/service/admob_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  // runApp과 같은 Zone에서 바인딩을 초기화해야 Zone mismatch 경고가 발생하지 않습니다.
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // 크래시 원인 확인: 미처리 예외/에러를 콘솔에 출력 (SIGABRT 직전 로그 확인)
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}\n${details.stack}');
    };

    // iOS SIGABRT 완화: 첫 프레임 그린 뒤에만 저장소·바인딩 초기화
    runApp(const _AppWrapper());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

/// 첫 프레임 후 초기화를 수행한 뒤 실제 앱을 표시합니다.
class _AppWrapper extends StatefulWidget {
  const _AppWrapper();

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAfterFirstFrame());
  }

  Future<void> _initAfterFirstFrame() async {
    if (!mounted) return;
    try {
      // 인트로 시간 최소화: await 없이 메인을 먼저 띄우고, 나머지는 백그라운드
      GetStorage.init(); // 완료를 기다리지 않음 (TodayController에서 필요 시 대기)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]); // await 제거

      final adMobProxy = DeferredAdMobService();
      Get.put<IAdMobService>(adMobProxy);
      InitBind().dependencies();
      if (mounted) setState(() => _ready = true);

      // AdMob은 백그라운드에서 초기화
      if (!kIsWeb) {
        await MobileAds.instance.initialize();
        final adMobService = await createAdMobService();
        if (mounted) adMobProxy.setDelegate(adMobService);
      }
    } catch (e, st) {
      debugPrint('Init error: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Init failed: $_error')),
        ),
      );
    }
    if (!_ready) {
      // 첫 프레임을 가볍게 해서 addPostFrameCallback이 빨리 실행되도록 (이미지 로드 대기 제거)
      return MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: ColoredBox(
            color: Color(0xFF272C25),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF00A86B)),
            ),
          ),
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: RouteInfo.routRoot,
      initialBinding: BindingsBuilder(() {}),
      getPages: RouteInfo.pages,
      defaultTransition: Transition.cupertino,
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'us'),
      themeMode: ThemeMode.system,
      translations: TranslationsInfo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
