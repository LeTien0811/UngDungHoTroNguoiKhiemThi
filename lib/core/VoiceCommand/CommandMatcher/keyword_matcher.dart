import 'package:build_access/enum/state.dart';

class KeywordMatcher {
  final Map<IntentType, List<String>> keywords = {
    IntentType.REPEAT: [
      "doc lai",
      "noi lai",
      "lap lai"
    ],
    IntentType.HISTORY: [
      "lich su",
      "xem lai",
      "danh sach"
    ],
    IntentType.SETTING_HARDWARE: [
      "cai dat",
      "cau hinh",
      "chinh"
    ],
    IntentType.CANCEL: [
      "dung",
      "thoat",
      "huy",
      "tat"
    ],
  };

  IntentType? matchExact(String text) {
    for (var entry in keywords.entries) {
      for (var keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return null;
  }
}