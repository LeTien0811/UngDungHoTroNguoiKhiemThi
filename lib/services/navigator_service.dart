import 'package:flutter/cupertino.dart';

class NavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
          (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void pop() {
    return navigatorKey.currentState!.pop();
  }
}