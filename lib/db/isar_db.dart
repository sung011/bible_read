import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'like_verse.dart';
import 'memorize_verse.dart';

/// Isar(내부 NoSQL DB) 인스턴스를 여는 함수입니다.
///
/// - **왜 필요한가?**
///   - GetStorage는 "키-값" 형태의 간단한 로컬 저장소라서 가볍고 편하지만,
///     데이터가 늘어나거나 검색/정렬/인덱싱이 필요해지면 DB(예: Isar)가 더 적합합니다.
/// - **어디에 저장되나?**
///   - 앱 내부 저장공간(Application Documents Directory) 아래에 Isar DB 파일로 저장됩니다.
Future<Isar> openAppIsar() async {
  // 앱 내부 저장 경로 (iOS: Application Support/Documents, Android: app data dir)
  final dir = await getApplicationDocumentsDirectory();

  // 이미 열려 있으면 재사용
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

