import 'package:bible_read/service/admob_service_interface.dart';
import 'package:bible_read/service/admob_service_stub.dart';

Future<IAdMobService> createAdMobService() async => StubAdMobService();
