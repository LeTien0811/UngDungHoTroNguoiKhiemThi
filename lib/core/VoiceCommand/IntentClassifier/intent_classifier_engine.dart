import 'dart:io';
import 'dart:typed_data';
import 'package:build_access/core/VoiceCommand/pipeline/intent_mapper.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/intent_classifier_provider.dart';
import 'package:build_access/services/intent_classifier/intent_ffi_service.dart';
import 'dart:developer' as developer_log;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class IntentClassifierEngine {
  final IntentFFIService _intentFFIService = getIt<IntentFFIService>();
  final IntentClassifierProvider _provider = getIt<IntentClassifierProvider>();

  Future<void> initializer() async {
    try {
      _provider.setProcessing();
      final ByteData modelData = await rootBundle.load(
        'assets/models/intent_v2_mobile_optimized.bin',
      );
      final List<int> bytes = modelData.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File(
        '${tempDir.path}/intent_v2_mobile_optimized.bin',
      );

      await tempFile.writeAsBytes(bytes, flush: true);
      developer_log.log(
        "đường dẫn đến model: ${tempDir.path}/intent_v2_mobile_optimized.bin",
        name: "IntentClassifierEngine.initializerApp",
      );

      bool isInit = _intentFFIService.initialize();

      if (!isInit) {
        throw Exception("Không thể kết nối C++ Native Library.");
      }

      bool isLoadModel = _intentFFIService.loadModel(tempFile.path);

      if (!isLoadModel) {
        throw Exception("C++ nạp mô hình FastText thất bại.");
      }

      _provider.setReady(true);
      developer_log.log(
        "Nạp thành công mô hình FastText",
        name: "IntentClassifierEngine.initializerApp",
      );
    } catch (e) {
      _provider.setReady(false);
      developer_log.log(
        "lỗi trong quá trình khởi tạo: $e",
        name: "IntentClassifierEngine.initializerApp",
      );
    }
  }

  Future<IntentType> processIntentClassifier(String voiceIntent) async {
    try {
      if (_provider.status == AIStatus.uninitialized) {
        developer_log.log(
          "Intent service chua duoc khoi dong tien hanh khoi dong",
          name: "processIntentClassifier.processIntentClassifier",
        );
        await initializer();
        if (_provider.status == AIStatus.uninitialized) {
          throw Exception("Thất bại khi khởi tạo lại");
        }
      }

      if (_provider.status != AIStatus.ready) {
        developer_log.log(
          "Intent service Dang ban",
          name: "processIntentClassifier.processIntentClassifier",
        );
        return IntentType.ERROR;
      }
      final String labelIntent = _intentFFIService.predict(voiceIntent);
      return IntentMapper.fromRawString(labelIntent);
    } catch (e) {
      developer_log.log(
        "co loi xay ra: $e",
        name: "processIntentClassifier.processIntentClassifier",
      );
      _provider.setError();
      return IntentType.ERROR;
    }
  }

  void shutdownEngine() {
    developer_log.log(
      "Tiến hành giải phóng C++ FastText",
      name: "IntentClassifierEngine",
    );
    _intentFFIService.dispose();
    _provider.setReady(false);
  }
}
