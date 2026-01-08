import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:hotronguoikhiemthi_app/util/ai_process.dart';
import 'package:hotronguoikhiemthi_app/util/main_setup.dart';

class AppStateManager extends ChangeNotifier {
  //trang thai
  //loading tong
  bool _isLoading = false;

  // trang thai camera và mic
  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  // trang thai noi
  bool _isSpeaking = false;

  // ham tien ich
  final FlutterTts _flutterTts = FlutterTts();
  final AiProcess ai_process = AiProcess();


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

      await ai_process.initModel();

      await MainSetup.setUpTTS(_flutterTts);
      _hasCameraPermission = await MainSetup.checkCameraPermissions(
        _hasCameraPermission,
        speak,
      );

      _hasMicPermission = await MainSetup.checkMicPermissions(
        _hasMicPermission,
        speak,
      );

      notifyListeners();
    } catch (e) {
      LogErrorServices.showLog(where: 'state manager => init', type: 'loi khi khoi tao', message: '.loi $e');
    }
    setLoading(false);
  }

  Future<void> speak(String text) async {
    if(_isLoading) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    _isSpeaking = true;
    await _flutterTts.speak(text);
    _isSpeaking = false;
  }

  @override
  void dispose() {
    ai_process.dispose();
    _flutterTts.stop();
    super.dispose();
  }

}
