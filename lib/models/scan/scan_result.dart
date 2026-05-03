import 'package:build_access/enum/state.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanResult {
  final ScanStatus status;
  final String? textDetect;
  final RecognizedText? rawRecognizedText;
  final String? command;
  final String? error;

  ScanResult(this.status, {this.textDetect, this.command, this.error, this.rawRecognizedText});

  ScanResult copyWith({
    ScanStatus? status,
    String? textDetect,
    RecognizedText? rawRecognizedText,
    String? command,
    String? error,
  }) {
    return ScanResult(
      status ?? this.status,
      textDetect: textDetect ?? this.textDetect,
      rawRecognizedText: rawRecognizedText ?? this.rawRecognizedText,
      command: command ?? this.command,
      error: error ?? this.error,
    );
  }
}
