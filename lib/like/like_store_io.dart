import 'like_store_base.dart';
import 'like_store_shared_prefs.dart' as sp show createLikeStore;

/// iOS/Android: SharedPreferences로 통일 (저장 안정적).
LikeStore createLikeStore() => sp.createLikeStore();
