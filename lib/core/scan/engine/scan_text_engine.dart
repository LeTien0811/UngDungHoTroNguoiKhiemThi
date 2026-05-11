import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class ScanTextEngine {
  late TextRecognizer textRecognizer;

  ScanTextEngine() {
    _initializeRecognizer();
  }

  void _initializeRecognizer() {
    final options = TextRecognizer(script: TextRecognitionScript.latin);
    textRecognizer = options;
  }

  Future<RecognizedText> processImage(InputImage inputImage) async {
    try {
      RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      return recognizedText;
    } catch (e) {
      developer_log.log(
        'Chưa thỏa mãn đâu đó: $e',
        name: 'processImage.MyTextRecognizer',
      );
      rethrow;
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
