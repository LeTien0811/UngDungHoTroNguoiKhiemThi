import 'package:build_access/core/utils/image_algorithm.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class MyTextRecognizer {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> processImage(InputImage inputImage, Function(String mess) callSpeak) async {
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      developer_log.log('is text last recognized: ${recognizedText.text}', name: 'processImage.MyTextRecognizer');
      final metadata = inputImage.metadata;
      if(metadata == null) return;

      int rotationDegrees = 0;
      switch(metadata.rotation) {
        case InputImageRotation.rotation90deg: rotationDegrees = 90; break;
        case InputImageRotation.rotation180deg: rotationDegrees = 180; break;
        case InputImageRotation.rotation270deg: rotationDegrees = 270; break;
        default: break;
      }

      ImageAlgorithm.analyzeTextPosition(
          recognizedText,
          metadata.size.width.toInt(),
          metadata.size.height.toInt(),
          rotationDegrees,
          callSpeak,
      );
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}