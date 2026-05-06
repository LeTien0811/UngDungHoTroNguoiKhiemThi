import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/VoiceCommand/SemanticRouter/intent_classifier_engine.dart';
import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/camera/vision_stream_coordinator.dart';
import 'package:build_access/core/image/frame_quality_evaluator.dart';
import 'package:build_access/core/scan/analyzer/spatial_text_analyzer.dart';
import 'package:build_access/core/scan/enhancer/scan_text_ai_enhancer.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/engine/text_scan_engine.dart';
import 'package:build_access/core/scan/pipeline/scan_quality_manager.dart';
import 'package:build_access/core/scan/scan_orchestrator.dart';
import 'package:build_access/core/setting/app_setting_engine.dart';
import 'package:build_access/core/user_profile/user_profile_engine.dart';
import 'package:build_access/providers/AI/api_ai_provider.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/intent_classifier_provider.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/AI_service/api_service.dart';
import 'package:build_access/services/scan/camera_hardware_service.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/core/scan/engine/paddle_ocr_service.dart';
import 'package:build_access/services/scan/flash_light_hardware_service.dart';
import 'package:build_access/services/scan/haptic_hardware_service.dart';
import 'package:build_access/services/AI_service/hardware_service.dart';
import 'package:build_access/services/intent_classifier/intent_ffi_service.dart';
import 'package:build_access/services/AI_service/local_ai_service.dart';
import 'package:build_access/services/AI_service/network_service.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'package:build_access/services/voice_interaction/audio_feedback_service.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';
import 'package:build_access/view_models/camera_view_model.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:build_access/view_models/splash_view_model.dart';
import 'package:build_access/view_models/vision_assistant_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependency() {
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());
  getIt.registerLazySingleton<HardwareService>(() => HardwareService());
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());

  getIt.registerLazySingleton<CameraHardwareService>(() => CameraHardwareService());
  getIt.registerLazySingleton<FlashLightHardwareService>(() => FlashLightHardwareService());
  getIt.registerLazySingleton<HapticHardwareService>(() => HapticHardwareService());

  getIt.registerLazySingleton<APIService>(() => APIService());
  getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());
  getIt.registerLazySingleton<ModelDownloaderService>(() => ModelDownloaderService());

  getIt.registerLazySingleton<SpeechToTextService>(
        () => SpeechToTextService(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<TextToSpeechService>(
        () => TextToSpeechService(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<AudioFeedbackService>(
        () => AudioFeedbackService(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<IntentFFIService>(
        () => IntentFFIService(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<LocalAIService>(
        () => LocalAIService(),
    dispose: (e) => e.dispose(),
  );

  getIt.registerLazySingleton<OcrPreprocessor>(
        () => OcrPreprocessor(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<ObjectDetectionEngine>(
        () => ObjectDetectionEngine(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<ScanTextEngine>(
        () => ScanTextEngine(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<LocalAIEngine>(
        () => LocalAIEngine(),
    dispose: (e) => e.dispose(),
  );

  getIt.registerLazySingleton<APIAIEngine>(() => APIAIEngine());
  getIt.registerLazySingleton<AppSettingEngine>(() => AppSettingEngine());
  getIt.registerLazySingleton<UserProfileEngine>(() => UserProfileEngine());
  getIt.registerLazySingleton<IntentClassifierEngine>(() => IntentClassifierEngine());

  getIt.registerLazySingleton<ScanQualityManager>(() => ScanQualityManager());
  getIt.registerLazySingleton<ScanTextAiEnhancer>(() => ScanTextAiEnhancer());
  getIt.registerLazySingleton<FrameQualityEvaluator>(() => FrameQualityEvaluator());
  getIt.registerFactory<SpatialTextAnalyzer>(() => SpatialTextAnalyzer());

  getIt.registerLazySingleton<AIOrchestrator>(
        () => AIOrchestrator(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<ScanOrchestrator>(() => ScanOrchestrator());
  getIt.registerLazySingleton<VisionStreamCoordinator>(() => VisionStreamCoordinator());

  getIt.registerLazySingleton<AppSettingProvider>(
        () => AppSettingProvider(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<CameraProvider>(
        () => CameraProvider(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<UserProfileProvider>(() => UserProfileProvider());
  getIt.registerLazySingleton<LocalAiProvider>(
        () => LocalAiProvider(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<APIAIProvider>(() => APIAIProvider());
  getIt.registerLazySingleton<IntentClassifierProvider>(
        () => IntentClassifierProvider(),
    dispose: (e) => e.dispose(),
  );
  getIt.registerLazySingleton<VoiceInteractionProvider>(
        () => VoiceInteractionProvider(),
    dispose: (e) => e.dispose(),
  );

  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<VisionAssistantViewModel>(() => VisionAssistantViewModel());
  getIt.registerFactory<SplashViewModel>(() => SplashViewModel());
  getIt.registerFactory<OnboardingViewModel>(() => OnboardingViewModel());
}