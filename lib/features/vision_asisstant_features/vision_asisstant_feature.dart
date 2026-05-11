import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/vision_asisstant_features/components/body.dart';
import 'package:build_access/models/scan/scan_result.dart';
import 'package:build_access/view_models/vision_assistant_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisionAsisstantFeature extends StatefulWidget {
  static const String routeName = '/vision_assistant';
  const VisionAsisstantFeature({super.key});

  @override
  State<VisionAsisstantFeature> createState() => _VisionAsisstantFeatureState();
}

class _VisionAsisstantFeatureState extends State<VisionAsisstantFeature>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final ScanResult? scanResultProps = Get.arguments['scanResult'];
    final AIType type = Get.arguments['type'] ?? AIType.values;

    return BaseView<VisionAssistantViewModel>(
      builder: (context, model, child) {
        if (model.state == ViewState.busy || type == AIType.error) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Body(model: model);
      },
      onModelReady: (model) async {
        if (type != AIType.error && scanResultProps != null) {
          await model.init(scanResult: scanResultProps, propType: type);
        }
      },
      onModelDispose: (model) {
        model.dispose();
      },
      child: null,
    );
  }
}
