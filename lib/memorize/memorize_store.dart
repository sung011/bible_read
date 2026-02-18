import 'memorize_store_base.dart';
import 'memorize_store_get_storage.dart'
    if (dart.library.io) 'memorize_store_io.dart' as impl;

export 'memorize_store_base.dart';

/// 플랫폼에 맞는 저장소 구현을 반환합니다.
/// - 모바일(iOS/Android): Isar(NoSQL DB)
/// - Web: GetStorage fallback
MemorizeStore createMemorizeStore() => impl.createMemorizeStore();

