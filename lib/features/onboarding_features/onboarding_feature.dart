import 'package:build_access/core/base/base_view.dart';
import 'package:build_access/features/onboarding_features/components/body.dart';
import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:flutter/material.dart';

class OnboardingFeature extends StatefulWidget {
  static final String routerName = "onboarding";
  const OnboardingFeature({super.key});

  @override
  State<OnboardingFeature> createState() => _OnboardingFeatureState();
}

class _OnboardingFeatureState extends State<OnboardingFeature> {
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
