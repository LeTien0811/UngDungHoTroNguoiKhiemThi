import 'package:build_access/config/base_model.dart';
import 'package:build_access/core/utils/camera/image_handle.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/enum/config.dart';
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

  Future<void> initCamera() async {
    await runSafe(() async {
      camera = await cameraService.getFirstCamera();
      await cameraService.init(camera!);
      await startStream();
    }, 'CameraModel.init');
  }

  Future<void> startStream() async {
    if (state == ViewState.busy) {
      return;
    }
    await runSafe(() async {
      if (cameraService.controller!.value.isStreamingImages || camera == null) return;
      await cameraService.controller!.startImageStream((
        CameraImage image,
      ) async {
        if (DateTime.now().difference(_lastScanTime).inMilliseconds <
            _throttleDuration) {
          return;
        }

        try {
          _lastScanTime = DateTime.now();

         InputImage? inputImage = await _imageHandle.processImageFromFrame(
            image,
            providerSevice.speechQueue as Function(String message),
            camera!,
            cameraService.controller!,
          );

          if(inputImage != null) {
            throw('RECAPTURE');
          }

          String textScan = await _myTextRecognizer.processImage(inputImage!);

          NavigatorService().pushNamedAndRemoveUntil(ReadingResultFeatures.routeName, arguments: textScan);

        } catch (e) {
          if (e == 'RECAPTURE') {
            developer_log.log(
              'Không nhận diện được quét lại: $e',
              name: 'stream.camera_service',
            );
          } else if (e == 'SUCCESS_READING') {
            await stopStream();
          } else {
            developer_log.log(
              'Lỗi luồng Camera: $e',
              name: 'stream.camera_service',
            );
            rethrow;
          }
        } finally {
          setState(ViewState.idle);
        }
      });
    }, "CameraViewModel.startStream");
  }

  Future<void> stopStream() async {
    await runSafe(() async {
      if (cameraService.controller != null &&
          cameraService.controller!.value.isStreamingImages) {
        await cameraService.controller!.stopImageStream();
        return;
      }
    }, 'CameraModel.stopStream');
  }

  @override
  void dispose() {
    super.dispose();
    cameraService.dispose();
    _myTextRecognizer.dispose();
  }
}
