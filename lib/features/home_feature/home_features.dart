import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/home_feature/components/body.dart';
import 'package:build_access/view_models/home_view_model.dart';
import 'package:flutter/material.dart';

class HomeFeatures extends StatelessWidget {
  static String routerName = "/home_feature";
  const HomeFeatures({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
        builder: (context, model, child) {
          if(model.state == ViewState.busy) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Body(model: model,);
        },
        onModelReady: (model) {},
        onModelDispose: (model) { model.dispose(); },
        child: null
    );
  }
}
