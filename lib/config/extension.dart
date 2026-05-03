import 'package:build_access/enum/state.dart';

extension HapticStateExtension on String {
  HapticState toHapticState() {
    return HapticState.values.firstWhere(
          (e) => e.name == this,
      orElse: () => HapticState.off,
    );
  }
}