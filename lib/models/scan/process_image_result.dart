import 'package:build_access/enum/config.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ProcessImageResult {
  final ProcessStatus status;
  final String? textDetect;
  final RecognizedText? rawRecognizedText;
  final String? command;
  final String? error;

  ProcessImageResult(this.status, {this.textDetect, this.command, this.error, this.rawRecognizedText});

  ProcessImageResult copyWith({
    ProcessStatus? status,
    String? textDetect,
    RecognizedText? rawRecognizedText,
    String? command,
    String? error,
  }) {
    return ProcessImageResult(
      status ?? this.status,
      textDetect: textDetect ?? this.textDetect,
      rawRecognizedText: rawRecognizedText ?? this.rawRecognizedText,
      command: command ?? this.command,
      error: error ?? this.error,
    );
  }
}
