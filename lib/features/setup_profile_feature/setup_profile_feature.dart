import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/features/onboarding_features/components/body.dart';
import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:flutter/material.dart';

class SetupProfileFeature extends StatefulWidget {
  static final String routerName = "/onboarding";
  const SetupProfileFeature({super.key});

  @override
  State<SetupProfileFeature> createState() => _SetupProfileFeatureState();
}

class _SetupProfileFeatureState extends State<SetupProfileFeature> {
  @override
  Widget build(BuildContext context) {
    return BaseView<OnboardingViewModel>(
      builder: (context, model, child) {
        return Body(model: model,);
      },
      onModelReady: (model) {
        model.initializer();
      },
      onModelDispose: (model) {
        model.dispose();
      }, child: null,
    );
  }
}
