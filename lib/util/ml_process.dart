import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlProcess {
  static final TextRecognizer textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  static Future<void> ImageToSpeech(InputImage image) async{
    final result = await textRecognizer.processImage(image);
    String fullText = result.text;
  }

  void dispose() {
    textRecognizer.close();
  }
}
