import 'dart:io' show Platform;

import 'memorize_store_base.dart';
import 'memorize_store_get_storage.dart' as gs show createMemorizeStore;
import 'memorize_store_isar.dart' as isar show createMemorizeStore;

/// 모바일: iOS는 GetStorage(SIGABRT 방지), Android는 Isar 사용.
MemorizeStore createMemorizeStore() =>
    Platform.isIOS ? gs.createMemorizeStore() : isar.createMemorizeStore();
