import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MainSetup {
  static Future<void> setUpTTS(FlutterTts flutterTts) async{
    await flutterTts.setLanguage('vi-VN');
    await flutterTts.setSpeechRate(0.9);
  }

  static Future<bool> checkCameraPermissions(bool hasCameraPermission, Function(String mess) speak) async{
    var cameraStatus = await Permission.camera.status;
    if(!cameraStatus.isGranted) {
      cameraStatus =  await Permission.camera.request();
    }
    hasCameraPermission = cameraStatus.isGranted;

    if (!hasCameraPermission) {
      await speak("Ứng dụng cần cấp quyền camera để hoạt động vui lòng cấp quyền camera để sử dụng ứng dụng");
      openAppSettings();
    } else {
      await speak("Khởi động ứng dụng hoàn tất để sử dụng chứng năng nhận diện vật thể vui lòng vuốt xuống trong màn hình hoặc để sử dụng chức năng nhận diện vật thể và hỏi hãy vuốt lên trong màn hình");
    }
    return hasCameraPermission;
  }

  static Future<bool> checkMicPermissions( bool hasMicPermission, Function(String mess) speak) async{
    var micStatus = await Permission.microphone.status;
    if(!micStatus.isGranted) {
      micStatus =  await Permission.microphone.request();
    }
    hasMicPermission = micStatus.isGranted;
    if (!hasMicPermission) {
      await speak("Ứng dụng cần cấp quyền camera để hoạt động vui lòng cấp quyền camera để sử dụng ứng dụng");
      openAppSettings();
    } else {
      await speak("Khởi động ứng dụng hoàn tất để sử dụng chứng năng nhận diện vật thể vui lòng vuốt xuống trong màn hình hoặc để sử dụng chức năng nhận diện vật thể và hỏi hãy vuốt lên trong màn hình");
    }
    return hasMicPermission;
  }
}