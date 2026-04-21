import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/camera/vision_stream_coordinator.dart';
import 'package:build_access/core/scan/pipeline/ocr_preprocessor.dart';
import 'package:build_access/core/scan/scan_orchestrator.dart';
import 'package:build_access/core/utils/navigator_service.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/features/reading_result_feature/reading_result_features.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:camera/camera.dart';

class CameraViewModel extends BaseModel {
  final VisionStreamCoordinator _visionStream =
      getIt<VisionStreamCoordinator>();
  final VoiceInteractionProvider voiceInteractionProvider = getIt<VoiceInteractionProvider>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();
  final ScanOrchestrator _scanOrchestrator = getIt<ScanOrchestrator>();

  Future<void> initCamera() async {
    await runSafe(() async {
      voiceInteractionProvider.speak(
        'Bắt đầu tạo camera và lấy nét vật thể vui lòng đưa máy đối diện vật muốn và chờ trong giây lát',
      );
      bool isPrepare = await _visionStream.initCamera();
      if (!isPrepare) {
        voiceInteractionProvider.speak('Khởi tạo camera thất bại');
        return;
      }
      voiceInteractionProvider.speak('Khởi động thành công bắt đầu nhận diện!');
      return;
    }, 'CameraModel.init');
  }

  void scanSuccess(ScanResult result) {
    voiceInteractionProvider.stopSpeaking();
    voiceInteractionProvider.speak("Đọc được thông tin ${result.textDetect}");
    Map<String, dynamic> propResult = {
      "rawText": result.textDetect,
      "type": AiType.ocrCorrection,
    };
    getIt<NavigatorService>().pushNamedAndRemoveUntil(
      ReadingResultFeatures.routeName,
      arguments: propResult,
    );
  }

  Future<void> scanProcess() async {
    if (!getIt<OcrPreprocessor>().isInitialized) {
      await getIt<OcrPreprocessor>().init();
    }

    await _visionStream.startVisionLoop((CameraImage image) async {
      try {
        ScanResult result = await _scanOrchestrator.process(image);
        if (result.status != ScanStatus.ok) {
          voiceInteractionProvider.speak(result.command!);
          return false;
        } else {
          scanSuccess(result);
          return true;
        }
      } catch (e) {
        developer_log.log(
          'Lỗi khi scan nè: $e',
          name: 'CameraViewModel.ScanProcess',
        );
        return false;
      }
    });
  }

  @override
  void dispose() {
    try {
      if (_visionStream.cameraHardwareManager.isCameraStream) {
        _visionStream.cameraHardwareManager.stopStream();
      }
    } catch (e) {
      developer_log.log(
        'Lỗi khi hủy view_models: $e',
        name: 'CameraViewModel.dispose',
      );
    }
    super.dispose();
  }
}
