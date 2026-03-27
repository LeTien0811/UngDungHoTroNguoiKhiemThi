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
        return;
      }
      return;
    }, 'ReadingResultViewModel.init');
  }

  Future<void> _runPipeline(String rawText) async {
    await runSafe(() async {
      final regex = RegExp(r'(?<=[.!?\n])\s+');
      final List<String> chunks = rawText.split(regex);

      for (String chunk in chunks) {
        if (_isDisposed) {
          developer_log.log(
            'Hủy tiến trình AI vì đã đóng màn hình',
            name: 'ReadingResultViewModel._runPipeline',
          );
          break;
        }

        final correctedChunk = await localEngineService.processAndCorrectText(chunk);

        if (_isDisposed) {
          developer_log.log(
            'Hủy tiến trình AI vì đã đóng màn hình',
            name: 'ReadingResultViewModel._runPipeline',
          );
          break;
        }

        fullResponse += "$correctedChunk ";
        notifyListeners();

        providerSevice.speakQueue(correctedChunk);
      }

      if (!_isDisposed) {
        developer_log.log(
          'Đã xử lý xong toàn bộ văn bản.',
          name: 'ReadingResultViewModel._runPipeline',
        );
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
