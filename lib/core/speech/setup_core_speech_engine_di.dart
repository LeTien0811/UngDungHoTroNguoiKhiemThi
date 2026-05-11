import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:get_it/get_it.dart';

class SetupCoreSpeechEngineDI {
  static void setupDependency(GetIt getIt) {
    getIt.registerLazySingleton<SpeechToTextEngine>(() => SpeechToTextEngine());
    return;
  }
}
