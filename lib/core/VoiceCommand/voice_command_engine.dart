import 'package:build_access/core/VoiceCommand/IntentClassifier/intent_classifier_engine.dart';
import 'package:build_access/core/VoiceCommand/command_router.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'dart:developer' as developer_log;

class VoiceCommandEngine {
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final SpeechToTextEngine _speechToTextEngine = getIt<SpeechToTextEngine>();
  final CommandRouter _commandRouter = getIt<CommandRouter>();
  final IntentClassifierEngine _intentClassifierEngine =
      getIt<IntentClassifierEngine>();

  Future<bool> stopWalkieTalkieAndProcessAI() async {
    try {
      final String userVoice = await _speechToTextEngine.stopWalkieTalkie();

      if (userVoice.trim().isEmpty) {
        await _voice.speak("Tôi chưa nghe rõ, vui lòng nhấn giữ và thử lại.");
        developer_log.log("User Voice Rỗng", name: "UserProfileEngine");
        return false;
      }

      developer_log.log(
        "Tiến hành phân tích AI $userVoice",
        name: "UserProfileEngine.getUserProfile",
      );

      // AI note: Dùng cùng một transcript đã chuẩn hóa cho classifier và router để tránh lệch hành vi xử lý.
      final String normalizedVoice = _intentClassifierEngine.normalizeVoiceIntent(
        userVoice,
      );
      developer_log.log(
        "Transcript đã chuẩn hóa: $normalizedVoice",
        name: "UserProfileEngine.getUserProfile",
      );

      final IntentType intentType = await _intentClassifierEngine
          .processIntentClassifier(normalizedVoice);

      await _commandRouter.router(intentType, normalizedVoice);

      developer_log.log(
        "Kết quả trả về: ${intentType.toString()}",
        name: "UserProfileEngine.getUserProfile",
      );

      return true;
    } catch (e) {
      developer_log.log(
        "Có lỗi xảy ra: $e",
        name: "UserProfileEngine.notifyUserInputreFinished",
      );
      return false;
    }
  }
}
