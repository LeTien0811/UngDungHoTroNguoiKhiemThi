import 'package:build_access/config/base_model.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';
import 'package:build_access/services/local_ai_engine_service.dart';
import 'dart:developer' as developer_log;

class ReadingResultViewModel extends BaseModel {
  final ProviderSevice providerSevice = getIt<ProviderSevice>();
  final LocalEngineService localEngineService = getIt<LocalEngineService>();
  String rawText = '';

  String fullResponse = "";
  bool _isDisposed = false;

  Future<void> init(String propRawText) async{

    runSafe(() async {
      rawText = propRawText;
      notifyListeners();
      if(!providerSevice.isReady) providerSevice.initializeSystem();

      bool isInitial = false;
      if(localEngineService.status == AIStatus.uninitialized || localEngineService.status == AIStatus.error) {
        isInitial = await localEngineService.initialize();
      } else if(localEngineService.status == AIStatus.ready) {
        isInitial = true;
      }

      if(isInitial) {
        _runPipeline(rawText);
        return;
      } else {
        if(localEngineService.status == AIStatus.missingAICore) {
          providerSevice.speakQueue('Hệ thống đang thiếu mô hình nhận diện thông minh. Vui lòng tải về từ cửa hàng ứng dụng để sử dụng tính năng này.');
          await localEngineService.requireInstall();
        } else {
          providerSevice.speakQueue('Hệ thống khởi tạo AI thất bại. Vui lòng kiểm tra lại thiết bị.');
        }
      }
    }, 'ReadingResultViewModel.init');
  }

  Future<void> _runPipeline(String rawText) async{
    await runSafe(() async {
      final regex = RegExp(r'(?<=[.!?\n])\s+');
      final List<String> chunks = rawText.split(regex);

      for(String chunk in chunks) {
        if(_isDisposed) {
          developer_log.log('Hủy tiến trình AI vì đã đóng màn hình', name: 'ReadingResultViewModel._runPipeline');
          break;
        }

        final correctedChunk = await localEngineService.processText(chunk);

        if(_isDisposed) {
          developer_log.log('Hủy tiến trình AI vì đã đóng màn hình', name: 'ReadingResultViewModel._runPipeline');
          break;
        }

        fullResponse += "$correctedChunk ";
        notifyListeners();

        providerSevice.speakQueue(correctedChunk);
      }

      if (!_isDisposed) {
        developer_log.log('Đã xử lý xong toàn bộ văn bản.', name: 'ReadingResultViewModel._runPipeline');
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