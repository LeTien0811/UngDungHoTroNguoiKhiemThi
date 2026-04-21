import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class FrameQualityEvaluatorResult {
  final ScanStatus status;
  final InputImage? image;

  FrameQualityEvaluatorResult({required this.status, this.image});
}