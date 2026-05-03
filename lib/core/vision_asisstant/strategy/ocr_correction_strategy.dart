import 'package:build_access/core/scan/enhancer/scan_text_ai_enhancer.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/vision_asisstant/strategy/vision_action_strategy.dart';

class OcrCorrectionStrategy implements VisionActionStrategy {
  final ScanTextAiEnhancer _scanTextAiEnhancer = getIt<ScanTextAiEnhancer>();

  @override
  Future<String> execute(String rawText) async {
    return await _scanTextAiEnhancer.enhance(rawText);
  }
}
