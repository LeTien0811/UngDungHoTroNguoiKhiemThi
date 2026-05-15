import 'package:build_access/core/auth/auth_controller.dart';
import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/setting/engine/app_setting_engine.dart';
import 'package:build_access/core/setups/permissions_setup.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/hardware/flash_light_hardware_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer_log;

import 'package:get/get.dart';

class SplashViewModel extends BaseModel {
  final VoiceInteractionProvider _voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();

  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();
  final AppSettingProvider _appSettingProvider = getIt<AppSettingProvider>();

  final FlashLightHardwareService _flashLightService =
      getIt<FlashLightHardwareService>();
  final AuthController _authController = Get.find<AuthController>();

  bool hasMicPermission = false;
  bool hasCameraPermission = false;

  Future<void> initializerApp() async {
    await _appSettingEngine.initializeEngine();
    if (_appSettingProvider.status != SettingStatus.idle) {
      developer_log.log(
        "khoi tao app setting khong thanh cong",
        name: "SplashViewModel.initializerApp",
      );
    } else {
      // Cập nhật lại ngôn ngữ hệ thống cho GetX ngay sau khi load xong từ Storage
      final localeParts = _appSettingProvider.appSetting.ttsLanguage.split('-');
      if (localeParts.length == 2) {
        Get.updateLocale(Locale(localeParts[0], localeParts[1]));
      }
    }

    await _flashLightService.init();

    await _voiceInteractionProvider.initializeVoice(
      _appSettingProvider.appSetting,
    );

    hasCameraPermission = await PermissionsSetup.checkCameraPermissions(
      hasCameraPermission,
      _voiceInteractionProvider.speak,
    );

    hasMicPermission = await PermissionsSetup.checkMicPermissions(
      hasMicPermission,
      _voiceInteractionProvider.speak,
    );

    if (!hasCameraPermission || !hasMicPermission) {
      _voiceInteractionProvider.speak('splash_permission_required'.tr);
      return;
    }

    try {
      _voiceInteractionProvider.speak('splash_checking_data'.tr);

      if (WidgetsBinding.instance.lifecycleState ==
          AppLifecycleState.detached) {
        return;
      }

      developer_log.log("Hoàn thành", name: "SplashViewModel.initializerApp");

      await _voiceInteractionProvider.playSuccessSound();
      await _authController.checkInitialAuth();
    } catch (e) {
      developer_log.log(
        "lỗi trong quá trình khởi tạo: $e",
        name: "SplashViewModel.initializerApp",
      );
      await _voiceInteractionProvider.speak('splash_error'.trParams({'error': e.toString()}));
      return;
    }
  }
}
