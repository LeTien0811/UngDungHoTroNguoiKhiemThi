import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:build_access/core/base/base_service.dart';
import 'package:build_access/models/scan/process_image_result.dart';
import 'package:build_access/core/scan/process_case_result.dart';
import 'package:build_access/core/image/image_handle.dart';
import 'package:build_access/core/utils/file_utils.dart';
import 'package:build_access/core/image/coordinate_mapper.dart';
import 'package:build_access/core/image/device_orientation.dart';
import 'package:build_access/core/scan/ocr_preprocessor.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/core/ml/my_object_detector.dart';
import 'package:build_access/core/ml/my_text_recognizer.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/camera/camera_hardware_manager.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class DetectAndRecognizerText extends BaseService {
  @override
  String get serviceName => 'ReadTextFromImage';
  final ImageHandle _imageHandle = ImageHandle();
  final MyTextRecognizer _myTextRecognizer = MyTextRecognizer();
  final MyObjectDetector _myObjectDetector = MyObjectDetector();
  final ProcessCaseResult processCaseResult = ProcessCaseResult();
  final OcrPreprocessor _handleImageWorkerService =
      getIt<OcrPreprocessor>();

  ui.Rect? _lastBox;

  ui.Rect _smoothBox(ui.Rect newBox) {
    if (_lastBox == null) {
      _lastBox = newBox;
      return newBox;
    }

    const double alpha = 0.6;

    _lastBox = ui.Rect.fromLTRB(
      _lastBox!.left * alpha + newBox.left * (1 - alpha),
      _lastBox!.top * alpha + newBox.top * (1 - alpha),
      _lastBox!.right * alpha + newBox.right * (1 - alpha),
      _lastBox!.bottom * alpha + newBox.bottom * (1 - alpha),
    );

    return _lastBox!;
  }

  ui.Rect _focusLabelRegion(ui.Rect objectBox, ui.Size imageSize) {
    final bool isLandscapeObject = objectBox.width >= objectBox.height;
    final double horizontalInsetRatio = isLandscapeObject ? 0.18 : 0.12;
    final double verticalInsetRatio = isLandscapeObject ? 0.10 : 0.18;

    final double insetX = objectBox.width * horizontalInsetRatio;
    final double insetY = objectBox.height * verticalInsetRatio;

    final ui.Rect focused = ui.Rect.fromLTRB(
      objectBox.left + insetX,
      objectBox.top + insetY,
      objectBox.right - insetX,
      objectBox.bottom - insetY,
    );

    return ui.Rect.fromLTRB(
      focused.left.clamp(0.0, imageSize.width),
      focused.top.clamp(0.0, imageSize.height),
      focused.right.clamp(0.0, imageSize.width),
      focused.bottom.clamp(0.0, imageSize.height),
    );
  }

  static const int maxTrackingMiss = 5;

  @override
  Future<void> init() async {
    setBusy();
    _handleImageWorkerService.init();
    setIdle();
    setInitialized(true);
  }

  Future<ProcessImageResult?> detectObjectAndReadTextFromInputImage({
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
      final ui.Size sensorSize = ui.Size(
        imageFromFrame.width.toDouble(),
        imageFromFrame.height.toDouble(),
      );

      dynamic response;
      ui.Rect? targetBox;
      Uint8List? optimizedBytes;

      Map<String, int>? realCoords;

      if (_lastBox != null) {
        targetBox = _lastBox;
        log("Dùng lại Box cũ để tracking");
      } else {
        final objects = await _myObjectDetector.detectObjects(
          formatResult.image!,
        );

        log("Tìm thấy ${objects.length} vật thể");

        if (objects.isNotEmpty) {
          final bestObj = _myObjectDetector.pickBestObject(objects, sensorSize);
          final ui.Rect smoothedBox = _smoothBox(bestObj.boundingBox);
          targetBox = _focusLabelRegion(smoothedBox, sensorSize);
          log(
            'BOX raw=${bestObj.boundingBox} smooth=$smoothedBox focused=$targetBox sensor=${sensorSize.width}x${sensorSize.height}',
          );
        } else {
          targetBox = null;
          _lastBox = null;
          log("Không tìm thấy vật thể nào!");
          return ProcessImageResult(
            ProcessStatus.recapture,
            command: "Hãy đưa gói sản phẩm vào giữa camera",
          );
        }
      }

      if (targetBox != null) {
        realCoords = CoordinateMapper.mapToImagePixels(
          mlKitRect: targetBox,
          imageSize: sensorSize,
          previewSize: previewSize,
          sensorOrientation: cameraHardwareManager.camera!.sensorOrientation,
        );

        log(
          "CROP BIẾN: x:${realCoords['x']}, y:${realCoords['y']}, w:${realCoords['w']}, h:${realCoords['h']}",
        );
        log(
          'CROP DEBUG preview=${previewSize.width}x${previewSize.height} sensor=${sensorSize.width}x${sensorSize.height} sensorOrientation=${cameraHardwareManager.camera!.sensorOrientation}',
        );
      }

      response = await _handleImageWorkerService.processImage(
        imageFromFrame.planes[0].bytes,
        imageFromFrame.width,
        imageFromFrame.height,
        stride: bytesPerRow,
        crop: realCoords,
      );

      log("check response");

      if (response == null || response is! Map) {
        log("LỖI VĂNG APP NGẦM: Isolate trả về String -> $response");
        return ProcessImageResult(ProcessStatus.blur);
      }

      optimizedBytes = response['ocrBytes'];
      final Uint8List debugBytes = response['debugBytes'];

      final int outW = response['outW'] ?? sensorSize.width.toInt();
      final int outH = response['outH'] ?? sensorSize.height.toInt();

      if (optimizedBytes!.isEmpty) {
        return ProcessImageResult(ProcessStatus.blur);
      }


      final int rotationDegree = resolveRotationDegree(cameraHardwareManager);

      if (debugBytes.isNotEmpty) {
        ImageDebugUtils.saveDebugImage(
          debugBytes,
          rotationDegree: rotationDegree,
        );
      }

      log(
        'OCR detect rotation=$rotationDegree sensor=${cameraHardwareManager.camera!.sensorOrientation} device=${cameraHardwareManager.controller!.value.deviceOrientation} crop=${realCoords?['w']}x${realCoords?['h']}',
      );
      final int finalW = (outW ~/ 2) * 2;
      final int finalH = (outH ~/ 2) * 2;

      final int yLength = finalW * finalH;
      final int uvLength = (yLength / 2).round();
      final Uint8List nv21PaddedBytes = Uint8List(yLength + uvLength);

      // Copy ảnh Xám của ông vào kênh Y
      if (optimizedBytes.length >= yLength) {
        nv21PaddedBytes.setRange(0, yLength, optimizedBytes.sublist(0, yLength));
      } else {
        nv21PaddedBytes.setRange(0, optimizedBytes.length, optimizedBytes);
      }
      // Bơm thêm màu xám trung tính (128) vào kênh U/V cho đủ chuẩn NV21
      nv21PaddedBytes.fillRange(yLength, yLength + uvLength, 128);

      InputImage optimizedInputImage = _imageHandle.createInputImageFromBytes(
        nv21PaddedBytes,
        ui.Size(finalW.toDouble(), finalH.toDouble()),
        rotationDegree,
      );


      ProcessImageResult rawOcrResult = await _myTextRecognizer.processImage(
        optimizedInputImage,
      );

      return rawOcrResult;
    }, methodName: "DetectAndReadTextFromInputImag");
  }

  @override
  Future<void> dispose() async {
    _myTextRecognizer.dispose();
    _myObjectDetector.dispose();
    _handleImageWorkerService.dispose();
  }
}
