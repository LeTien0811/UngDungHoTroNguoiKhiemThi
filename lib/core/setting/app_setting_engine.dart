import 'package:build_access/config/extension.dart';
import 'package:build_access/core/text_to_speech/speech_rate.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/services/scan/flash_light_hardware_service.dart';
import 'package:build_access/services/scan/haptic_hardware_service.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'dart:developer' as developer_log;

import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';

class AppSettingEngine {
  final SecureStorageService _storageService = getIt<SecureStorageService>();
  final AppSettingProvider _settingProvider = getIt<AppSettingProvider>();
  final HapticHardwareService _hapticService = getIt<HapticHardwareService>();
  final FlashLightHardwareService _flashlightService =
      getIt<FlashLightHardwareService>();
  final String _settingsKey = 'secure_app_settings';

  Future<void> initializeEngine() async {
    try {
      final String? rawJson = await _storageService.readData(_settingsKey);

      if (rawJson != null) {
        final AppSettingsModel loadedSettings = AppSettingsModel.fromJson(
          rawJson,
        );
        _settingProvider.loadedAppSetting(loadedSettings);
      } else {
        developer_log.log("Chưa có setting nào được lưu", name: "AppSettingsEngine");
        _settingProvider.setReady();
      }
    } catch (e) {
      developer_log.log("Lỗi nạp cấu hình: $e", name: "AppSettingsEngine");
    }
  }

  Future<void> saveSettings(AppSettingsModel newModel) async {
    try {
      await _storageService.saveData(_settingsKey, newModel.toJson());
      _settingProvider.updateSetting(newModel);
    } catch (e) {
      developer_log.log("Lỗi ghi cấu hình: $e", name: "AppSettingEngine");
    }
  }

  Future<double> cycleSpeechRate() async {
    try {
      final currentRate = _settingProvider.appSetting.ttsSpeechRate;
      int currentIndex = SpeechRate.speechRateCycle.indexOf(currentRate);

      int nextIndex = (currentIndex + 1) % SpeechRate.speechRateCycle.length;
      double newRate = SpeechRate.speechRateCycle[nextIndex];

      final newModel = _settingProvider.appSetting.copyWith(
        ttsSpeechRate: newRate,
      );

      await getIt<TextToSpeechService>().applyHardwareSettings(newModel);
      await saveSettings(newModel);

      return newRate;
    } catch (e) {
      developer_log.log("Lỗi xoay vòng TTS: $e", name: "AppSettingEngine");
      return _settingProvider.appSetting.ttsSpeechRate;
    }
  }

  Future<bool> toggleHapticFeedback() async {
    try {
      String currentHapticString = _settingProvider.appSetting.hapticLevel;
      final HapticState currentState = currentHapticString.toHapticState();
      int currentIndex = _hapticService.listHaptic.indexOf(currentState);

      int nextIndex = (currentIndex + 1) % SpeechRate.speechRateCycle.length;
      final HapticState newState = _hapticService.listHaptic[nextIndex];

      final newModel = _settingProvider.appSetting.copyWith(
        hapticLevel: newState.name,
      );
      await saveSettings(newModel);

      bool isTrigger = await _hapticService.triggerHapticFeedBack(newState);
      return isTrigger;
    } catch (e) {
      developer_log.log("Lỗi Toggle Haptic: $e", name: "AppSettingEngine");
      return false;
    }
  }

  Future<bool> toggleFlashlightRule() async {
    try {
      if (!_flashlightService.hasTorch) {
        return false;
      }
      final currentState = _settingProvider.appSetting.autoEnableFlashlight;
      final newState = !currentState;

      bool isSuccess = false;
      if (newState) {
        isSuccess = await _flashlightService.turnOn();
      } else {
        isSuccess = await _flashlightService.turnOff();
      }
      if (isSuccess) {
        final newModel = _settingProvider.appSetting.copyWith(
          autoEnableFlashlight: newState,
        );
        await saveSettings(newModel);
      }
      return isSuccess;
    } catch (e) {
      developer_log.log("Lỗi Toggle Flashlight: $e", name: "AppSettingEngine");
      return false;
    }
  }
}
