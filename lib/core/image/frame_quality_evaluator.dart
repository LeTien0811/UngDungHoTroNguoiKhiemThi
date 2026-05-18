import 'package:build_access/core/isolate/long_live_worker.dart';
import 'package:build_access/models/image/blur_score_params.dart';
import 'package:build_access/models/image/blur_score_response.dart';
import 'package:build_access/models/scan/frame_quality_evaluator_result.dart';
import 'package:build_access/core/image/algorithm/blur_algrothim.dart';
import 'package:build_access/core/image/mlkit_image_adapter.dart';
import 'package:build_access/enum/state.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;
import 'dart:typed_data';

class FrameQualityEvaluator {
  late final LongLivedWorker<void, BlurScoreParams, BlurScoreResponse> _worker;
  final BlurAlgrothm _blurAlgrothm = BlurAlgrothm();
  bool _isWorkerInitialized = false;

  Future<void> initWorker() async {
    _worker = LongLivedWorker(_blurAlgrothm.computeLaplacianVariance);
    await _worker.init(null);
    _isWorkerInitialized = true;
  }

  void disposeWorker() {
    if (_isWorkerInitialized) {
      _worker.dispose();
      _isWorkerInitialized = false;
    }
  }

  double getDynamicThreshold(double brightness) {
    if (brightness < 40) return 80.0;  // Ánh sáng yếu, hạ thấp tiêu chuẩn
    if (brightness < 80) return 150.0;
    return 250.0; // Ngưỡng thực tế cho ảnh nét sau khi bỏ Smoothing
  }

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
      final plane = imageFromFrame.planes[0];

      final BlurScoreParams params = BlurScoreParams(
        bytes: plane.bytes,
        stride: plane.bytesPerRow,
        height: imageFromFrame.height,
        width: imageFromFrame.width,
      );

      final response = await _worker.execute(params);

      if (response == null) {
        return FrameQualityEvaluatorResult(status: ScanStatus.error);
      }



      final blurScore = response.variance;

      double threshold = getDynamicThreshold(response.avgBrightness);

      developer_log.log(
        'Blur score: $blurScore, Brightness: ${response.avgBrightness}, Threshold: $threshold',
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

      return FrameQualityEvaluatorResult(
        status: ScanStatus.ok,
        image: inputImage,
      );
    } catch (e) {
      developer_log.log('Lỗi $e', name: 'ImageHandle.processImageFromFrame');
      return FrameQualityEvaluatorResult(status: ScanStatus.error);
    }
  }
}
