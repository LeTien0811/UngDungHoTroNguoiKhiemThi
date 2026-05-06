import 'dart:async';
import 'dart:developer' as developer_log;
import 'package:build_access/core/utils/override_library_path.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalAIService {
  LlamaParent? _llamaParent;
  StreamSubscription? _streamSubscription;

  final int _maxContext = 1024;
  int _contextUsedTokens = 0;
  String _currentModelPath = "";

  bool _isLowEndDevice = false;

  Future<bool> initializeSystem(String modelAbsolutePath) async {
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
      samplingParams.temp = _isLowEndDevice ? 0.2 : 0.3;
      samplingParams.topP = 0.90;
      samplingParams.topK = 40;
      samplingParams.penaltyRepeat = 1.0;

      final loadCommand = LlamaLoad(
        path: modelAbsolutePath,
        modelParams: modelParams,
        contextParams: contextParams,
        samplingParams: samplingParams,
      );

      _llamaParent = LlamaParent(loadCommand);

      int timeoutSeconds = _isLowEndDevice ? 180 : 90;
      await _llamaParent!.init().timeout(Duration(seconds: timeoutSeconds));

      await Future.delayed(
        Duration(milliseconds: _isLowEndDevice ? 2000 : 1000),
      );

      _contextUsedTokens = 0;

      developer_log.log(
        'Llama Isolate Engine đã sẵn sàng nhận lệnh!',
        name: 'LocalAiEngineService.initializeSystem',
      );
      return true;
    } catch (e) {
      developer_log.log(
        'Crash Init: $e',
        name: 'LocalAiEngineService.initializeSystem',
      );
      return false;
    }
  }

  Future<bool> _resetContext() async {
    try {
      developer_log.log(
        'Hard Reset giải phóng RAM...',
        name: 'LocalAiEngineService',
      );
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      bool isInitializer = await initializeSystem(_currentModelPath);
      return isInitializer;
    } catch (e) {
      developer_log.log(
        'Crash reset context: $e',
        name: 'LocalAiEngineService._resetContext',
      );
      return false;
    }
  }

  Future<String> processChunk(String prompt) async {
    if (_contextUsedTokens + (prompt.length) > _maxContext - 150) {
      await _resetContext();
    }
    try {
      if (_llamaParent == null) {
        throw Exception("Llama Engine chưa được khởi tạo");
      }

      final completer = Completer<String>();
      final buffer = StringBuffer();
      Timer? stuckTimer;

      try {
        await _streamSubscription?.cancel();

        _streamSubscription = _llamaParent!.stream.listen(
          (response) {
            stuckTimer?.cancel();
            if (response.trim() == '[DONE]') {
              if (!completer.isCompleted) completer.complete(buffer.toString());
              return;
            }
            buffer.write(response);

            int stuckDuration = _isLowEndDevice ? 6000 : 4000;
            stuckTimer = Timer(Duration(milliseconds: stuckDuration), () {
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
              'Lỗi trong quá trình xử lý: $e',
              name: 'LocalAiEngineService.processChunk',
            );
            if (!completer.isCompleted) completer.completeError(e);
          },
          cancelOnError: true,
        );

        _llamaParent!.sendPrompt(prompt);
        _contextUsedTokens += prompt.length ~/ 2;

        final result = await completer.future;

        String finalClean = result
            .replaceAll("<|im_end|>", "")
            .replaceAll("[DONE]", "")
            .trim();

        if (finalClean.toLowerCase().startsWith("sửa:")) {
          finalClean = finalClean.substring(4).trim();
        }

        return finalClean;
      } finally {
        stuckTimer?.cancel();
        await _streamSubscription?.cancel();
        _streamSubscription = null;
        await Future.delayed(
          Duration(milliseconds: _isLowEndDevice ? 300 : 150),
        );
      }
    } catch (e) {
      developer_log.log(
        'Lỗi Try-Catch: $e',
        name: 'LocalAiEngineService.processChunk',
      );
      return "";
    }
  }

  void stopInference() {
    _streamSubscription?.cancel();

    if (_llamaParent != null) {
      _llamaParent!.stop();
    }
  }

  void dispose() {
    _streamSubscription?.cancel();
    _llamaParent!.dispose();
  }
}
