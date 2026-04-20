import 'package:build_access/core/image/image_handle.dart';
import 'package:build_access/core/image/image_algorithm.dart';
import 'package:build_access/core/scan/ocr_preprocessor.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:build_access/core/scan/detect_and_recognizer_text.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/core/scan/paddle_ocr_service.dart';
import 'package:build_access/view_models/camera_view_model.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:build_access/view_models/reading_result_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupDependency() {
  // navigator and provider
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());
  getIt.registerLazySingleton<GlobalProvider>(() => GlobalProvider());
  getIt.registerLazySingleton<CameraProvider>(() => CameraProvider());
  getIt.registerLazySingleton<LocalAiProvider>(() => LocalAiProvider());

  // Service
  getIt.registerLazySingleton<CameraHardwareManager>(() => CameraHardwareManager());
  getIt.registerLazySingleton<OcrPreprocessor>(
    () => OcrPreprocessor(),
  );
  getIt.registerLazySingleton<DetectAndRecognizerText>(() => DetectAndRecognizerText());

  //AI
  getIt.registerFactory<ModelDownloaderService>(() => ModelDownloaderService());
  getIt.registerLazySingleton<LocalAIEngine>(
    () => LocalAIEngine(),
  );
  getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());

  // Thuat toan
  getIt.registerFactory<ImageHandle>(() => ImageHandle());
  getIt.registerFactory<ImageAlgorithm>(() => ImageAlgorithm());

  // model
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<ReadingResultViewModel>(() => ReadingResultViewModel());
}
