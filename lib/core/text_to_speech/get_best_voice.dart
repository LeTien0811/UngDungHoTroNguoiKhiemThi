import 'package:build_access/core/text_to_speech/tts_voice_resolver.dart';

class GetBestVoice {
  static Future<Map<String, dynamic>?> getVoice({
    required List<dynamic> voices,
    required String language,
    required String genderPreference,
  }) async {
    final bestVoice = await TtsVoiceResolver.resolveBestVoice(
      voices: voices,
      targetLang: language,
      genderPreference: genderPreference,
    );

    if (bestVoice != null) return bestVoice;

    final fallbackLang =
    voices.where((v) => v['locale'] == language).toList();

    if (fallbackLang.isNotEmpty) return fallbackLang.first;

    return voices.isNotEmpty ? voices.first : null;
  }
}