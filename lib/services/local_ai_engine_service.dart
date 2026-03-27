import 'dart:async';
import 'dart:developer' as developer_log;
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalAiEngineService {
  LlamaParent? _llamaParent;
  StreamSubscription? _streamSubscription;
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> initializeSystem(String modelAbsolutePath) async {
    try {
      final contextParams = ContextParams();
      contextParams.nCtx = 1024;
      contextParams.nThreads = 4;

      final modelParams = ModelParams();
      modelParams.nGpuLayers = 99;

      final samplingParams = SamplerParams();
      samplingParams.temp = 0.1;
      samplingParams.topP = 0.9;

      final loadCommand = LlamaLoad(
        path: modelAbsolutePath,
        modelParams: modelParams,
        contextParams: contextParams,
        samplingParams: samplingParams,
      );

      _llamaParent = LlamaParent(loadCommand);
      await _llamaParent!.init();

      _isReady = true;
      developer_log.log('Llama Isolate Engine ĐÃ LÊN NÒNG!', name: 'LocalEngineService');
    } catch (e) {
      developer_log.log('Crash Engine: $e', name: 'LocalEngineService');
      rethrow;
    }
  }

  Future<String> processAndCorrectText(String rawOcrText) async {
    if (!_isReady || _llamaParent == null) {
      throw Exception('EngineNotReady');
    }

    final completer = Completer<String>();
    final buffer = StringBuffer();

    _streamSubscription = _llamaParent!.stream.listen(
          (response) {
        buffer.write(response);
      },
      onDone: () {
        completer.complete(buffer.toString().trim());
      },
      onError: (e) {
        completer.completeError(e);
      },
    );

    final prompt = "Bạn là trợ lý cho người khiếm thị. hãy chỉnh sửa lỗi chính tả từ được OCR đọc vào. Tuyệt đối chỉ xuất ra tiếng Việt, nếu có Tiếng Anh thì dịch nó sang tiếng việt rồi để từ tiếng anh kế bên và mô tả nó làm sao cho text to speech đọc chính xác, nôi dung chính xác nhất không dùng dấu ký tự đặt biệt chỉ diễn tả bằng giọng văn.\nNội dung OCR: $rawOcrText";

    _llamaParent!.sendPrompt(prompt);

    final result = await completer.future;

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    return result;
  }

  void dispose() {
    _streamSubscription?.cancel();
    _isReady = false;
  }
}