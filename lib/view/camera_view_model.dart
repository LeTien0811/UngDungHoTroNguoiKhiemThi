import 'package:build_access/config/base_model.dart';
import 'package:build_access/core/utils/camera/image_handle.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/ml/my_text_recognizer.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/src/features/reading_result_feature/reading_result_features.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraViewModel extends BaseModel {
  final ImageHandle _imageHandle = ImageHandle();
  final CameraService cameraService = getIt<CameraService>();
  final ProviderSevice providerSevice = getIt<ProviderSevice>();
  final MyTextRecognizer _myTextRecognizer = MyTextRecognizer();
  CameraDescription? camera;

  final int _throttleDuration = 1000;
  DateTime _lastScanTime = DateTime.now();
  bool _isProcessing = false;
  bool isCameraReady = false;
  bool _isDisposed = false;

  Future<void> initCamera() async {
    await runSafe(() async {
      _isDisposed = false;
      isCameraReady = false;
      notifyListeners();

      camera = await cameraService.getFirstCamera();
      if (camera == null) return;

      await cameraService.init(camera!);
      if (_isDisposed) return;

      isCameraReady = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      if (_isDisposed) return;

      await startStream();

      if (_isDisposed) return;
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isDisposed) return;

      providerSevice.speakQueue(
        'Bắt đầu quét hãy đưa điện thoại đối diện vật muốn quét',
      );
    }, 'CameraModel.init');
  }

  Future<void> startStream() async {
    await runSafe(() async {
      if (_isDisposed || cameraService.controller == null || !isCameraReady)
        return;
      if (cameraService.controller!.value.isStreamingImages) return;

      try {
        await cameraService.controller!.startImageStream((
          CameraImage image,
        ) async {
          if (_isDisposed ||
              _isProcessing ||
              DateTime.now().difference(_lastScanTime).inMilliseconds <
                  _throttleDuration) {
            return;
          }

          _isProcessing = true;
          _lastScanTime = DateTime.now();
          notifyListeners();

          try {
            InputImage? inputImage = await _imageHandle.processImageFromFrame(
              image,
              camera!,
              cameraService.controller!,
            );

            if (inputImage == null) throw 'RECAPTURE';
            String textScan = await _myTextRecognizer.processImage(inputImage);
            if (textScan.trim().isEmpty) throw 'RECAPTURE';

            developer_log.log(
              'Đã đọc thành công: $textScan',
              name: 'CameraViewModel.OCR',
            );
            providerSevice.stopSpeaking();

            await stopStream();
            if (_isDisposed) return;

            getIt<NavigatorService>().pushNamedAndRemoveUntil(
              ReadingResultFeatures.routeName,
              arguments: textScan,
            );
          } catch (e) {
            if (e == 'RECAPTURE') {
              developer_log.log(
                'Tiếp tục quét...',
                name: 'stream.camera_service',
              );
            } else {
              developer_log.log('Lỗi luồng: $e', name: 'stream.camera_service');
            }
          } finally {
            _isProcessing = false;
            if (!_isDisposed) notifyListeners();
          }
        });
      } catch (e) {
        developer_log.log(
          'Lỗi khởi động stream: $e',
          name: 'CameraViewModel.startStream',
        );
      }
    }, "CameraViewModel.startStream");
  }

  Future<void> stopStream() async {
    if (_isDisposed) return;
    try {
      if (cameraService.controller != null &&
          cameraService.controller!.value.isStreamingImages) {
        await cameraService.controller!.stopImageStream();
      }
    } catch (e) {
      developer_log.log(
        'Lỗi dừng stream: $e',
        name: 'CameraViewModel.stopStream',
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    isCameraReady = false;

    try {
      if (cameraService.controller != null &&
          cameraService.controller!.value.isStreamingImages) {
        cameraService.controller!.stopImageStream();
      }
    } catch (e) {}

    cameraService.dispose();
    _myTextRecognizer.dispose();
    super.dispose();
  }
}
