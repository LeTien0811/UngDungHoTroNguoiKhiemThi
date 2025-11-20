import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class AppStateManager extends ChangeNotifier {
  //trang thai
  bool _isLoading = false;
  bool _hasCameraPermisson = false;
  bool _hasMicPermisson = false;

  //tts ho tro thong bao bang giong noi cho nguoi khiem thi
  final FlutterTts _flutterTts = FlutterTts();

  // getters
  bool get isLoading => _isLoading;
  bool get hasCameraPermisson => _hasCameraPermisson;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> initializeSystem() async{
    setLoading(true);
    await _setUpTTS();
    await _checkPermissons();
    setLoading(false);
  }

  Future<void> _setUpTTS() async{
    await _flutterTts.setLanguage('vi-VN');
    await _flutterTts.setSpeechRate(0.9);
  }

  Future<void> _checkPermissons() async{
    var cameraStatus = await Permission.camera.status;
    if(!cameraStatus.isGranted) {
      cameraStatus =  await Permission.camera.request();
    }

    var micStatus = await Permission.microphone.status;
    if(!micStatus.isGranted) {
      micStatus =  await Permission.microphone.request();
    }

    _hasCameraPermisson = cameraStatus.isGranted;
    _hasMicPermisson = micStatus.isGranted;

    if (!_hasCameraPermisson) {
      await _speak("Ứng dụng cần cấp quyền camera để hoạt động vui lòng cấp quyền camera để sử dụng ứng dụng");
      openAppSettings();
    } else {
      await _speak("Khởi động ứng dụng hoàn tất để sử dụng chứng năng nhận diện vật thể vui lòng vuốt xuống trong màn hình hoặc để sử dụng chức năng nhận diện vật thể và hỏi hãy vuốt lên trong màn hình");
    }
    notifyListeners();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

}