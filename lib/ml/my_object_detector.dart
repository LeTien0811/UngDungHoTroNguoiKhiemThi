import 'dart:ui';
import 'dart:developer' as developer_log;
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class MyObjectDetector {
  ObjectDetector? _objectDetector;

  MyObjectDetector() {
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

  DetectedObject pickBestObject(List<DetectedObject> objects, Size imageSize) {
    final center = Offset(imageSize.width / 2, imageSize.height / 2);

    objects.sort((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;

      final distA = (a.boundingBox.center - center).distance;
      final distB = (b.boundingBox.center - center).distance;

      final scoreA = areaA / (distA + 1);
      final scoreB = areaB / (distB + 1);

      return scoreB.compareTo(scoreA);
    });

    return objects.first;
  }

  Future<List<DetectedObject>> detectObjects(InputImage inputImage) async {
    if (_objectDetector == null) return [];
    try {
      final List<DetectedObject> objects =
      await _objectDetector!.processImage(inputImage);
      return objects;
    } catch (e) {
      developer_log.log('Lỗi $e', name: 'MyObjectDetector.detectObjects');
      return [];
    }
  }

  Future<void> dispose() async {
    await _objectDetector?.close();
    _objectDetector = null;
  }
}