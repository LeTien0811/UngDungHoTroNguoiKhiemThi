import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/speech/text_to_speech/speech_rate.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/config/extension.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'dart:developer' as developer_log;

class HapticSetting {
  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();
  final HapticHardwareService _hapticService = getIt<HapticHardwareService>();
  Future<bool> toggleHapticFeedback() async {
    try {
      String currentHapticString =
          _appSettingEngine.settingProvider.appSetting.hapticLevel;
      final HapticState currentState = currentHapticString.toHapticState();
      int currentIndex = _hapticService.listHaptic.indexOf(currentState);

      int nextIndex =
          (currentIndex + 1) % SpeechRate.speechRateCycle.length;
      final HapticState newState = _hapticService.listHaptic[nextIndex];

      final newModel = _appSettingEngine.settingProvider.appSetting.copyWith(
        hapticLevel: newState.name,
      );
      await _appSettingEngine.saveSettings(newModel);

      bool isTrigger = await _hapticService.triggerHapticFeedBack(newState);
      return isTrigger;
    } catch (e) {
      developer_log.log("Lỗi Toggle Haptic: $e", name: "AppSettingEngine");
      return false;
    }
  }
}
