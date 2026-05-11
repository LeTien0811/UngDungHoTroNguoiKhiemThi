import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
import 'package:get_it/get_it.dart';

class SetupCoreAiEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<APIAIEngine>(() => APIAIEngine());
    getIt.registerLazySingleton<LocalAIEngine>(
      () => LocalAIEngine(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<ModelDownloaderService>(
      () => ModelDownloaderService(),
    );
    getIt.registerLazySingleton<AIOrchestrator>(
      () => AIOrchestrator(),
      dispose: (e) => e.dispose(),
    );
  }
}
