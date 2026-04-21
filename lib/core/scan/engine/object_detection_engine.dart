import 'dart:ui';
import 'dart:developer' as developer_log;
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectionEngine {
  late ObjectDetector _objectDetector;

   ObjectDetectionEngine() {
    _initializeDetector();
  }

  void _initializeDetector() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: false,
      multipleObjects: false,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<Rect?> detectBestObject(InputImage inputImage) async {
    try {
      final List<DetectedObject> objects = await _objectDetector.processImage(
        inputImage,
      );

      if (objects.isEmpty) return null;

      if (objects.length == 1) return objects.first.boundingBox;

      objects.sort((a, b) {
        final areaA = a.boundingBox.width * a.boundingBox.height;
        final areaB = b.boundingBox.width * b.boundingBox.height;
        return areaB.compareTo(areaA);
      });

      return objects.first.boundingBox;
    } catch (e) {
      developer_log.log(
        'Lỗi Object Detection: $e',
        name: 'ObjectDetectionEngine',
      );
      return null;
    }
  }

  Future<void> dispose() async {
    await _objectDetector.close();
  }
}
