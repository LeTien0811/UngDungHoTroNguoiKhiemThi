import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class MyObjectDetector {
  ObjectDetector? _objectDetector;

  MyObjectDetector() {
    _initializeDetector();
  }

  void _initializeDetector() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: false,
      multipleObjects: false,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<List<DetectedObject>> detectObjects(InputImage inputImage) async {
    if (_objectDetector == null) return [];
    try {
      final List<DetectedObject> objects =
      await _objectDetector!.processImage(inputImage);
      return objects;
    } catch (e) {
      return [];
    }
  }

  Future<void> dispose() async {
    await _objectDetector?.close();
    _objectDetector = null;
  }
}