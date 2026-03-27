import 'package:build_access/core/utils/camera/image_handle.dart';
import 'package:build_access/core/utils/image_algorithm.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/view/camera_view_model.dart';
import 'package:build_access/view/home_view_model.dart';
import 'package:build_access/view/reading_result_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  // SERVICES: Sống mãi mãi (Singleton)
  getIt.registerLazySingleton<NavigatorService>(() => NavigatorService());
  getIt.registerLazySingleton<ProviderSevice>(() => ProviderSevice());
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<LocalEngineService>(() => LocalEngineService());

  getIt.registerFactory<ImageHandle>(() => ImageHandle());
  getIt.registerFactory<ImageAlgorithm>(() => ImageAlgorithm());

  // VIEWMODELS: Dùng xong vứt (Factory)
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());
  getIt.registerFactory<CameraViewModel>(() => CameraViewModel());
  getIt.registerFactory<ReadingResultViewModel>(() => ReadingResultViewModel());
}