import 'package:build_access/config/base_view.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/features/reading_result_feature/components/body.dart';
import 'package:build_access/view_models/reading_result_view_model.dart';
import 'package:flutter/material.dart';

class ReadingResultFeatures extends StatefulWidget {
  static const String routeName = '/reading_result';
  const ReadingResultFeatures({super.key});

  @override
  State<ReadingResultFeatures> createState() => _ReadingResultFeaturesState();
}

class _ReadingResultFeaturesState extends State<ReadingResultFeatures>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String rawText = args is String ? args : "";

    return BaseView<ReadingResultViewModel>(
      builder: (context, model, child) {
        if (model.state == ViewState.busy || rawText.isEmpty) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Body(model: model);
      },
      onModelReady: (model) async {
        if(rawText.isNotEmpty) {
          await model.init(rawText);
        }
      },
      onModelDispose: (model) {
        model.dispose();
      },
      child: null,
    );
  }
}
