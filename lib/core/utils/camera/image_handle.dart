import 'dart:io';
import 'package:build_access/core/utils/device_orientation.dart';
import 'package:build_access/core/utils/image_algorithm.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class ImageHandle {
  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
    CameraController controller,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          orientationsCheck[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<InputImage?> processImageFromFrame(
    CameraImage imageFromFrame,
    Function(String message) callSpeak,
    CameraDescription camera,
    CameraController controller,
  ) async {
    try {
      developer_log.log(
        '--- Đang xử lý frame mới ---',
        name: 'ImageHandle.processImageFromFrame',
      );

      double blurScore = ImageAlgorithm.calculateBlurScore(imageFromFrame);

      if (blurScore < 15) {
        developer_log.log('Ảnh mờ', name: 'ImageHandle.processImageFromFrame');
        callSpeak(
          "Ảnh mờ vui lòng dữ yên điện thoại hoặc di chuyển để lấy nét",
        );
        throw ("RECAPTURE");
      }

      InputImage? inputImage = _inputImageFromCameraImage(
        imageFromFrame,
        camera,
        controller,
      );

      if (inputImage == null) {
        developer_log.log(
          'lỗi không thể convert',
          name: 'ImageHandle.processImageFromFrame',
        );
        throw('lỗi không thể convert input Image');
      }
      return inputImage;
    } catch (e) {
      rethrow;
    }
  }
}
