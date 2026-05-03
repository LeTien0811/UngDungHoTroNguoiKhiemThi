import 'package:build_access/core/VoiceCommand/CommandMatcher/fuzzy_matcher.dart';
import 'package:build_access/core/VoiceCommand/CommandMatcher/keyword_matcher.dart';
import 'package:build_access/core/VoiceCommand/CommandMatcher/text_normalizer.dart';
import 'package:build_access/enum/state.dart';
import 'dart:developer' as developer_log;

class CommandMatcher {
  final KeywordMatcher _keywordMatcher = KeywordMatcher();
  IntentType process(String userCommand) {
    try {
      String text = TextNormalizer.normalize(userCommand);

      final extract = _keywordMatcher.matchExact(text);

      if (extract != null) {
        return extract;
      }

      IntentType bestIntent = IntentType.UNKNOWN;
      double maxScore = 0.0;

      _keywordMatcher.keywords.forEach((intent, keywords) {
        for (final keyword in keywords) {
          final score = FuzzyMatcher.similarity(text, keyword);
          if (score > maxScore) {
            maxScore = score;
            bestIntent = intent;
          }
        }
      });

      return bestIntent;
    } catch (e) {
      developer_log.log('Lỗi CommandMatcher: $e', name: 'CommandMatcher');
      return IntentType.UNKNOWN;
    }
  }
}
