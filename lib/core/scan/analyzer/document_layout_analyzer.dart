import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DocumentLayoutAnalyzer {
  static StringBuffer process(RecognizedText text) {
    List<TextBlock> blocks = List.from(text.blocks);

    blocks.sort((a, b) {
      double heightTolerance = a.boundingBox.height * 0.5;
      if ((a.boundingBox.center.dy - b.boundingBox.center.dy).abs() <
          heightTolerance) {
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      return a.boundingBox.top.compareTo(b.boundingBox.top);
    });

    StringBuffer finalStructuredText = StringBuffer();

    for (var block in blocks) {
      for (var line in block.lines) {
        finalStructuredText.write('${line.text} ');
      }
      finalStructuredText.write('. \n');
    }
    return finalStructuredText;
  }
}
