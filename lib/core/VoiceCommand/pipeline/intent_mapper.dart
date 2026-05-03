import 'package:build_access/enum/state.dart';

class IntentMapper {
  static IntentType fromRawString(String rawLabel) {
    switch (rawLabel) {
      case 'USAGE':
        return IntentType.USAGE;
      case 'SAFETY':
        return IntentType.SAFETY;
      case 'DETAILS':
        return IntentType.DETAILS;
      case 'REPEAT':
        return IntentType.REPEAT;
      case 'HISTORY':
        return IntentType.HISTORY;
      case 'CANCEL':
        return IntentType.CANCEL;
      case 'GENERAL':
        return IntentType.GENERAL;
      case 'SETTINGS':
        return IntentType.SETTINGS;
      case 'SETTINGS_HARDWARE':
        return IntentType.SETTINGS_HARDWARE;
      case 'SETTINGS_OPEN':
        return IntentType.SETTINGS_OPEN;
      case 'SETTINGS_VOICE':
        return IntentType.SETTINGS_VOICE;
      case 'SETTINGS_AI':
        return IntentType.SETTINGS_AI;
      case 'UNKNOWN':
        return IntentType.UNKNOWN;
      default:
        return IntentType.UNKNOWN;
    }
  }
}