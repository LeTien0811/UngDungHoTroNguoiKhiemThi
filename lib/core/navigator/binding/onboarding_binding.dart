import 'package:build_access/view_models/onboarding_view_model.dart';
import 'package:get/get.dart';

class OnboardingBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<OnboardingViewModel>(() => OnboardingViewModel());
  }
}