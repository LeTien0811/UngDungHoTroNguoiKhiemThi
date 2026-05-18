import 'package:build_access/core/vision_asisstant/vision_assistant_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreVisionAsisstantEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<VisionAssistantEngine>(() => VisionAssistantEngine());
    return;
  }
}
