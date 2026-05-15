import 'package:build_access/config/my_colors.dart';
import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/history_feature/components/body.dart';
import 'package:build_access/view_models/history_view_model.dart';
import 'package:flutter/material.dart';

class HistoryFeature extends StatelessWidget {
  static String routerName = "/history";
  const HistoryFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<HistoryViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: MyColors.bgDark,
          body: model.state == ViewState.busy
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Body(model: model),
        );
      },
      onModelReady: (model) async {
        await model.loadHistory();
      },
      onModelDispose: (model) {
        model.dispose();
      },
      child: null,
    );
  }
}
