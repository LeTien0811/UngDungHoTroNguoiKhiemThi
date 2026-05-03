import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/vision_asisstant_features/components/body.dart';
import 'package:build_access/view_models/vision_assistant_view_model.dart';
import 'package:flutter/material.dart';

class VisionAsisstantFeature extends StatefulWidget {
  static const String routeName = '/vision_asisstant_feature';
  const VisionAsisstantFeature({super.key});

  @override
  State<VisionAsisstantFeature> createState() => _VisionAsisstantFeatureState();
}

class _VisionAsisstantFeatureState extends State<VisionAsisstantFeature>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String rawText = args['rawText'] ?? "";
    final AIType type = args['type'] ?? AIType.error;

    return BaseView<VisionAssistantViewModel>(
      builder: (context, model, child) {
        if (model.state == ViewState.busy ||
            rawText.isEmpty ||
            type == AIType.error) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Body(model: model);
      },
      onModelReady: (model) async {
        if (rawText.isNotEmpty && type != AIType.error) {
          await model.init(propRawText: rawText, propType: type);
        }
      },
      onModelDispose: (model) {
        model.dispose();
      },
      child: null,
    );
  }
}
