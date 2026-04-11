import 'package:build_access/core/utils/camera/image_handle.dart';
import 'package:build_access/core/utils/image_algorithm.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'package:build_access/core/utils/local_ai/model_downloader_service.dart';
import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/services/paddle_ocr_service.dart';
import 'package:build_access/view_models//camera_view_model.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:build_access/view_models/reading_result_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {

  // navigator and provider
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());
  getIt.registerLazySingleton<GlobalProvider>(() => GlobalProvider());
  getIt.registerLazySingleton<CameraProvider>(() => CameraProvider());

  // Service
  getIt.registerLazySingleton<CameraService>(() => CameraService());

  //AI
  getIt.registerFactory<ModelDownloaderService>(() => ModelDownloaderService());
  getIt.registerLazySingleton<LocalAiEngineService>(() => LocalAiEngineService());
  getIt.registerLazySingleton<PaddleOcrService>(() => PaddleOcrService());

  // Thuat toan
  getIt.registerFactory<ImageHandle>(() => ImageHandle());
  getIt.registerFactory<ImageAlgorithm>(() => ImageAlgorithm());

  // model
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<ReadingResultViewModel>(() => ReadingResultViewModel());
}