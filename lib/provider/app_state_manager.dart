import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hotronguoikhiemthi_app/model/ai_response.dart';
import 'package:hotronguoikhiemthi_app/services/ai_services.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:hotronguoikhiemthi_app/util/ai_process.dart';
import 'package:hotronguoikhiemthi_app/util/main_setup.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AppStateManager extends ChangeNotifier {
  //trang thai
  //loading tong
  bool _isLoading = false;

  // trang thai camera và mic
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  // trang thai noi
  bool _isSpeaking = false;

  // trang thai lang nghe
  bool _isRecordAudio = false;

  // trang thai kich hoat speech
  bool _isSpeechEnable = false;

  final Queue<String> _speechQueue = Queue<String>();

  // ham tien ich
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();

  // ai ho tro
  final AIProcess aiProcess = AIProcess();
  late AIServices aiServices;


  //getter
  bool get isLoading => _isLoading;
  bool get hasCameraPermission => _hasCameraPermission;
  bool get hasMicPermission => _hasMicPermission;


  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> initializeSystem() async {
    if(_isLoading) return;
    setLoading(true);
    try {

      await aiProcess.initModel();

      aiServices = AIServices(aiProcess);

      await MainSetup.setUpTTS(_flutterTts);

      _flutterTts.setCompletionHandler(() {
          _isSpeaking = false;
          _processSpeechQueue();
      });


      _hasCameraPermission = await MainSetup.checkCameraPermissions(
        _hasCameraPermission,
        speak,
      );

      _hasMicPermission = await MainSetup.checkMicPermissions(
        _hasMicPermission,
        speak,
      );

      if(_hasCameraPermission && _hasMicPermission) {
        _isSpeechEnable = await _speechToText.initialize();
        await speak("Khởi động ứng dụng hoàn tất để sử dụng chứng năng nhận diện vật thể vui lòng vuốt xuống trong màn hình hoặc để sử dụng chức năng nhận diện vật thể và hỏi hãy vuốt lên trong màn hình");
      }
      notifyListeners();
    } catch (e) {
      LogErrorServices.showLog(where: 'state manager => init', type: 'loi khi khoi tao', message: '.loi $e');
    }
    setLoading(false);
  }

  Future<void> speak(String text, {bool priority = false}) async {
    if(_isLoading || _isRecordAudio) return;
    LogErrorServices.showLog(where: 'state manager => speek', type: 'speek', message: 'gọi nói');
    if(priority) {
      // o day neu la thong bao quan trong thi giai quyet hang doi va doc luon
      await stopSpeaking();
      _speechQueue.add(text);
      _processSpeechQueue();
      LogErrorServices.showLog(where: 'state manager => speek', type: 'speek', message: ' nói liền');
    } else {
      // con thong bao eo quan trong thi cho
      _speechQueue.add(text);
      LogErrorServices.showLog(where: 'state manager => speek', type: 'speek', message: ' nói sau');
      if (!_isSpeaking) {
        // neu nhu dang ranh quai chuong thi no se doc ln ko can cho
        LogErrorServices.showLog(where: 'state manager => speek', type: 'speek', message: ' nói liền');
        _processSpeechQueue();
      }
    }
    return;
  }

  Future<void> startSpeech() async {
    if(_isLoading || _isSpeaking) return;

    if(!_isSpeechEnable ) {
      await speak('MicroPhone chưa được bật vui lòng kiểm tra lại cài đặt', priority: true);
      return;
    }

    await speak('Vui lòng nói yêu cầu của bạn', priority: true);

    await stopSpeaking();

    _isRecordAudio = true;
    notifyListeners();
    String words = '';
    await _speechToText.listen(
      onResult: (result) async{
        words += result.recognizedWords;
        if(result.finalResult) {
          _speechToText.stop();
          final AIResponse? response =  await aiServices.askAIResponse(words);
          LogErrorServices.showLog(where: 'APP state', type: 'Xu ly hien thi response tu ai', message: 'Ai tra ve $response');
        }
      },
      localeId: 'vi-VN',
      listenMode: ListenMode.dictation,
      partialResults: false,
      pauseFor: const Duration(seconds: 3)
    );
  }

  Future<void> _processSpeechQueue() async{
    if(_isRecordAudio || _speechQueue.isEmpty) {
      _isSpeaking = false;
      return;
    }

    if(_isSpeaking) return;

    _isSpeaking = true;

    final textToSpeech = _speechQueue.removeFirst();
    LogErrorServices.showLog(where: 'state manager => _processSpeechQueue', type: '_processSpeechQueue', message: ' nói nè');
    await _flutterTts.speak(textToSpeech);
    notifyListeners();
    return;
  }

  Future<void> stopSpeaking() async {
    _speechQueue.clear();
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    aiProcess.dispose();
    _flutterTts.stop();
    super.dispose();
  }

}
