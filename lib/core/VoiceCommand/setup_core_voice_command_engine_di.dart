import 'package:build_access/core/VoiceCommand/IntentClassifier/intent_classifier_engine.dart';
import 'package:build_access/core/VoiceCommand/command_router.dart';
import 'package:build_access/core/VoiceCommand/voice_command_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreVoiceCommandEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<VoiceCommandEngine>(() => VoiceCommandEngine());
    getIt.registerLazySingleton<CommandRouter>(() => CommandRouter());
    getIt.registerLazySingleton<IntentClassifierEngine>(
      () => IntentClassifierEngine(),
      dispose: (param) => param.shutdownEngine(),
    );

    return;
  }
}
