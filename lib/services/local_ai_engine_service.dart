import 'package:build_access/engine/os_local_ai_engine.dart';
import 'dart:developer' as developer_log;

import 'package:build_access/enum/config.dart';

class LocalEngineService {
  final _aiEngine = OsLocalAiEngine();
  AIStatus get status => _aiEngine.status;

  Future<bool> initialize() async {
    try {
      if(_aiEngine.status == AIStatus.ready) return true;

      bool isSupport = await _aiEngine.isSupported();
      if (isSupport) {
        await _aiEngine.initialize();
        return _aiEngine.status == AIStatus.ready;
      }

      return false;
    } catch (e) {
      developer_log.log('lỗi khởi tạo $e', name: 'LocalEngineService.initialize');
      return false;
    }
  }

  Future<void> requireInstall() async{
    await _aiEngine.openStoreToInstall();
  }

  Future<String> processText(String rawText) async{
    try {
      if(_aiEngine.status == AIStatus.uninitialized) throw('AI chưa được khởi tạo');

      final response = await _aiEngine.processText(rawText);

      if(response == '404') {
        throw ('AI hiện đang bận vui lòng thử lại sau');
      }

      return response;
    } catch (e) {
      developer_log.log('lỗi khởi tạo $e', name: 'OsLocalAiEngine.isNotSupported');
      return e.toString();
    }
  }

}