String extractJsonBlock(String rawText) {
  final RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
  final match = jsonRegex.firstMatch(rawText);

  if (match != null) {
    return match.group(0)!;
  }

  throw const FormatException("AI không trả về đúng định dạng JSON.");
}