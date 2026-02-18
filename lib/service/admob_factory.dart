import 'package:bible_read/service/admob_service_interface.dart';
import 'package:bible_read/service/admob_factory_io.dart'
    if (dart.library.html) 'package:bible_read/service/admob_factory_stub.dart'
    as admob_factory_impl;

Future<IAdMobService> createAdMobService() async =>
    admob_factory_impl.createAdMobService();
