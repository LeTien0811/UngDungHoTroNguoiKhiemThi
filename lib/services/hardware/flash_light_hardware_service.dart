import 'package:torch_light/torch_light.dart';
import 'dart:developer' as developer_log;

class FlashLightHardwareService {
  bool hasTorch = false;
  bool isTorchOn = false;

  Future<void> init() async {
    try {
      final isTorchAvailable = await TorchLight.isTorchAvailable();
      hasTorch = isTorchAvailable;
    } catch (e) {
      isTorchOn = false;
      developer_log.log(
        "thiết bị không có sẵn camera: $e",
        name: "FlashLightHardwareService.init",
      );
    }
  }

  Future<bool> turnOn() async {
    if (!hasTorch || isTorchOn) return false;
    try {
      await TorchLight.enableTorch();
      isTorchOn = true;
      return true;
    } catch (e) {
      developer_log.log(
        "Lỗi bật đèn Flash: $e",
        name: "FlashlightHardwareService",
      );
      return false;
    }
  }

  Future<bool> turnOff() async {
    if (!hasTorch || !isTorchOn) return false;
    try {
      await TorchLight.disableTorch();
      isTorchOn = false;
      return true;
    } catch (e) {
      developer_log.log(
        "Lỗi tắt đèn Flash: $e",
        name: "FlashlightHardwareService",
      );
      return false;
    }
  }
}
