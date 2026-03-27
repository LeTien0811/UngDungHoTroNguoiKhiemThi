import 'package:build_access/config/base_view.dart';
import 'package:build_access/src/features/reading_result_feature/components/body.dart';
import 'package:build_access/view/reading_result_view_model.dart';
import 'package:flutter/material.dart';

class ReadingResultFeatures extends StatefulWidget {
  final String rawText;
  const ReadingResultFeatures({
    super.key,
    required this.rawText,
  });

  @override
  State<ReadingResultFeatures> createState() => _ReadingResultFeaturesState();
}

class _ReadingResultFeaturesState extends State<ReadingResultFeatures> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BaseView<ReadingResultViewModel>(
        builder: (context, model, child) => Body(model: model,),
        onModelReady: (model) async {
          await model.init(widget.rawText);
        },
        onModelDispose: (model)  {
           model.dispose();
        },
        child: null ,
    );
  }
}
