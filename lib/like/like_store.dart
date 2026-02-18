import 'like_store_get_storage.dart'
    if (dart.library.io) 'like_store_io.dart' as impl;

import 'like_store_base.dart';

export 'like_store_base.dart';

LikeStore createLikeStore() => impl.createLikeStore();

