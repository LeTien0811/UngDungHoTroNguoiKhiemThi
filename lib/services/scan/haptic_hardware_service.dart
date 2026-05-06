import 'package:build_access/config/extension.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/app_setting_provider.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer_log;

class HapticHardwareService {
  final List<HapticState> listHaptic = [
    HapticState.light,
    HapticState.heavy,
    HapticState.selection,
    HapticState.off,
  ];

  Future<void> executeSystemVibration() async {
    try {
      final String currentHapticString =
          getIt<AppSettingProvider>().appSetting.hapticLevel;
      final HapticState currentState = currentHapticString.toHapticState();

      if (currentState == HapticState.off) return;

      await triggerHapticFeedBack(currentState);
    } catch (e) {
      developer_log.log(
        "Lỗi thực thi rung hệ thống: $e",
        name: "HapticHardwareService",
      );
    }
  }

  Future<bool> triggerHapticFeedBack(HapticState propsHaptic) async {
    try {
      switch (propsHaptic) {
        case HapticState.light:
          await triggerLightImpact();
          return true;
        case HapticState.heavy:
          await triggerHeavyImpact();
          return true;
        case HapticState.selection:
          await triggerSelectionClick();
          return true;
        case HapticState.off:
          return true;
        default:
          return false;
      }
    } catch (e) {
      developer_log.log(
        "Khoong thay doi dc trang thai: $e",
        name: "HapticHardwareService",
      );
      return false;
    }
  }

  Future<void> triggerLightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      developer_log.log(
        "Lỗi phần cứng Rung: $e",
        name: "HapticHardwareService",
      );
    }
  }

  Future<void> triggerHeavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      developer_log.log(
        "Lỗi phần cứng Rung: $e",
        name: "HapticHardwareService",
      );
    }
  }

  Future<void> triggerSelectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      developer_log.log(
        "Lỗi phần cứng Rung: $e",
        name: "HapticHardwareService",
      );
    }
  }
}
