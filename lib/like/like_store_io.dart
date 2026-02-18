import 'dart:io' show Platform;

import 'like_store_base.dart';
import 'like_store_get_storage.dart' as gs show createLikeStore;
import 'like_store_isar.dart' as isar show createLikeStore;

/// 모바일: iOS는 GetStorage(SIGABRT 방지), Android는 Isar 사용.
LikeStore createLikeStore() =>
    Platform.isIOS ? gs.createLikeStore() : isar.createLikeStore();
