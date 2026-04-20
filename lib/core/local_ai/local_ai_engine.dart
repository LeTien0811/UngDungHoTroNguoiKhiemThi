import 'dart:async';
import 'dart:developer' as developer_log;
import 'package:build_access/core/utils/override_library_path.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/local_ai_provider.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class LocalAIEngine {
  LocalAiProvider localAiProvider = getIt<LocalAiProvider>();
  LlamaParent? _llamaParent;
  StreamSubscription? _streamSubscription;

  final int _maxContext = 1024;
  int _contextUsedTokens = 0;
  String _currentModelPath = "";

  bool _isLowEndDevice = false;


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

      await Future.delayed(Duration(milliseconds: _isLowEndDevice ? 2000 : 1000));

      _contextUsedTokens = 0;

      localAiProvider.setReady(true);
      developer_log.log(
        'Llama Isolate Engine đã sẵn sàng nhận lệnh!',
        name: 'LocalAiEngineService',
      );
    } catch (e) {
      localAiProvider.setReady(false);
      developer_log.log('Crash Init: $e', name: 'LocalEngineService');
      rethrow;
    }
  }

  Future<void> _resetContext() async {
    developer_log.log(
      'Hard Reset giải phóng RAM...',
      name: 'LocalAiEngineService',
    );
    localAiProvider.setDisposed();
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await initializeSystem(_currentModelPath);
  }

  Future<String> processChunk(String chunkText) async {
    if (localAiProvider.status != LocalAiStatus.ready || _llamaParent == null) return "";
    if (localAiProvider.status == LocalAiStatus.processing) return "";

    localAiProvider.setProcessing();

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
          localAiProvider.setError();
          if (!completer.isCompleted) completer.completeError(e);
        },
        cancelOnError: true,
      );

      final String fullPrompt =
          "<|im_start|>system\n"
          "Bạn là trợ lý khôi phục văn bản. Nhiệm vụ của bạn là sửa lỗi chính tả, thêm dấu, tách từ dính liền, và tóm gọn lại thông tin dễ hiểu nhất.\n"
          "Tuyệt đối chỉ in ra kết quả, không giải thích dài dòng.\n"
          "---VÍ DỤ---\n"
          "Đầu vào: UONO LẠNH THÁNH PHÁN mch extract from malt barleyl, duờng, sũa bột tách kem\n"
          "Đầu ra: Uống lạnh. Thành phần: Mạch nha, đường, sữa bột tách kem.\n"
          "-----------\n"
          "<|im_end|>\n"
          "<|im_start|>user\n"
          "Đầu vào: $chunkText\n"
          "Đầu ra:<|im_end|>\n"
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
      localAiProvider.setError();
      return "";
    } finally {
      stuckTimer?.cancel();
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      await Future.delayed(Duration(milliseconds: _isLowEndDevice ? 300 : 150));
      localAiProvider.setReady(true);
      developer_log.log(
        '--- KẾT THÚC PHIÊN XỬ LÝ CHUNK ---',
        name: 'AI_TELEMETRY',
      );
    }
  }

  void dispose() {
    _streamSubscription?.cancel();
    localAiProvider.setDisposed();
  }
}
