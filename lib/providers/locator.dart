import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<ProviderSevice>(() => ProviderSevice());
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<LocalEngineService>(() => LocalEngineService());
}