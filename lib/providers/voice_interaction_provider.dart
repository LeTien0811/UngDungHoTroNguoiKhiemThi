import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/services/voice_interaction/audio_feedback_service.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';

class VoiceInteractionProvider extends BaseModel {
  final TextToSpeechService _ttsService = getIt<TextToSpeechService>();
  final SpeechToTextService _sttService = getIt<SpeechToTextService>();
  final AudioFeedbackService _audioFeedbackService =
      getIt<AudioFeedbackService>();

  bool isSpeaking = false;
  bool isListening = false;
  String recognizedText = "";

  Future<void> initializeVoice(AppSettingsModel appSetting) async {
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

    await _ttsService.init(appSetting);
    await _sttService.init();
    await _audioFeedbackService.initialize();
  }


  Future<void> speak(String text) async{
    _audioFeedbackService.stopProcessingSound();
    _ttsService.speak(text);
  }

  Future<void> stopSpeaking() async{
    _ttsService.stop();
  }

  Future<void> startListening() async {
    await _ttsService.stop();
    await _audioFeedbackService.playNotificationSound();
    await _sttService.startListening();
  }

  void stopListening() {
    _sttService.stopListening();
  }

  Future<void> playProcessingSound() async {
    await _ttsService.stop();
    await _audioFeedbackService.playProcessingSound();
  }

  Future<void> playSuccessSound() async {
    await _audioFeedbackService.playSuccessSound();
  }

  Future<void> playErrorSound() async {
    await _audioFeedbackService.playErrorSound();
  }

  @override
  void dispose() {
    _audioFeedbackService.dispose();
    super.dispose();
  }
}
