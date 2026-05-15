import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer_log;

class SpeechSetting {
  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();
  final Map<String, double> ttsSpeedRate = {
    "SETTING_SPEED_HIGH": 0.75,
    "SETTING_SPEED_NORMAL": 0.5,
    "SETTING_SPEED_LOW": 0.25,
  };

  final Map<String, double> ttsPitchRate = {
    "SETTING_PITCH_HIGH": 1.0,
    "SETTING_PITCH_LOW": 0.5,
  };

  final Map<IntentType, String> ttsLangRate = {
    IntentType.SETTING_LANG_EN: "en-US",
    IntentType.SETTING_LANG_VI: "vi-VN",
  };

  final Map<IntentType, String> ttsSexRate = {
    IntentType.SETTING_VOICE_FEMALE: "female",
    IntentType.SETTING_VOICE_MALE: "male",
  };

  Future<bool> process(IntentType intentType) async {
    try {
      AppSettingsModel newModel = _appSettingEngine.settingProvider.appSetting;
      bool isChange = false;
      switch (intentType) {
        case IntentType.SETTING_SPEED_HIGH:
          if (newModel.ttsSpeech < ttsSpeedRate["SETTING_SPEED_HIGH"]!) {
            newModel = newModel.copyWith(
              ttsSpeech: ttsSpeedRate["SETTING_SPEED_HIGH"],
            );
            isChange = true;
          }
          break;
        case IntentType.SETTING_SPEED_NORMAL:
          if (newModel.ttsSpeech < ttsSpeedRate["SETTING_SPEED_NORMAL"]! ||
              newModel.ttsSpeech > ttsSpeedRate["SETTING_SPEED_NORMAL"]!) {
            newModel = newModel.copyWith(
              ttsSpeech: ttsSpeedRate["SETTING_SPEED_NORMAL"],
            );
            isChange = true;
          }
          break;
        case IntentType.SETTING_SPEED_LOW:
          if (newModel.ttsSpeech > ttsSpeedRate["SETTING_SPEED_LOW"]!) {
            newModel = newModel.copyWith(
              ttsSpeech: ttsSpeedRate["SETTING_SPEED_LOW"],
            );
            isChange = true;
          }
          break;
        case IntentType.SETTING_PITCH_HIGH:
          if (newModel.ttsPitch < ttsPitchRate["SETTING_PITCH_HIGH"]!) {
            newModel = newModel.copyWith(
              ttsPitch: ttsPitchRate["SETTING_PITCH_HIGH"],
            );
            isChange = true;
          }
          break;
        case IntentType.SETTING_PITCH_LOW:
          if (newModel.ttsPitch > ttsPitchRate["SETTING_PITCH_LOW"]!) {
            newModel = newModel.copyWith(
              ttsPitch: ttsPitchRate["SETTING_PITCH_LOW"],
            );
            isChange = true;
          }
          break;
        case IntentType.SETTING_LANG_VI:
          if (newModel.ttsLanguage != ttsLangRate[intentType]) {
            newModel = newModel.copyWith(ttsLanguage: ttsLangRate[intentType]);
            Get.updateLocale(const Locale('vi', 'VN'));
            isChange = true;
          }
          break;
        case IntentType.SETTING_LANG_EN:
          if (newModel.ttsLanguage != ttsLangRate[intentType]) {
            newModel = newModel.copyWith(ttsLanguage: ttsLangRate[intentType]);
            Get.updateLocale(const Locale('en', 'US'));
            isChange = true;
          }
          break;
        case IntentType.SETTING_VOICE_MALE:
          if (newModel.ttsGenderPreference != ttsSexRate[intentType]) {
            newModel = newModel.copyWith(ttsGenderPreference: ttsSexRate[intentType]);
            isChange = true;
          }
          break;
        case IntentType.SETTING_VOICE_FEMALE:
          if (newModel.ttsGenderPreference != ttsSexRate[intentType]) {
            newModel = newModel.copyWith(ttsGenderPreference: ttsSexRate[intentType]);
            isChange = true;
          }
          break;
        default:
          developer_log.log(
            "Gởi nhầm intent type: $intentType",
            name: "AppSettingEngine",
          );
          return false;
      }

      if (isChange) {
        await getIt<TextToSpeechService>().applyHardwareSettings(newModel);
        await _appSettingEngine.saveSettings(newModel);
        isChange = false;
        return true;
      }
      return false;
    } catch (e) {
      developer_log.log("Lỗi xoay vòng TTS: $e", name: "AppSettingEngine");
      rethrow;
    }
  }
}
