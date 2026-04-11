import 'package:build_access/config/base_model.dart';
import 'package:build_access/config/process_case_result.dart';
import 'package:build_access/config/process_format_input_image_result.dart';
import 'package:build_access/config/process_image_result.dart';
import 'package:build_access/core/utils/camera/image_handle.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/features/reading_result_feature/reading_result_features.dart';
import 'dart:developer' as developer_log;
import 'package:build_access/ml/my_text_recognizer.dart';
import 'package:build_access/providers/camera_provider.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/services/camera_service.dart';
import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/features/home_feature/home_features.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraViewModel extends BaseModel {
  final ImageHandle _imageHandle = ImageHandle();
  final CameraService cameraService = getIt<CameraService>();
  final GlobalProvider globalProvider = getIt<GlobalProvider>();
  final CameraProvider cameraProvider = getIt<CameraProvider>();
  final MyTextRecognizer _myTextRecognizer = MyTextRecognizer();
  final ProcessCaseResult processCaseResult = ProcessCaseResult();

  Future<void> initCamera() async {
    await runSafe(() async {
      if (cameraProvider.isDisposed) return;

      await cameraService.init();

      await startProcess();

      globalProvider.speakQueue(
        'Bắt đầu quét hãy đưa điện thoại đối diện vật muốn quét',
      );
    }, 'CameraModel.init');
  }

  Future<void> startProcess() async {
    setState(ViewState.busy);
    await cameraService.startStream((CameraImage imageFromeFrame) async {
      try {
        ProcessFormatInputImageResult inputImage = await _imageHandle
            .processImageFromFrame(
              imageFromeFrame,
              cameraService.camera!,
              cameraService.controller!,
            );

        if (inputImage.image == null) return false;

        bool isFormatCase = await processCaseResult
            .handleProcessResult<ProcessFormatInputImageResult>(
              result: inputImage,
            );

        if (isFormatCase) {
          InputImage image = inputImage.image!;
          ProcessImageResult result = await _myTextRecognizer.processImage(
            image,
          );

          bool isResultCase = await processCaseResult
              .handleProcessResult<ProcessImageResult>(
                result: result,
                isPropFuncRecapture: true,
                onReCapture: () async {
                  globalProvider.stopSpeaking();
                  await Future.delayed(const Duration(milliseconds: 200));
                  globalProvider.speakQueue(result.command!);
                },
              );

          if(isResultCase){
            getIt<NavigatorService>().pushNamedAndRemoveUntil(
                ReadingResultFeatures.routeName,
                arguments: result.textDetect
            );
          }
          return isResultCase;
        }

        return false;
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    try {
      if (cameraService.controller != null &&
          cameraService.controller!.value.isStreamingImages) {
        cameraService.controller!.stopImageStream();
      }
    } catch (e) {
      developer_log.log(
        'Lỗi khi hủy view_models: $e',
        name: 'CameraViewModel.dispose',
      );
    }

    cameraService.dispose();
    _myTextRecognizer.dispose();
    cameraProvider.setDispose();
    super.dispose();
  }
}
