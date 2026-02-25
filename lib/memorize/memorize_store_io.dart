import 'memorize_store_base.dart';
import 'memorize_store_shared_prefs.dart' as sp show createMemorizeStore;

/// iOS/Android: SharedPreferences로 통일 (저장 안정적).
MemorizeStore createMemorizeStore() => sp.createMemorizeStore();
