import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
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
