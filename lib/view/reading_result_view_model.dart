import 'package:build_access/config/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'dart:developer' as developer_log;

class ReadingResultViewModel extends BaseModel {
  final ProviderSevice providerSevice = getIt<ProviderSevice>();
  final LocalAiEngineService localEngineService = getIt<LocalAiEngineService>();
  String rawText = '';
  String fullResponse = "";
  bool _isDisposed = false;

  Future<void> init(String propRawText) async {
    runSafe(() async {
      rawText = propRawText;
      notifyListeners();

      if (!providerSevice.isReady) providerSevice.initializeSystem();

      if (localEngineService.isReady) {
        await _runPipeline(rawText);
      }
    }, 'ReadingResultViewModel.init');
  }

  Future<void> _runPipeline(String rawText) async {
    await runSafe(() async {
      providerSevice.speakQueue("Đang xử lý, vui lòng chờ trong giây lát.");

      // Cắt văn bản cẩn thận theo dấu chấm, chấm hỏi, chấm than, hoặc xuống dòng kép
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

      // Add đoạn cuối cùng
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

        // Lọc bỏ rác quá ngắn (như chữ "Search" cô đơn)
        if (chunk.length < 5) continue;

        String correctedChunk = await localEngineService.processChunk(chunk);

        if (_isDisposed) break;

        // Chống AI nhai lại System Prompt
        if (correctedChunk.contains("Sửa lỗi chính tả đoạn văn bản")) continue;

        if (correctedChunk.isNotEmpty) {
          fullResponse += "$correctedChunk ";
          notifyListeners();
          providerSevice.speakQueue(correctedChunk);
        }
      }

      if (!_isDisposed) {
        fullResponse += "\n";
        notifyListeners();
      }
    }, 'ReadingResultViewModel._runPipeline');
  }

  @override
  void dispose() {
    _isDisposed = true;
    providerSevice.stopSpeaking();
    super.dispose();
  }
}