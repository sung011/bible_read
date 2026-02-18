import 'package:get/get.dart';

class TranslationsInfo extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ko': ko,
      };

  final Map<String, String> enUS = {
    'navBar.home': 'Home',
    'navBar.search': 'search',
    'navBar.bible': 'bible',
    'navBar.mylist': 'Notes',
  };

  final Map<String, String> ko = {
    'navBar.home': '홈',
    'navBar.search': '검색',
    'navBar.bible': '성경',
    'navBar.mylist': '암송 노트',
  };
}
