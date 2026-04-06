import 'dart:async';
import 'dart:developer' as developer_log;
import 'package:build_access/core/utils/local_ai/override_library_path.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalAiEngineService {
  LlamaParent? _llamaParent;
  StreamSubscription? _streamSubscription;
  bool _isReady = false;
  bool _isProcessing = false;

  final int _maxContext = 1024;
  int _contextUsedTokens = 0;
  String _currentModelPath = "";

  bool _isLowEndDevice = false;

  bool get isReady => _isReady;

  Future<void> initializeSystem(String modelAbsolutePath) async {
    try {
      _currentModelPath = modelAbsolutePath;
      overrideLibraryPath();
      
      int safeThreads = checkHardwareTier((isSet) {
        _isLowEndDevice = isSet;
      });

      final contextParams = ContextParams();
      contextParams.nCtx = _maxContext;
      contextParams.nThreads = safeThreads;
      contextParams.nThreadsBatch = safeThreads;
      contextParams.nPredict = _isLowEndDevice ? 256 : 512;

      final modelParams = ModelParams();
      modelParams.nGpuLayers = 99;
      modelParams.useMemorymap = true;

      final samplingParams = SamplerParams();
      samplingParams.temp = _isLowEndDevice ? 0.1 : 0.25  ;
      samplingParams.topP = 0.90;
      samplingParams.topK = 40;
      samplingParams.penaltyRepeat = 1.10;

      final loadCommand = LlamaLoad(
        path: modelAbsolutePath,
        modelParams: modelParams,
        contextParams: contextParams,
        samplingParams: samplingParams,
      );

      _llamaParent = LlamaParent(loadCommand);

      int timeoutSeconds = _isLowEndDevice ? 180 : 90;
      await _llamaParent!.init().timeout(Duration(seconds: timeoutSeconds));

      await Future.delayed(Duration(milliseconds: _isLowEndDevice ? 2000 : 1000));

      _contextUsedTokens = 0;
      _isReady = true;
      developer_log.log(
        'Llama Isolate Engine đã sẵn sàng nhận lệnh!',
        name: 'LocalAiEngineService',
      );
    } catch (e) {
      _isReady = false;
      developer_log.log('Crash Init: $e', name: 'LocalEngineService');
      rethrow;
    }
  }

  Future<void> _resetContext() async {
    developer_log.log(
      'Hard Reset giải phóng RAM...',
      name: 'LocalAiEngineService',
    );
    _isReady = false;
    _isProcessing = false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await initializeSystem(_currentModelPath);
  }

  Future<String> processChunk(String chunkText) async {
    if (!_isReady || _llamaParent == null) return "";
    if (_isProcessing) return "";

    _isProcessing = true;

    if (_contextUsedTokens + (chunkText.length) > _maxContext - 150) {
      await _resetContext();
    }

    final completer = Completer<String>();
    final buffer = StringBuffer();
    Timer? stuckTimer;

    try {
      developer_log.log(
        '--- BẮT ĐẦU PHIÊN XỬ LÝ CHUNK MỚI ---',
        name: 'AI_TELEMETRY',
      );
      await _streamSubscription?.cancel();

      _streamSubscription = _llamaParent!.stream.listen(
        (response) {
          developer_log.log('Token: [$response]', name: 'AI_STREAM_DATA');
          stuckTimer?.cancel();
          if (response.trim() == '[DONE]') {
            if (!completer.isCompleted) completer.complete(buffer.toString());
            return;
          }
          buffer.write(response);

          int stuckDuration = _isLowEndDevice ? 6000 : 4000;
          stuckTimer = Timer( Duration(milliseconds: stuckDuration), () {
            if (!completer.isCompleted) completer.complete(buffer.toString());
          });
        },
        onDone: () {
          stuckTimer?.cancel();
          if (!completer.isCompleted) completer.complete(buffer.toString());
        },
        onError: (e) {
          stuckTimer?.cancel();
          developer_log.log(
            'Luồng Crash với lỗi: $e',
            name: 'AI_TELEMETRY_ERROR',
          );
          if (!completer.isCompleted) completer.completeError(e);
        },
        cancelOnError: true,
      );

      final String fullPrompt =
          "<|im_start|>system\n"
          "Bạn là chuyên gia khôi phục văn bản OCR tiếng Việt chuyên sâu.\n"
          "Nhiệm vụ bắt buộc:\n"
          "1. Phân tách các từ bị viết dính liền nhau (Ví dụ: \"OnNhu\" -> \"Ôn Như\", \"NguyenVanNgoc\" -> \"Nguyễn Văn Ngọc\").\n"
          "2. Khôi phục dấu tiếng Việt và sửa lỗi chính tả dựa hoàn toàn vào ngữ cảnh văn bản.\n"
          "3. Phát hiện và loại bỏ các đoạn văn bản bị lặp lại do lỗi quét khung hình (Deduplication).\n"
          "4. Tuyệt đối chỉ trả về văn bản kết quả cuối cùng. Không được phép giải thích hoặc thêm văn bản dẫn chuyện.\n"
          "<|im_end|>\n"
          "<|im_start|>user\n"
          "$chunkText\n"
          "<|im_end|>\n"
          "<|im_start|>assistant\n";

      developer_log.log(
        'Đang bơm Prompt vào lõi C++:\n$fullPrompt',
        name: 'AI_TELEMETRY',
      );

      _llamaParent!.sendPrompt(fullPrompt);
      _contextUsedTokens += fullPrompt.length ~/ 2;

      final result = await completer.future;

      String finalClean = result
          .replaceAll("<|im_end|>", "")
          .replaceAll("[DONE]", "")
          .trim();
      if (finalClean.toLowerCase().startsWith("sửa:")) {
        finalClean = finalClean.substring(4).trim();
      }
      developer_log.log(
        'KẾT QUẢ CUỐI CÙNG SAU KHI LỌC: [$finalClean]',
        name: 'AI_TELEMETRY',
      );

      return finalClean;
    } catch (e) {
      developer_log.log('Lỗi Try-Catch: $e', name: 'AI_TELEMETRY_ERROR');
      return "";
    } finally {
      stuckTimer?.cancel();
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      await Future.delayed(Duration(milliseconds: _isLowEndDevice ? 300 : 150));
      _isProcessing = false;
      developer_log.log(
        '--- KẾT THÚC PHIÊN XỬ LÝ CHUNK ---',
        name: 'AI_TELEMETRY',
      );
    }
  }

  void dispose() {
    _streamSubscription?.cancel();
    _isReady = false;
  }
}
