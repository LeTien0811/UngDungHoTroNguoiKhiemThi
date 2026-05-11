import 'package:build_access/providers/voice_interaction_provider.dart';

class StreamVoiceHelper {
  static Future<String> speakStreamBySentence({
    required Stream<String> stream,
    required VoiceInteractionProvider voiceProvider,
  }) async {
    StringBuffer sentenceBuffer = StringBuffer();
    StringBuffer fullBuffer = StringBuffer();

    final RegExp sentenceEnd = RegExp(r'[.,?!:;\n]');

    await for (final chunk in stream) {
      sentenceBuffer.write(chunk);
      fullBuffer.write(chunk);
      String currentContent = sentenceBuffer.toString();
      if (currentContent.contains(sentenceEnd)) {
        await voiceProvider.speak(currentContent);
        sentenceBuffer.clear();
      }
    }

    if(sentenceBuffer.isNotEmpty) {
      String remainingContent = sentenceBuffer.toString().trim();
      if(remainingContent.isNotEmpty) {
        await voiceProvider.speak(remainingContent);
      }
    }
    return Future.value(fullBuffer.toString().trim());
  }
}
