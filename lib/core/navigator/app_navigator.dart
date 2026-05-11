import 'package:get/get.dart';

class NavigatorService {
  Future<void> navigateTo(String routeName, {dynamic arguments}) async {
    Get.toNamed(routeName, arguments: arguments);
  }

  Future<void> pushNamedAndRemoveUntil(
    String routeName, {
    dynamic arguments,
  }) async {
    Get.offAllNamed(routeName, arguments: arguments);
  }

  void pop({dynamic result}) {
    Get.back(result: result);
  }
}
