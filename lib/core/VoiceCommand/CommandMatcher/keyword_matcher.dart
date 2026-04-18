import 'package:build_access/enum/config.dart';

class KeywordMatcher {
  final Map<IntentType, List<String>> keywords = {
    IntentType.repeat: [
      "doc lai",
      "noi lai",
      "lap lai"
    ],
    IntentType.history: [
      "lich su",
      "xem lai",
      "danh sach"
    ],
    IntentType.settings: [
      "cai dat",
      "cau hinh",
      "chinh"
    ],
    IntentType.cancel: [
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