import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();

  Function(bool)? onListeningStateChanged;
  Function(String)? onResultText;

  Future<void> init() async {
    try {
      await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (onListeningStateChanged != null) {
              onListeningStateChanged!(false);
            }
          }
        },
        onError: (errorNotification) => debugPrint(errorNotification.errorMsg),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> startListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        localeId: 'vi_VN',
        onResult: (result) {
          if (onResultText != null) {
            onResultText!(result.recognizedWords);
          }
        },
      );
      if (onListeningStateChanged != null) {
        onListeningStateChanged!(true);
      }
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    if (onListeningStateChanged != null) {
      onListeningStateChanged!(false);
    }
  }

  void dispose() {
    _speechToText.stop();
  }
}