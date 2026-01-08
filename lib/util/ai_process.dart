import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:mediapipe_genai/io.dart';
import 'package:path_provider/path_provider.dart';

class AiProcess {
  LlmInferenceEngine? _engine;

  static const String _modelAssetName = 'gemma-2b-it-cpu-int4.bin'; // Tên file trong assets
  static const int _maxTokens = 1024;
  static const double _temperature = 0.7;
  static const int _topK = 40;

  Future<void> initModel() async{
    try {
      final String modelPath = await _copyAssetToLocal(_modelAssetName);
      final tempDir = await getTemporaryDirectory();
      final options = LlmInferenceOptions.cpu(
          modelPath: modelPath,
          maxTokens: _maxTokens,
          temperature: _temperature,
          cacheDir: tempDir.path,
          topK: _topK
      );
      _engine = LlmInferenceEngine(options);
      return;
    } catch (e) {
      LogErrorServices.showLog(where: 'AiProcess -> init', type: 'loi khoi tao', message: 'Loi khoi tao $e');
      return;
    }
  }

  Future<String> _copyAssetToLocal(String assetName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$assetName';
    final file = File(filePath);

    if (!await file.exists()) {
      print("Đang copy model (1.5GB)...");
      try {
        final byteData = await rootBundle.load('assets/models/$assetName');
        await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ));
        print("Copy xong.");
      } catch (e) {
        LogErrorServices.showLog(where: 'AiProcess -> copyAssetToLocal', type: 'loi khi coppy file', message: '$e');
      }
    }
    return filePath;
  }


  void dispose() {
    _engine?.dispose();
  }
}