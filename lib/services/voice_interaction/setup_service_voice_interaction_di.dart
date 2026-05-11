import 'package:build_access/services/voice_interaction/audio_feedback_service.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';
import 'package:get_it/get_it.dart';

class SetupServiceVoiceInteractionDI {
  static Future<void> setupDependency(GetIt getIt) async {
    getIt.registerLazySingleton<AudioFeedbackService>(
      () => AudioFeedbackService(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<SpeechToTextService>(
      () => SpeechToTextService(),
      dispose: (e) => e.dispose(),
    );
    getIt.registerLazySingleton<TextToSpeechService>(
      () => TextToSpeechService(),
      dispose: (e) => e.dispose(),
    );
  }
}
