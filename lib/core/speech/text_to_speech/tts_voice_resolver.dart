class TtsVoiceResolver {
  static String? _cachedVoiceId;

  static Future<Map<String, dynamic>?> resolveBestVoice({
    required List voices,
    required String targetLang,
    String genderPreference = "auto",
  }) async {
    if (_cachedVoiceId != null) {
      try {
        return voices.firstWhere((v) => v['name'] == _cachedVoiceId);
      } catch (_) {}
    }

    final filtered = voices.where((v) {
      final Map<dynamic, dynamic> voiceMap = v as Map;
      return voiceMap['locale'] == targetLang;
    }).toList();

    if (filtered.isEmpty) return null;

    filtered.sort((a, b) {
      bool aLocal = a['name'].toString().contains("local");
      bool bLocal = b['name'].toString().contains("local");

      if (aLocal && !bLocal) return -1;
      if (!aLocal && bLocal) return 1;
      return 0;
    });

    List genderFiltered = filtered;

    if (genderPreference != "auto") {
      genderFiltered = filtered.where((v) {
        final name = v['name'].toString().toLowerCase();

        if (genderPreference == "female") {
          return name.contains("female") ||
              name.contains("fem") ||
              name.contains("woman") ||
              name.contains("vi-f");
        }

        if (genderPreference == "male") {
          return name.contains("male") ||
              name.contains("man") ||
              name.contains("vi-m");
        }

        return true;
      }).toList();

      if (genderFiltered.isEmpty) {
        genderFiltered = filtered; // fallback
      }
    }

    final best = genderFiltered.first;

    _cachedVoiceId = best['name'].toString();

    return Map<String, dynamic>.from(best);
  }
}
