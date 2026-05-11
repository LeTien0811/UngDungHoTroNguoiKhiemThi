import 'package:build_access/core/camera/vision_stream_coordinator.dart';
import 'package:get_it/get_it.dart';

class SetupCoreCameraEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<VisionStreamCoordinator>(
      () => VisionStreamCoordinator(),
      dispose: (param) => param.dispose(),
    );
  }
}
