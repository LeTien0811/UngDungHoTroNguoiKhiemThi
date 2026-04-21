import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/features/splash_feature/components/body.dart';
import 'package:build_access/view_models/splash_view_model.dart';
import 'package:flutter/cupertino.dart';

class SplashFeature extends StatefulWidget {
  static const String routerName = '/splash';
  const SplashFeature({super.key});

  @override
  State<SplashFeature> createState() => _SplashFeatureState();
}

class _SplashFeatureState extends State<SplashFeature> {
  @override
  Widget build(BuildContext context) {
    return BaseView<SplashViewModel>(
        builder: (context, model, child) {
        return Body(model: model);
      },
        onModelReady: (model) async{
          await model.initializerApp();
    },
        onModelDispose: (model) {

    },
        child: null);
  }
}
