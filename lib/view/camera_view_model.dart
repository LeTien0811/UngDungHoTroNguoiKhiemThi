import 'package:build_access/config/base_model.dart';
import 'package:build_access/core/utils/camera/image_handle.dart';
import 'package:build_access/enum/config.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/ml/my_text_recognizer.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/services/paddle_ocr_service.dart';
import 'package:build_access/src/features/home_feature/home_features.dart';
import 'package:build_access/src/features/reading_result_feature/reading_result_features.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraViewModel extends BaseModel {
  final ImageHandle _imageHandle = ImageHandle();
  final CameraService cameraService = getIt<CameraService>();
  final ProviderSevice providerSevice = getIt<ProviderSevice>();
  final PaddleOcrService _paddleOcrService = getIt<PaddleOcrService>();
  final MyTextRecognizer _myTextRecognizer = MyTextRecognizer();
  CameraDescription? camera;

  int _consecutiveFrames = 0;
  final int _requiredFrames = 3;
  int _bestTextLength = 0;

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
      if (_isDisposed || cameraService.controller == null || !isCameraReady) {
        throw Exception('Camera đang bận hoặc chưa sẵn sàng');
      }
      if (cameraService.controller!.value.isStreamingImages) return;

      try {
        await cameraService.controller!.startImageStream((
          CameraImage image,
        ) async {
          if (_isDisposed || _isProcessing) return;

          final int currentMs = DateTime.now().millisecondsSinceEpoch;
          if (currentMs - _lastScanTime.millisecondsSinceEpoch < 150) {
            return;
          }
          _lastScanTime = DateTime.now();
          _isProcessing = true;
          notifyListeners();

          try {
            InputImage? inputImage = await _imageHandle.processImageFromFrame(
              image,
              camera!,
              cameraService.controller!,
            );

            if (inputImage == null) {
              _consecutiveFrames = 0;
              throw 'RECAPTURE';
            }

            String textScan = await _myTextRecognizer.processImage(inputImage);
            int currentLength = textScan.trim().length;

            if (currentLength == 0) {
              _consecutiveFrames = 0;
              _bestTextLength = 0;
              throw 'RECAPTURE';
            }

            if (_consecutiveFrames > 0 &&
                currentLength < _bestTextLength * 0.3) {
              developer_log.log(
                'Ảnh nhòe/nhiễu (từ $_bestTextLength tụt xuống $currentLength chữ). Hủy khóa mục tiêu.',
                name: 'CameraViewModel.QualityControl',
              );
              _consecutiveFrames = 0;
              _bestTextLength = currentLength;
              throw 'RECAPTURE';
            }

            if (currentLength > _bestTextLength) {
              _bestTextLength = currentLength;
            }

            _consecutiveFrames++;
            HapticFeedback.lightImpact();

            if (_consecutiveFrames < _requiredFrames) {
              throw 'RECAPTURE';
            }

            developer_log.log(
              'Đã đọc thành công từ google ML KIT: $textScan',
              name: 'CameraViewModel.OCR',
            );

            providerSevice.stopSpeaking();
            notifyListeners();

            providerSevice.speakQueue("Đang quét, giữ nguyên tay");
            HapticFeedback.heavyImpact();

            await stopStream();
            if (_isDisposed) return;

            String textTho = "";
            try {
              XFile file = await cameraService.controller!.takePicture();
              developer_log.log(
                'Đã chụp ảnh thành công lưu ở : ${file.path}',
                name: 'CameraViewModel.OCR',
              );
              textTho = await _paddleOcrService.scanImage(file.path);
              developer_log.log(
                'Kết quả text từ paddle OCR: $textTho',
                name: 'CameraViewModel.OCR',
              );

              // SỬA LẠI LOGIC ĐIỀU HƯỚNG
              bool isSuccess =
                  textTho.trim().isNotEmpty &&
                  !textTho.contains('success: true') &&
                  !textTho.contains('识别成功');

              if (isSuccess) {
                // ĐỌC ĐƯỢC CHỮ THÌ SANG MÀN KẾT QUẢ
                setState(ViewState.idle);
                getIt<NavigatorService>().pushNamedAndRemoveUntil(
                  ReadingResultFeatures.routeName,
                  arguments: textTho,
                );
              } else {
                setState(ViewState.idle);
                // KHÔNG ĐỌC ĐƯỢC HOẶC RÁC THÌ VỀ HOME
                developer_log.log(
                  'Paddle thất bại, quay về Home',
                  name: 'CameraViewModel.OCR',
                );
                getIt<NavigatorService>().pushNamedAndRemoveUntil(
                  HomeFeatures.routerName,
                );
              }
            } catch (e) {
              developer_log.log(
                'Lỗi khi xử lý đến paddle OCR: $e',
                name: 'CameraViewModel.OCR',
              );
              rethrow;
            } finally {
              _consecutiveFrames = 0;
              _bestTextLength = 0;
            }
          } catch (e) {
            if (e == 'RECAPTURE') {
              developer_log.log(
                'Tiếp tục quét...',
                name: 'stream.camera_service',
              );
            } else {
              developer_log.log('Lỗi luồng: $e', name: 'stream.camera_service');
              rethrow;
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
        stopStream();
        getIt<NavigatorService>().pushNamedAndRemoveUntil(
          HomeFeatures.routerName,
        );
        return;
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
    } catch (e) {
      developer_log.log(
        'Lỗi khi hủy view: $e',
        name: 'CameraViewModel.dispose',
      );
    }

    cameraService.dispose();
    _myTextRecognizer.dispose();
    super.dispose();
  }
}
