import 'dart:typed_data';
import 'package:build_access/core/base/base_service.dart';
import 'package:build_access/core/image/image_handle.dart';
import 'package:build_access/core/utils/file_utils.dart';
import 'package:build_access/core/image/device_orientation.dart';
import 'package:build_access/core/scan/ocr_preprocessor.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/core/ml/my_text_recognizer.dart';
import 'package:build_access/models/scan/process_image_result.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:build_access/core/scan/process_case_result.dart';
import 'package:camera/camera.dart';
import 'dart:ui' as ui;

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class AnalyzeTextPositionAndReadText extends BaseService {

  @override
  String get serviceName => 'AnalyzeTextPositionAndReadText';
  final ImageHandle _imageHandle = ImageHandle();
  final MyTextRecognizer _myTextRecognizer = MyTextRecognizer();
  final ProcessCaseResult processCaseResult = ProcessCaseResult();
  final OcrPreprocessor _handleImageWorkerService =
  getIt<OcrPreprocessor>();

  @override
  Future<void> init() async{

  }

  Future<ProcessImageResult?> analyzeTextPositionAndReadText({
    required CameraHardwareManager cameraHardwareManager,
    required CameraImage imageFromFrame,
    required GlobalProvider globalProvider,
    required ui.Size previewSize,
  }) async {
    return await runSafe<ProcessImageResult>(() async {
      final formatResult = await _imageHandle.processImageFromFrame(
        imageFromFrame,
        cameraHardwareManager.camera!,
        cameraHardwareManager.controller!,
      );

      if (formatResult.image == null ||
          formatResult.status != ProcessStatus.ok) {
        log("Ảnh chưa đủ nét, bỏ qua frame...");
        return ProcessImageResult(
          formatResult.status,
          command: "Vui lòng giữ yên điện thoại",
        );
      }

      final int bytesPerRow = imageFromFrame.planes[0].bytesPerRow;
      final int sensorWidth = imageFromFrame.width;
      final int sensorHeight = imageFromFrame.height;

      final dynamic response = await _handleImageWorkerService.processImage(
        imageFromFrame.planes[0].bytes,
        sensorWidth,
        sensorHeight,
        stride: bytesPerRow,
        crop: null,
      );

      if (response == null || response is! Map) {
        log("LỖI VĂNG APP NGẦM: Isolate trả về String -> $response");
        return ProcessImageResult(ProcessStatus.blur);
      }

      final Uint8List optimizedBytes = response['ocrBytes'];
      final Uint8List debugBytes = response['debugBytes'];

      if (optimizedBytes.isEmpty) {
        return ProcessImageResult(ProcessStatus.blur);
      }

      if (debugBytes.isNotEmpty) {
        ImageDebugUtils.saveDebugImage(debugBytes);
      }

      final int rotationDegree = resolveRotationDegree(cameraHardwareManager);

      log(
        'OCR full-frame rotation=$rotationDegree sensor=${cameraHardwareManager.camera!.sensorOrientation} device=${cameraHardwareManager.controller!.value.deviceOrientation} size=${sensorWidth}x$sensorHeight',
      );

      InputImage optimizedInputImage = _imageHandle.createInputImageFromBytes(
        optimizedBytes,
        ui.Size(sensorWidth.toDouble(), sensorHeight.toDouble()),
        rotationDegree,
      );

      ProcessImageResult rawOcrResult = await _myTextRecognizer.processImage(
        optimizedInputImage,
      );

      await processCaseResult.handleProcessResult<ProcessImageResult>(
        result: rawOcrResult,
      );
      return rawOcrResult;
    }, methodName: "DetectAndReadTextFromInputImag");
  }
}