import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/AI/ai_form_factory.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'dart:developer' as developer_log;

class ScanTextAiEnhancer {
  late final LocalAIEngine _localAiEngine;
  late final LocalAiProvider _aiProvider;

  ScanTextAiEnhancer() {
    _localAiEngine = getIt<LocalAIEngine>();
    _aiProvider = getIt<LocalAiProvider>();
  }

  Future<String> enhance(String text) async {
    if (text.trim().isEmpty) {
      developer_log.log(
        "Text truyền vào xử lý AI rỗng",
        name: "ScanTextAiEnhancer.enhance",
      );
      return "";
    }
    try {
      developer_log.log(
        "Gọi AI xử lý $text",
        name: "ScanTextAiEnhancer.enhance",
      );
      _aiProvider.setProcessing();
      String prompt = AiPromptFactory.buildOcrCorrectionPrompt(text);
      String result = await _localAiEngine.executeTask(prompt);
      _aiProvider.setReady(true);
      developer_log.log(
        "kết quả$result",
        name: "ScanTextAiEnhancer.enhance",
      );
      return result.trim().isNotEmpty ? result : text;
    } catch (e) {
      developer_log.log(
        "Lỗi trong quá trình AI cường hóa: $e",
        name: "ScanTextAiEnhancer.enhance",
      );
      return text;
    }
  }
}
