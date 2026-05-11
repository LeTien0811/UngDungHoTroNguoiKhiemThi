import 'dart:convert';

import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'dart:developer' as developer_log;

class ScanTextAiEnhancer {
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();

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

      final Stream<String> aiStream = _aiEngine.executeAiTask(
        type: AIType.OCR_SCAN,
        data: text,
      );

      StringBuffer cleanContentBuffer = StringBuffer();
      await for (final chunk in aiStream) {
        try {
          final Map<String, dynamic> chunkMap = jsonDecode(chunk);
          if (chunkMap.containsKey('text')) {
            cleanContentBuffer.write(chunkMap['text']);
          }
        } catch (e) {
          cleanContentBuffer.write(chunk);
        }
      }
      String fullRawResponse = cleanContentBuffer.toString();
      return fullRawResponse;
    } catch (e) {
      developer_log.log(
        "Lỗi trong quá trình AI cường hóa: $e",
        name: "ScanTextAiEnhancer.enhance",
      );
      return text;
    }
  }
}
