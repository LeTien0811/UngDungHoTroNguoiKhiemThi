import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/VoiceCommand/SemanticRouter/intent_classifier_engine.dart';
import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/setting/app_setting_engine.dart';
import 'package:build_access/core/setups/permissions_setup.dart';
import 'package:build_access/core/user_profile/user_profile_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:build_access/features/onboarding_features/onboarding_feature.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/scan/camera_hardware_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer_log;

class SplashViewModel extends BaseModel {
  final NavigatorService _navigatorService = getIt<NavigatorService>();

  final VoiceInteractionProvider _voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();

  final CameraHardwareService _cameraHardwareService =
      getIt<CameraHardwareService>();

  final IntentClassifierEngine _classifierEngine =
      getIt<IntentClassifierEngine>();

  final AppSettingEngine _appSettingEngine = getIt<AppSettingEngine>();
  final AppSettingProvider _appSettingProvider = getIt<AppSettingProvider>();

  final UserProfileProvider _profileProvider = getIt<UserProfileProvider>();
  final UserProfileEngine _profileEngine = getIt<UserProfileEngine>();

  final AIOrchestrator _aiOrchestrator = getIt<AIOrchestrator>();

  bool hasMicPermission = false;
  bool hasCameraPermission = false;

  Future<void> initializerApp() async {
    await _appSettingEngine.initializeEngine();
    if (_appSettingProvider.status != SettingStatus.idle) {
      developer_log.log(
        "khoi tao app setting khong thanh cong",
        name: "SplashViewModel.initializerApp",
      );
    }

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
      _voiceInteractionProvider.speak(
        "Vui lòng cấp quyền camera và micro trong cài đặt để sử dụng ứng dụng.",
      );
      return;
    }

    try {
      _voiceInteractionProvider.speak(
        "Đang kiểm tra dữ liệu, vui lòng đợi trong giây lát.",
      );

      await Future.wait([
        _profileEngine.initializer(),
      ]);

      if (WidgetsBinding.instance.lifecycleState ==
          AppLifecycleState.detached) {
        return;
      }

      developer_log.log("Hoàn thành", name: "SplashViewModel.initializerApp");

      _voiceInteractionProvider.playSuccessSound();

      if (_profileProvider.userState == UserProfileState.uninitialized) {
        _navigatorService.pushNamedAndRemoveUntil(OnboardingFeature.routerName);
        return;
      } else {
        _navigatorService.pushNamedAndRemoveUntil(HomeFeatures.routerName);
        return;
      }

    } catch (e) {
      developer_log.log(
        "lỗi trong quá trình khởi tạo: $e",
        name: "SplashViewModel.initializerApp",
      );
      _voiceInteractionProvider.speak("Có lỗi xảy ra: $e");
      return;
    }
  }
}
