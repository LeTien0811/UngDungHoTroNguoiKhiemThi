import 'package:build_access/core/speech/text_to_speech/get_best_voice.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer_log;

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _speechQueue = [];
  bool _isSpeaking = false;
  String _lastSpokenText = "";
  DateTime _lastSpokenTime = DateTime.now();

  Function(bool)? onSpeakingStateChanged;

  Future<void> init(AppSettingsModel appSetting) async {
    final List<dynamic> voices = await _flutterTts.getVoices ?? [];
    developer_log.log(voices.toString(), name: "TextToSpeechService.init");

    final bestVoice = await GetBestVoice.getVoice(
      voices: voices,
      language: appSetting.ttsLanguage,
      genderPreference: appSetting.ttsGenderPreference,
    );

    await _flutterTts.setLanguage(appSetting.ttsLanguage);

    if (bestVoice != null) {
      await _flutterTts.setVoice({
        "name": bestVoice['name'],
        "locale": bestVoice['locale'],
      });
    } else if (appSetting.ttsVoiceId.isNotEmpty) {
      await _flutterTts.setVoice({
        "name": appSetting.ttsVoiceId,
        "locale": appSetting.ttsLanguage,
      });
    }

    await _flutterTts.setSpeechRate(appSetting.ttsSpeech);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(appSetting.ttsPitch);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      _setSpeakingState(false);
      _processQueue();
    });

    _flutterTts.setErrorHandler((msg) {
      _setSpeakingState(false);
      _processQueue();
    });

    _flutterTts.setCancelHandler(() {
      _setSpeakingState(false);
      _processQueue();
    });
  }

  Future<void> applyHardwareSettings(AppSettingsModel settings) async {
    try {
      await _flutterTts.setSpeechRate(settings.ttsSpeech);
      await _flutterTts.setPitch(settings.ttsPitch);
      await _flutterTts.setLanguage(settings.ttsLanguage);

      final List<dynamic> voices = await _flutterTts.getVoices ?? [];
      final bestVoice = await GetBestVoice.getVoice(
        voices: voices,
        language: settings.ttsLanguage,
        genderPreference: settings.ttsGenderPreference,
      );

      if (bestVoice != null) {
        await _flutterTts.setVoice({
          "name": bestVoice['name'],
          "locale": bestVoice['locale'],
        });
        developer_log.log(
          "cập nhật cấu hình voice id tự động",
          name: "VoiceProvider",
        );
      } else if (settings.ttsVoiceId.isNotEmpty) {
        await _flutterTts.setVoice({
          "name": settings.ttsVoiceId,
          "locale": settings.ttsLanguage,
        });
        developer_log.log("cập nhật cấu hình voice id", name: "VoiceProvider");
      }

      developer_log.log("cập nhật cấu hình thành công", name: "VoiceProvider");
      return;
    } catch (e) {
      developer_log.log(
        "Không thể cập nhật cấu hình loa: $e",
        name: "VoiceProvider",
      );
    }
  }

  void _setSpeakingState(bool state) {
    _isSpeaking = state;
    if (onSpeakingStateChanged != null) {
      onSpeakingStateChanged!(state);
    }
  }

  Future<void> speak(String text) async {
    final now = DateTime.now();
    if (text == _lastSpokenText &&
        now.difference(_lastSpokenTime).inSeconds < 3) {
      return;
    }
    if (_speechQueue.isNotEmpty && _speechQueue.last == text) {
      return;
    }
    _speechQueue.add(text);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isSpeaking || _speechQueue.isEmpty) return;

    _setSpeakingState(true);

    String textToSpeak = _speechQueue.removeAt(0);
    _lastSpokenText = textToSpeak;
    _lastSpokenTime = DateTime.now();

    await _flutterTts.speak(textToSpeak);
  }

  Future<void> stop() async {
    _speechQueue.clear();
    await _flutterTts.stop();
    if (_isSpeaking) {
      _setSpeakingState(false);
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
