import 'package:build_access/enum/config.dart';

class MapLable {
  IntentType mapLabelToIntent(String label) {
    switch (label) {
      case '__label__usage':
        return IntentType.usage;
      case '__label__safety':
        return IntentType.safety;
      case '__label__details':
        return IntentType.details;
      case '__label__repeat':
        return IntentType.repeat;
      case '__label__history':
        return IntentType.history;
      case '__label__settings':
        return IntentType.settings;
      case '__label__cancel':
        return IntentType.cancel;
      case '__label__general':
        return IntentType.general;
      default:
        return IntentType.unknown;
    }
  }
}
