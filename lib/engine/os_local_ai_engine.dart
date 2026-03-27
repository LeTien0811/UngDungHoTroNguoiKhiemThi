import 'package:build_access/config/ai_engine_strategy.dart';
import 'package:build_access/enum/config.dart';
import 'package:flutter_local_ai/flutter_local_ai.dart';
import 'dart:developer' as developer_log;

class OsLocalAiEngine implements AiEngineStrategy {
  final FlutterLocalAi _engine = FlutterLocalAi();

  AIStatus _status = AIStatus.uninitialized;
  AIStatus get status => _status;

  @override
  Future<void> initialize() async {
    try {
      if(_status == AIStatus.ready) return;

      _status = AIStatus.initializing;

      final success = await _engine.initialize(
          instructions: 'Bạn là một chuyên gia ngôn ngữ tiếng Việt. Sửa lỗi chính tả từ văn bản OCR. Chỉ trả về kết quả đã sửa.'
      );
      _status = success ? AIStatus.ready : AIStatus.error;
    } catch(e) {
      _status =  AIStatus.error;
      developer_log.log('lỗi khởi tạo $e', name: 'OsLocalAiEngine.initialize');
      rethrow;
    }
  }

  @override
  Future<bool> isSupported() async{
    try {
      final isSupported = await _engine.isAvailable();
      _status = isSupported ? _status : AIStatus.missingAICore;
      return isSupported;
    } catch (e) {
      developer_log.log('lỗi khởi tạo $e', name: 'OsLocalAiEngine.isNotSupported');
      _status =  AIStatus.error;
      rethrow;
    }
  }

  Future<bool> openStoreToInstall() async {
    try {
      bool isSuccess = await _engine.openAICorePlayStore();
      if(isSuccess) {
        _status = AIStatus.uninitialized;
      }

      return isSuccess;
    } catch (e) {
      developer_log.log('lỗi khởi tạo $e', name: 'OsLocalAiEngine.openStoreToInstall');
      _status =  AIStatus.error;
      rethrow;
    }
  }

  @override
  Future<String> processText(String rawText) async{
    try {
      final response = await _engine.generateText(
          prompt: rawText,
          config: const GenerationConfig(maxTokens: 250)
      );
      return response.text.trim();
    } catch (e) {
      developer_log.log('lỗi sinh texxt $e', name: 'OsLocalAiEngine.isNotSupported');
      _status =  AIStatus.error;
      throw Exception('PROCESS_ERROR');
    }
  }
}