import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'dart:developer' as developer_log;

import 'package:build_access/providers/voice_interaction_provider.dart';

class ReadingResultViewModel extends BaseModel {
  final VoiceInteractionProvider voiceInteractionProvider = getIt<VoiceInteractionProvider>();
  final LocalAIEngine localAIEngine = getIt<LocalAIEngine>();
  final LocalAiProvider localAiProvider = getIt<LocalAiProvider>();
  String rawText = '';
  AiType type = AiType.error;
  String fullResponse = "";

  Future<void> init({required String propRawText, required AiType propType}) async {
    await runSafe(() async {
      rawText = propRawText;
      type = propType;
      localAiProvider.setReady(true);
      notifyListeners();

      if (localAiProvider.status == LocalAiStatus.ready) {
        await _runPipeline(rawText);
      }
    }, 'ReadingResultViewModel.init');
  }

  Future<void> _runPipeline(String rawText) async {
    await runSafe(() async {
      localAiProvider.setProcessing();
      voiceInteractionProvider.speak("Đang xử lý, vui lòng chờ trong giây lát.");

      final regex = RegExp(r'(?<=[.!?])\s+|\n\s*\n');
      List<String> sentences = rawText
          .split(regex)
          .where((s) => s.trim().isNotEmpty)
          .toList();

      List<String> chunks = [];
      String currentChunk = "";
      final int optimalChunkLength = 350;

      for (String sentence in sentences) {
        if ((currentChunk.length + sentence.length) > optimalChunkLength) {
          if (currentChunk.isNotEmpty) {
            chunks.add(currentChunk.trim());
          }
          currentChunk = sentence;
        } else {
          currentChunk += (currentChunk.isEmpty ? "" : " ") + sentence;
        }
      }

      if (currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
      }

      if (chunks.isEmpty) {
        chunks = [rawText];
      }

      developer_log.log(
        'Đã gom ngữ nghĩa thành ${chunks.length} đoạn.',
        name: 'ReadingResultViewModel._runPipeline',
      );

      for (int i = 0; i < chunks.length; i++) {
        if (localAiProvider.status != LocalAiStatus.processing) break;

        String chunk = chunks[i].trim();
        if (chunk.length < 5) continue;

        String correctedChunk = await localAIEngine.processChunk(chunk);

        if (localAiProvider.status != LocalAiStatus.processing) break;

        if (correctedChunk.contains("Sửa lỗi chính tả đoạn văn bản")) continue;

        if (correctedChunk.isNotEmpty) {
          fullResponse += "$correctedChunk ";
          notifyListeners();
          voiceInteractionProvider.speak(correctedChunk);
        }
      }

      if (localAiProvider.status == LocalAiStatus.processing) {
        fullResponse += "\n";
        notifyListeners();
      }
    }, 'ReadingResultViewModel._runPipeline');
  }

  @override
  void dispose() {
    localAiProvider.setDisposed();
    voiceInteractionProvider.stopSpeaking();
    super.dispose();
  }
}
