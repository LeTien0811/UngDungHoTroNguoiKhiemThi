import 'package:build_access/config/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/global_provider.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'dart:developer' as developer_log;

class ReadingResultViewModel extends BaseModel {
  final GlobalProvider globalProvider = getIt<GlobalProvider>();
  final LocalAiEngineService localEngineService = getIt<LocalAiEngineService>();
  String rawText = '';
  String fullResponse = "";
  bool _isDisposed = false;

  Future<void> init(String propRawText) async {
    await runSafe(() async {
      rawText = propRawText;
      notifyListeners();

      if (!globalProvider.isReady) globalProvider.initializeSystem();

      if (localEngineService.isReady) {
        await _runPipeline(rawText);
      }
    }, 'ReadingResultViewModel.init');
  }

  Future<void> _runPipeline(String rawText) async {
    /** await runSafe(() async {
      globalProvider.speakQueue("Đang xử lý, vui lòng chờ trong giây lát.");

      final regex = RegExp(r'(?<=[.!?])\s+|\n\s*\n');
      List<String> sentences = rawText.split(regex).where((s) => s.trim().isNotEmpty).toList();

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

      developer_log.log('Đã gom ngữ nghĩa thành ${chunks.length} đoạn.', name: 'ReadingResultViewModel._runPipeline');

      for (int i = 0; i < chunks.length; i++) {
        if (_isDisposed) break;

        String chunk = chunks[i].trim();
        if (chunk.length < 5) continue;

        String correctedChunk = await localEngineService.processChunk(chunk);

        if (_isDisposed) break;

        if (correctedChunk.contains("Sửa lỗi chính tả đoạn văn bản")) continue;

        if (correctedChunk.isNotEmpty) {
          fullResponse += "$correctedChunk ";
          notifyListeners();
          globalProvider.speakQueue(correctedChunk);
        }
      }

      if (!_isDisposed) {
        fullResponse += "\n";
        notifyListeners();
      }
    }, 'ReadingResultViewModel._runPipeline'); **/

    await runSafe(() async {
      globalProvider.speakQueue("Đang xử lý, vui lòng chờ trong giây lát.");
      fullResponse = rawText;
      notifyListeners();
      globalProvider.speakQueue("Kết quả đọc được. $fullResponse");
    },'ReadingResultViewModel._runPipeline');
  }

  @override
  void dispose() {
    _isDisposed = true;
    globalProvider.stopSpeaking();
    super.dispose();
  }
}