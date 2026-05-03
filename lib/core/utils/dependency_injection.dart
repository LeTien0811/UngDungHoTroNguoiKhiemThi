import 'package:build_access/core/VoiceCommand/SemanticRouter/intent_classifier_engine.dart';
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
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:build_access/providers/intent_classifier_provider.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/camera_hardware_service.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/core/scan/engine/paddle_ocr_service.dart';
import 'package:build_access/services/flash_light_hardware_service.dart';
import 'package:build_access/services/haptic_hardware_service.dart';
import 'package:build_access/services/intent_classifier/intent_ffi_service.dart';
import 'package:build_access/services/local_ai_service.dart';
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
  // navigator and provider
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());

  // Voice
  getIt.registerLazySingleton<SpeechToTextService>(() => SpeechToTextService());
  getIt.registerLazySingleton<TextToSpeechService>(() => TextToSpeechService());
  getIt.registerLazySingleton<AudioFeedbackService>(
    () => AudioFeedbackService(),
  );
  getIt.registerLazySingleton<VoiceInteractionProvider>(
    () => VoiceInteractionProvider(),
  );

  //camera
  getIt.registerLazySingleton<CameraHardwareService>(
    () => CameraHardwareService(),
  );
  getIt.registerLazySingleton<CameraProvider>(() => CameraProvider());
  getIt.registerLazySingleton<VisionStreamCoordinator>(
    () => VisionStreamCoordinator(),
  );

  // Isolate Ocr Preprocessor
  getIt.registerLazySingleton<OcrPreprocessor>(() => OcrPreprocessor());

  //Engine scan.
  getIt.registerLazySingleton<ObjectDetectionEngine>(
    () => ObjectDetectionEngine(),
  );
  getIt.registerLazySingleton<ScanTextEngine>(() => ScanTextEngine());
  getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());
  getIt.registerFactory<SpatialTextAnalyzer>(() => SpatialTextAnalyzer());
  getIt.registerLazySingleton<ScanQualityManager>(() => ScanQualityManager());
  getIt.registerLazySingleton<ScanTextAiEnhancer>(() => ScanTextAiEnhancer());
  getIt.registerLazySingleton<ScanOrchestrator>(() => ScanOrchestrator());
  getIt.registerLazySingleton<FrameQualityEvaluator>(() => FrameQualityEvaluator());

  //AI
  getIt.registerFactory<ModelDownloaderService>(() => ModelDownloaderService());
  getIt.registerLazySingleton<LocalAIService>(() => LocalAIService());
  getIt.registerLazySingleton<LocalAiProvider>(() => LocalAiProvider());
  getIt.registerLazySingleton<LocalAIEngine>(() => LocalAIEngine());

  // intent classifier
  getIt.registerLazySingleton<IntentFFIService>(() => IntentFFIService());
  getIt.registerLazySingleton<IntentClassifierEngine>(
    () => IntentClassifierEngine(),
  );
  getIt.registerLazySingleton<IntentClassifierProvider>(
    () => IntentClassifierProvider(),
  );

  //storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  //app Setting
  getIt.registerLazySingleton<AppSettingEngine>(() => AppSettingEngine());
  getIt.registerLazySingleton<AppSettingProvider>(() => AppSettingProvider());

  // flash light and haptic feedback
  getIt.registerLazySingleton<HapticHardwareService>(
    () => HapticHardwareService(),
  );
  getIt.registerLazySingleton<FlashLightHardwareService>(
    () => FlashLightHardwareService(),
  );

  //User Profile
  getIt.registerLazySingleton<UserProfileProvider>(() => UserProfileProvider());
  getIt.registerLazySingleton<UserProfileEngine>(() => UserProfileEngine());

  // view model
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<VisionAssistantViewModel>(
    () => VisionAssistantViewModel(),
  );
  getIt.registerFactory<SplashViewModel>(() => SplashViewModel());
  getIt.registerFactory<OnboardingViewModel>(() => OnboardingViewModel());
}
