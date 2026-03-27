import 'package:build_access/config/base_model.dart';
import 'package:build_access/setups/permissions_setup.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ProviderSevice extends BaseModel {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isReady = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String recognizedText = "";
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  bool get isReady => _isReady;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get hasCameraPermission => _hasCameraPermission;
  bool get hasMicPermission => _hasMicPermission;

  final List<String> speechQueue = [];

  Future<void> initializeSystem() async {
    _hasCameraPermission = await PermissionsSetup.checkCameraPermissions(
      _hasCameraPermission,
      speakQueue,
    );

    _hasMicPermission = await PermissionsSetup.checkMicPermissions(
      _hasMicPermission,
      speakQueue,
    );

    await _initMic();
    await _initVoice();

    _isReady = true;
    notifyListeners();

    speakQueue("Hệ thống đã sẵn sàng.");
    speakQueue("Vuốt từ trên xuống để để bắt đầu quét nhận diện mà không cần mạng");
    speakQueue("Vuốt từ dưới lên để bắt đầu quét thông minh");
  }

  Future<void> _initMic() async {
    try {
      await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (errorNotification) => debugPrint("Lỗi Mic: $errorNotification"),
      );
    } catch (e) {
      debugPrint("Lỗi khởi tạo Mic: $e");
    }
  }

  void startListening() async {
    stopSpeaking();

    if (!_speechToText.isListening) {
      await _speechToText.listen(
        localeId: 'vi_VN',
        onResult: (result) {
          recognizedText = result.recognizedWords;
          notifyListeners();

          if (result.finalResult) {
            debugPrint("Người dùng nói: $recognizedText");
          }
        },
      );
      _isListening = true;
      notifyListeners();
    }
  }

  void stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> _initVoice() async {
    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
      processQueue();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      processQueue();
    });
  }


  String _lastSpokenText = "";
  DateTime _lastSpokenTime = DateTime.now();

  void speakQueue(String text) {
    if (text == _lastSpokenText && DateTime.now().difference(_lastSpokenTime).inSeconds < 3) {
      return;
    }
    if (speechQueue.isNotEmpty && speechQueue.last == text) {
      return;
    }
    speechQueue.add(text);
    processQueue();
  }

  Future<void> processQueue() async {
    if (_isSpeaking || speechQueue.isEmpty) return;

    _isSpeaking = true;
    notifyListeners();

    String textToSpeak = speechQueue.removeAt(0);
    _lastSpokenText = textToSpeak;
    _lastSpokenTime = DateTime.now();
    await _flutterTts.speak(textToSpeak);
  }

  Future<void> stopSpeaking() async {
    speechQueue.clear();
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _speechToText.stop();
    _flutterTts.stop();

  }
}