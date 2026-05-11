import 'dart:async';
import 'package:build_access/core/AI/setup_core_ai_engine_di.dart';
import 'package:build_access/core/VoiceCommand/setup_core_voice_command_engine_di.dart';
import 'package:build_access/core/auth/setup_core_auth_engine_di.dart';
import 'package:build_access/core/camera/setup_core_camera_engine_di.dart';
import 'package:build_access/core/history/setup_core_history_engine_di.dart';
import 'package:build_access/core/image/setup_core_image_engine_di.dart';
import 'package:build_access/core/navigator/setup_core_navigator_di.dart';
import 'package:build_access/core/scan/setup_core_scan_engine_di.dart';
import 'package:build_access/core/setting/setup_core_setting_engine_di.dart';
import 'package:build_access/core/speech/setup_core_speech_engine_di.dart';
import 'package:build_access/core/onboarding/setup_core_onboarding_engine_di.dart';
import 'package:build_access/core/utils/setup_core_utils_engine_di.dart';
import 'package:build_access/core/vision_asisstant/setup_core_vision_asisstant_engine_di.dart';
import 'package:build_access/providers/setup_provider_di.dart';
import 'package:build_access/services/AI_service/setup_service_ai_di.dart';
import 'package:build_access/services/API_service/setup_service_network_di.dart';
import 'package:build_access/services/auth/setup_service_auth_di.dart';
import 'package:build_access/services/hardware/setup_service_hardware_di.dart';
import 'package:build_access/services/intent_classifier/setup_service_intent_classifier_di.dart';
import 'package:build_access/services/storage/setup_service_storage_di.dart';
import 'package:build_access/services/voice_interaction/setup_service_voice_interaction_di.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer' as developer_log;

GetIt getIt = GetIt.instance;
Future<void> setupDependency() async {
  try {
    SetupServiceVoiceInteractionDI.setupDependency(getIt);
    SetupServiceHardwareDI.setupDependency(getIt);
    await SetupServiceStorageDI.setupDependency(getIt);
    SetupServiceNetworkDI.setupDependency(getIt);
    SetupServiceIntentClassifierDI.setupDependency(getIt);

    SetupCoreUtilsEngineDI.setupDependency(getIt);
    SetupCoreNavigatorDI.setupDependency(getIt);
    SetupCoreSpeechEngineDI.setupDependency(getIt);
    SetupProviderDI.setupDependency(getIt);

    SetupServiceAuthDI.setupDependency(getIt);
    SetupServiceAiDI.setupDependency(getIt);

    SetupCoreHistoryEngineDI.setupDependency(getIt);
    SetupCoreSettingEngineDI.setupDependency(getIt);
    SetupCoreAuthEngineDI.setupDependency(getIt);
    SetupCoreAiEngineDI.setupDependency(getIt);
    SetupCoreOnboardingEngineDI.setupDependency(getIt);
    SetupCoreCameraEngineDI.setupDependency(getIt);
    SetupCoreImageEngineDI.setupDependency(getIt);
    SetupCoreScanEngineDI.setupDependency(getIt);
    SetupCoreVisionAsisstantEngineDI.setupDependency(getIt);
    SetupCoreVoiceCommandEngineDI.setupDependency(getIt);
    developer_log.log("DI system Sẵn sàng", name: "DI");
  } catch (e) {
    developer_log.log("DI system lỗi khởi tạo: $e", name: "DI");
  }
}
