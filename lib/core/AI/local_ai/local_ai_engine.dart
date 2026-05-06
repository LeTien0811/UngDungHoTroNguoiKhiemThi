import 'dart:async';
import 'dart:collection';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/services/AI_service/local_ai_service.dart';
import 'dart:developer' as developer_log;

class LocalAIEngine {
  final LocalAIService _localAIService = getIt<LocalAIService>();
  final LocalAiProvider _localAiProvider = getIt<LocalAiProvider>();

  final Queue<Completer<String>> _taskQueue = Queue();
  final Queue<String> _promptQueue = Queue();

  Future<bool> initialize(String pathAIModel) async {
    _localAiProvider.setProcessing();
    try {
      bool isSuccess = await _localAIService.initializeSystem(pathAIModel);
      if (isSuccess) {
        _localAiProvider.setReady(true);
      } else {
        _localAiProvider.setError();
      }
      return isSuccess;
    } catch (e) {
      _localAiProvider.setError();
      developer_log.log('Crash Init: $e', name: 'LocalAIEngine.initialize');
      return false;
    }
  }

  Future<String> executeTask(String promt) async {
    final completer = Completer<String>();
    _taskQueue.add(completer);
    _promptQueue.add(promt);
    await _processNextTask();
    return completer.future;
  }

  Future<void> _processNextTask() async {
    if (_localAiProvider.status != AIStatus.ready || _taskQueue.isEmpty) {
      return;
    }
    final completer = _taskQueue.removeFirst();
    final prompt = _promptQueue.removeFirst();
    try {
      _localAiProvider.setProcessing();
      final result = await _localAIService.processChunk(prompt);
      completer.complete(result);
    } catch (e) {
      completer.completeError(e);
    } finally {
      if (_taskQueue.isEmpty) {
        _localAiProvider.setReady(true);
      } else {
        _localAiProvider.setReady(true);
        _processNextTask();
      }
    }
  }

  void stopCurrentInference() {
    _taskQueue.clear();
    _promptQueue.clear();

    _localAIService.stopInference();
    _localAiProvider.setReady(true);
  }

  void dispose() {
    _taskQueue.clear();
    _promptQueue.clear();
    _localAIService.dispose();
    _localAiProvider.dispose();
    developer_log.log(
      "Đã giải phóng Hàng đợi và Lõi C++ AI",
      name: "LocalAIEngine",
    );
  }
}
