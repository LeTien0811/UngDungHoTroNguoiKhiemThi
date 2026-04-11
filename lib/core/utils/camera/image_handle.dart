import 'package:build_access/config/process_format_input_image_result.dart';
import 'package:build_access/constant/blur_score.dart';
import 'package:build_access/core/utils/input_image_format.dart';
import 'package:build_access/enum/config.dart';
import 'package:camera/camera.dart';
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
      developer_log.log('Blur score: $blurScore', name: 'ImageHandle.processImageFromFrame');
      if (blurScore < 35) {
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
      rethrow;
    }
  }
}
