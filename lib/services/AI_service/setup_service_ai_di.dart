import 'package:build_access/services/AI_service/hardware_service.dart';
import 'package:build_access/services/AI_service/local_ai_service.dart';
import 'package:build_access/services/AI_service/network_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceAiDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<NetworkService>(() => NetworkService());
    getIt.registerLazySingleton<HardwareService>(() => HardwareService());

    getIt.registerLazySingleton<LocalAIService>(
          () => LocalAIService(),
      dispose: (e) => e.dispose(),
    );
  }
}
