import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:build_access/models/scan/process_format_input_image_result.dart';
import 'package:build_access/constant/blur_score.dart';
import 'package:build_access/core/image/input_image_format.dart';
import 'package:build_access/enum/config.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class ImageHandle {
  Future<ProcessFormatInputImageResult> processImageFromFrame(
    CameraImage imageFromFrame,
    CameraDescription camera,
    CameraController controller,
  ) async {
    try {
      developer_log.log(
        '--- Đang xử lý frame mới ---',
        name: 'ImageHandle.processImageFromFrame',
      );

      double blurScore = calculateBlurScore(imageFromFrame);
      double brightness = calculateBrightness(imageFromFrame.planes[0].bytes);
      double threshold = getDynamicThreshold(brightness);

      developer_log.log(
        'Blur score: $blurScore, Brightness: $brightness',
        name: 'ImageHandle.processImageFromFrame',
      );
      if (blurScore < threshold) {
        developer_log.log('Ảnh mờ', name: 'ImageHandle.processImageFromFrame');
        return ProcessFormatInputImageResult(ProcessStatus.blur);
      }

      InputImage? inputImage = inputImageFormat(
        imageFromFrame,
        camera,
        controller,
      );

      if (inputImage == null) {
        developer_log.log(
          'lỗi không thể convert',
          name: 'ImageHandle.processImageFromFrame',
        );
        return ProcessFormatInputImageResult(ProcessStatus.recapture);
      }

      return ProcessFormatInputImageResult(ProcessStatus.ok, image: inputImage);
    } catch (e) {
      developer_log.log('Lỗi $e', name: 'ImageHandle.processImageFromFrame');
      rethrow;
    }
  }

  InputImageRotation _getRotation(int degree) {
    switch (degree) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImage createInputImageFromBytes(
    Uint8List grayBytes,
    ui.Size size,
    int rotationDegree,
  ) {
    final int w = size.width.toInt();
    final int h = size.height.toInt();

    // Tạo mảng byte chuẩn NV21: Kích thước = W * H * 1.5
    final int ySize = w * h;
    final int uvSize = ySize ~/ 2;
    final Uint8List nv21Bytes = Uint8List(ySize + uvSize);

    // 1. Chép vùng xám vào Y-plane
    nv21Bytes.setRange(0, ySize, grayBytes);

    // 2. Điền giá trị 128 (trung tính) vào UV-plane
    nv21Bytes.fillRange(ySize, nv21Bytes.length, 128);

    return InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: _getRotation(rotationDegree),
        format: InputImageFormat.nv21, // ANDROID THÍCH CÁI NÀY NHẤT
        bytesPerRow: w,
      ),
    );
  }
}
