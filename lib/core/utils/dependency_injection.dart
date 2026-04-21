import 'package:build_access/core/scan/analyzer/spatial_text_analyzer.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/engine/text_scan_engine.dart';
import 'package:build_access/core/scan/pipeline/scan_quality_manager.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:build_access/core/scan/engine/object_detection_engine.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/camera_hardware_serivce.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/core/scan/engine/paddle_ocr_service.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';
import 'package:build_access/view_models/camera_view_model.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:build_access/view_models/reading_result_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependency() {
  // navigator and provider
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());
  getIt.registerLazySingleton<VoiceInteractionProvider>(() => VoiceInteractionProvider());
  getIt.registerLazySingleton<CameraProvider>(() => CameraProvider());
  getIt.registerLazySingleton<LocalAiProvider>(() => LocalAiProvider());

  // Service
  getIt.registerLazySingleton<CameraHardwareService>(
    () => CameraHardwareService(),
  );
  getIt.registerLazySingleton<SpeechToTextService>(() => SpeechToTextService());
  getIt.registerLazySingleton<TextToSpeechService>(() => TextToSpeechService());

  // Isolate Ocr Preprocessor
  getIt.registerLazySingleton<OcrPreprocessor>(() => OcrPreprocessor());

  //Engine scan.
  getIt.registerLazySingleton<ObjectDetectionEngine>(
    () => ObjectDetectionEngine(),
  );
  getIt.registerLazySingleton<ScanTextEngine>(() => ScanTextEngine());
  getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());
  getIt.registerLazySingleton<ScanQualityManager>(() => ScanQualityManager());

  //AI
  getIt.registerFactory<ModelDownloaderService>(() => ModelDownloaderService());
  getIt.registerLazySingleton<LocalAIEngine>(() => LocalAIEngine());

  // Thuat toan
  getIt.registerFactory<SpatialTextAnalyzer>(() => SpatialTextAnalyzer());

  // model
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<ReadingResultViewModel>(() => ReadingResultViewModel());
}
