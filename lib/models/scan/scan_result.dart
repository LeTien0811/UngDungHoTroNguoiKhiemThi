import 'package:build_access/enum/state.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanResult {
  final ScanStatus status;
  final String? textDetect;
  final RecognizedText? rawRecognizedText;
  final String? command;
  final String? error;
  final String? directoryPath;
  final String? base64Image;

  ScanResult({
    required this.status,
    this.textDetect,
    this.command,
    this.error,
    this.rawRecognizedText,
    this.directoryPath,
    this.base64Image,
  });

  ScanResult copyWith({
    ScanStatus? status,
    String? textDetect,
    RecognizedText? rawRecognizedText,
    String? command,
    String? error,
    String? directoryPath,
    String? base64Image,
  }) {
    return ScanResult(
      status: status ?? this.status,
      textDetect: textDetect ?? this.textDetect,
      rawRecognizedText: rawRecognizedText ?? this.rawRecognizedText,
      command: command ?? this.command,
      error: error ?? this.error,
      directoryPath: directoryPath ?? this.directoryPath,
      base64Image: base64Image ?? this.base64Image,
    );
  }
}