import 'package:build_access/config/process_image_result.dart';
import 'package:build_access/core/utils/image_algorithm.dart';
import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer_log;

class MyTextRecognizer {
  TextRecognizer? textRecognizer;

  MyTextRecognizer() {
    _initializeRecognizer();
  }

  void _initializeRecognizer() {
    final options = TextRecognizer(script: TextRecognitionScript.latin);
    textRecognizer = options;
  }

  Future<ProcessImageResult> processImage(InputImage inputImage) async {
    try {
      final recognizedText = await textRecognizer!.processImage(inputImage);

      developer_log.log(
        'is text last recognized: ${recognizedText.text}',
        name: 'processImage.MyTextRecognizer',
      );
      final metadata = inputImage.metadata;
      if (metadata == null) return ProcessImageResult(ProcessStatus.recapture);

      int rotationDegrees = 0;
      switch (metadata.rotation) {
        case InputImageRotation.rotation90deg:
          rotationDegrees = 90;
          break;
        case InputImageRotation.rotation180deg:
          rotationDegrees = 180;
          break;
        case InputImageRotation.rotation270deg:
          rotationDegrees = 270;
          break;
        default:
          break;
      }

      ProcessImageResult finalResult = ImageAlgorithm().analyzeTextPosition(
        recognizedText,
        metadata.size.width.toInt(),
        metadata.size.height.toInt(),
        rotationDegrees,
      );
      return finalResult;
    } catch (e) {
      developer_log.log(
        'Chưa thỏa mãn đâu đó: $e',
        name: 'processImage.MyTextRecognizer',
      );
      rethrow;
    }
  }

  void dispose() {
    textRecognizer!.close();
  }
}
