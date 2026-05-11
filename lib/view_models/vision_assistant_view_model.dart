import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/vision_asisstant/vision_asisstant_engine.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'dart:developer' as developer_log;


class VisionAssistantViewModel extends BaseModel {
  final VoiceInteractionProvider voiceInteractionProvider =
      getIt<VoiceInteractionProvider>();
  final VisionAsisstantEngine _visionAsisstantEngine =
      getIt<VisionAsisstantEngine>();

  String rawText = '';
  String fullResponse = "";

  Future<void> init({
    required ScanResult scanResult,
    required AIType propType,
  }) async {
    await runSafe(() async {
      rawText = scanResult.textDetect.toString();
      notifyListeners();
      setState(ViewState.idle);
      await process(scanResult: scanResult, propType: propType);
    }, 'VisionAssistantViewModel.init');
  }

  Future<void> process({
    ScanResult? scanResult,
    String? userChat,
    required AIType propType,
  }) async {
    await voiceInteractionProvider.playProcessingSound();
    String result = await _visionAsisstantEngine.process(
      propType: propType,
      scanResult: scanResult,
    );
    if (result.trim().isNotEmpty) {
      rawText = result;
      notifyListeners();
      developer_log.log('kết quả: $rawText', name: "VisionAssistantViewModel");
    } else {
      developer_log.log(
        'kết quả rỗng: $rawText',
        name: "VisionAssistantViewModel",
      );
    }

    await voiceInteractionProvider.playSuccessSound();
  }
}
