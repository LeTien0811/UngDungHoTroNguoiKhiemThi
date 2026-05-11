import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/services/hardware/flash_light_hardware_service.dart';
import 'dart:developer' as developer_log;

class FlashSetting {
  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();
  final FlashLightHardwareService _flashlightService =
      getIt<FlashLightHardwareService>();
  Future<bool> toggleFlashlightRule() async {
    try {
      if (!_flashlightService.hasTorch) {
        return false;
      }
      final currentState =
          _appSettingEngine.settingProvider.appSetting.autoEnableFlashlight;
      final newState = !currentState;

      bool isSuccess = false;
      if (newState) {
        isSuccess = await _flashlightService.turnOn();
      } else {
        isSuccess = await _flashlightService.turnOff();
      }
      if (isSuccess) {
        final newModel = _appSettingEngine.settingProvider.appSetting.copyWith(
          autoEnableFlashlight: newState,
        );
        await _appSettingEngine.saveSettings(newModel);
      }
      return isSuccess;
    } catch (e) {
      developer_log.log("Lỗi Toggle Flashlight: $e", name: "AppSettingEngine");
      return false;
    }
  }
}
