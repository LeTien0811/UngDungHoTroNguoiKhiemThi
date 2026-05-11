import 'package:build_access/core/setting/engine/AI/ai_setting.dart';
import 'package:build_access/core/setting/engine/speech/speech_setting.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'dart:developer' as developer_log;

class SettingOrchestrator {
  final AiSetting _aiSetting = getIt<AiSetting>();
  final SpeechSetting _speechSetting = getIt<SpeechSetting>();

  Future<void> process(IntentType intentType) async {
    try {
      switch (intentType) {
        case IntentType.SETTING_SPEED_LOW:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_SPEED_HIGH:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_SPEED_NORMAL:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_LANG_VI:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_LANG_EN:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_PITCH_HIGH:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_PITCH_LOW:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_VOICE_SOUTH:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_VOICE_NORTH:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_VOICE_MALE:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_VOICE_FEMALE:
          await _speechSetting.process(intentType);
          break;
        case IntentType.SETTING_HARDWARE:
          developer_log.log("cai dat phan cung", name: "SettingOrchestrator");
          break;
        case IntentType.SETTING_AI:
          await _aiSetting.process();
          break;
        default:
          developer_log.log(
            "cai dat khac: $intentType",
            name: "SettingOrchestrator",
          );
          break;
      }
      return;
    } catch (e) {
      developer_log.log('loi $e', name: "SettingOrchestrator");
      return;
    }
  }
}
