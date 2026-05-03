import 'package:build_access/core/VoiceCommand/SemanticRouter/intent_classifier_engine.dart';
import 'package:build_access/core/local_ai/local_ai_engine.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/camera_hardware_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer_log;

class AppLifecycleSupervisor extends WidgetsBindingObserver {
  final CameraHardwareService _cameraHardwareService =
      getIt<CameraHardwareService>();
  final VoiceInteractionProvider _voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();
  final LocalAIEngine _localAIEngine = getIt<LocalAIEngine>();
  final IntentClassifierEngine _classifierEngine = getIt<IntentClassifierEngine>();

  void startSupervising() {
    WidgetsBinding.instance.addObserver(this);
    developer_log.log(
      "Lifecycle Supervisor đã được kích hoạt",
      name: "Lifecycle",
    );
  }

  void stopSupervising() {
    WidgetsBinding.instance.removeObserver(this);
    developer_log.log(
      "Lifecycle Supervisor đã dừng hoạt động",
      name: "Lifecycle",
    );
  }

  void _handleAppWentToBackground() {
    try {
      developer_log.log(
        "App xuong nen tam dung moi hoat dong",
        name: "Lifecycle",
      );
      _voiceInteractionProvider.stopSpeaking();
      _voiceInteractionProvider.stopListening();

      _localAIEngine.stopCurrentInference();

      if (_cameraHardwareService.controller != null &&
          _cameraHardwareService.isInitialized) {
        _cameraHardwareService.stopStream();
      }
    } catch (e) {
      developer_log.log("loi khi tam dung app : $e", name: "Lifecycle");
    }
  }

  void _handleAppResumed() {
    try {
      developer_log.log("App tro lai hoat dong", name: "Lifecycle");
    } catch (e) {
      developer_log.log("loi khi tro lai app : $e", name: "Lifecycle");
    }
  }

  void _handleAppKilled() {
    developer_log.log("App bị tắt: Hủy toàn bộ tài nguyên", name: "Lifecycle");

    _voiceInteractionProvider.dispose();
    _cameraHardwareService.dispose();
    _localAIEngine.dispose();
    _classifierEngine.shutdownEngine();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _handleAppWentToBackground();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppKilled();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }
}
