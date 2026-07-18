import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'like_verse.dart';
import 'memorize_verse.dart';

/// 동시에 `openAppIsar()`가 여러 번 호출되면(예: 암송·좋아요 컨트롤러 `onInit`) 둘 다
/// `Isar.instanceNames.isEmpty`를 통과해 `Isar.open()`이 중복 실행될 수 있어,
/// 기기에서 `DartWorker` / `EXC_BAD_ACCESS`로 터질 수 있습니다. 한 Future로 직렬화합니다.
Future<Isar>? _openAppIsarMemo;

/// Isar(내부 NoSQL DB) 인스턴스를 여는 함수입니다.
///
/// - **왜 필요한가?**
///   - GetStorage는 "키-값" 형태의 간단한 로컬 저장소라서 가볍고 편하지만,
///     데이터가 늘어나거나 검색/정렬/인덱싱이 필요해지면 DB(예: Isar)가 더 적합합니다.
/// - **어디에 저장되나?**
///   - 앱 내부 저장공간(Application Documents Directory) 아래에 Isar DB 파일로 저장됩니다.
Future<Isar> openAppIsar() async {
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }
  _openAppIsarMemo ??= _openAppIsarOnce();
  try {
    return await _openAppIsarMemo!;
  } catch (_) {
    _openAppIsarMemo = null;
    rethrow;
  }
}

Future<Isar> _openAppIsarOnce() async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isNotEmpty) {
    return Isar.getInstance()!;
  }
  // inspector: true는 iOS 네이티브에서 SIGABRT 유발 가능 → false로 설정
  return Isar.open(
    [
      MemorizeVerseSchema,
      LikeVerseSchema,
    ],
    directory: dir.path,
    inspector: false,
  );
}

