import 'package:build_access/models/scan/frame_quality_evaluator_result.dart';
import 'package:build_access/constant/blur_score.dart';
import 'package:build_access/core/image/mlkit_image_adapter.dart';
import 'package:build_access/enum/state.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class FrameQualityEvaluator {
  Future<FrameQualityEvaluatorResult> processImageFromFrame(
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
        return FrameQualityEvaluatorResult(status: ScanStatus.blur);
      }

      InputImage? inputImage = MlKitImageAdapter.convertCameraImage(
        imageFromFrame,
        camera,
        controller,
      );

      if (inputImage == null) {
        developer_log.log(
          'lỗi không thể convert',
          name: 'ImageHandle.processImageFromFrame',
        );
        return FrameQualityEvaluatorResult(status: ScanStatus.recapture);
      }

      return FrameQualityEvaluatorResult(status: ScanStatus.ok, image: inputImage);
    } catch (e) {
      developer_log.log('Lỗi $e', name: 'ImageHandle.processImageFromFrame');
      return FrameQualityEvaluatorResult(status: ScanStatus.error);
    }
  }
}
