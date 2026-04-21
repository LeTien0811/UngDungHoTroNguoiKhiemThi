import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';


class VoiceInteractionProvider extends BaseModel {
  final TextToSpeechService _ttsService = getIt<TextToSpeechService>();
  final SpeechToTextService _sttService = getIt<SpeechToTextService>();

  bool isSpeaking = false;
  bool isListening = false;
  String recognizedText = "";

  Future<void> initializeVoice() async {
    _ttsService.onSpeakingStateChanged = (state) {
      if (isSpeaking != state) {
        isSpeaking = state;
        notifyListeners();
      }
    };

    _sttService.onListeningStateChanged = (state) {
      if (isListening != state) {
        isListening = state;
        notifyListeners();
      }
    };

    _sttService.onResultText = (text) {
      recognizedText = text;
      notifyListeners();
    };

    await _ttsService.init();
    await _sttService.init();
  }

  void speak(String text) {
    _ttsService.speak(text);
  }

  void stopSpeaking() {
    _ttsService.stop();
  }

  Future<void> startListening() async {
    await _ttsService.stop();
    await _sttService.startListening();
  }

  void stopListening() {
    _sttService.stopListening();
  }
}