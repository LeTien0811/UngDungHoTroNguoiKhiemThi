import 'dart:ui';

String getSystemLanguageTag() {
  final locale = PlatformDispatcher.instance.locale;
  return "${locale.languageCode}-${locale.countryCode}";
}