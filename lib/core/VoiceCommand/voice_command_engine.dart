import 'package:build_access/core/VoiceCommand/IntentClassifier/intent_classifier_engine.dart';
import 'package:build_access/core/VoiceCommand/command_router.dart';
import 'package:build_access/core/speech/speech_to_text/speech_to_text_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/widgets/voice_confirm_widget.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:get/get.dart';
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
        await _voice.speak('voice_not_heard_clear'.tr);
        developer_log.log("User Voice Rỗng", name: "UserProfileEngine");
        return false;
      }

      developer_log.log(
        "Tiến hành phân tích AI $userVoice",
        name: "UserProfileEngine.getUserProfile",
      );

      String cofirmProcess =
          "confirm_general_request".tr + userVoice + "confirm_instruction".tr;

      bool comfirm =
          await VoiceConfirmWidget.show(message: cofirmProcess) ?? false;

      if (comfirm) {
        final String normalizedVoice = _intentClassifierEngine
            .normalizeVoiceIntent(userVoice);
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
      } else {
        await _voice.speak('confirm_action_stopped'.tr);
      }

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
