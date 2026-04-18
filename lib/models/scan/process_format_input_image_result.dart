import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ProcessFormatInputImageResult {
  final ProcessStatus status;
  final InputImage? image;

  ProcessFormatInputImageResult(this.status, {this.image});
}