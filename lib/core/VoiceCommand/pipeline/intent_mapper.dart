import 'package:build_access/enum/state.dart';
import 'dart:developer' as developer_log;

class IntentMapper {
  static IntentType fromRawString(String rawLabel) {
    developer_log.log("Nhãn thô từ Native: '$rawLabel'", name: "IntentMapper");
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
      // Speed
      case 'SETTING_SPEED_LOW':
        return IntentType.SETTING_SPEED_LOW;
      case 'SETTING_SPEED_HIGH':
        return IntentType.SETTING_SPEED_HIGH;
      case 'SETTING_SPEED_NORMAL':
        return IntentType.SETTING_SPEED_NORMAL;
      // Lang
      case 'SETTING_LANG_VI':
        return IntentType.SETTING_LANG_VI;
      case 'SETTING_LANG_EN':
        return IntentType.SETTING_LANG_EN;
      // Pitch
      case 'SETTING_PITCH_HIGH':
        return IntentType.SETTING_PITCH_HIGH;
      case 'SETTING_PITCH_LOW':
        return IntentType.SETTING_PITCH_LOW;
      //voice
      case 'SETTING_VOICE_SOUTH':
        return IntentType.SETTING_VOICE_SOUTH;
      case 'SETTING_VOICE_NORTH':
        return IntentType.SETTING_VOICE_NORTH;
      //sex voice
      case 'SETTING_VOICE_MALE':
        return IntentType.SETTING_VOICE_MALE;
      case 'SETTING_VOICE_FEMALE':
        return IntentType.SETTING_VOICE_FEMALE;
      // haptic
      case 'SETTING_HARDWARE':
        return IntentType.SETTING_HARDWARE;
      // AI
      case 'SETTING_AI':
        return IntentType.SETTING_AI;
      case 'CANCEL':
        return IntentType.CANCEL;
      case 'GENERAL':
        return IntentType.GENERAL;
      case 'UNKNOWN':
        return IntentType.UNKNOWN;
      default:
        return IntentType.UNKNOWN;
    }
  }
}
