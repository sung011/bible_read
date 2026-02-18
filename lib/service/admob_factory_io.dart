import 'package:bible_read/service/admob_service_interface.dart';
import 'package:bible_read/service/admob_service_impl.dart';

Future<IAdMobService> createAdMobService() async => AdMobServiceImpl();
