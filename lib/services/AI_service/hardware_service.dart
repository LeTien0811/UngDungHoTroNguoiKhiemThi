import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:developer' as developer_log;

class HardwareService {
  Future<bool> isCapableForLocalAI() async {
    try {
      if (Platform.isAndroid) {
        await DeviceInfoPlugin().androidInfo;
        final memInfo = await Process.run('cat', ['/proc/meminfo']);
        final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(memInfo.stdout.toString());

        if (match != null) {
          final totalRamMB = int.parse(match.group(1)!) / 1024;
          return totalRamMB > 3500;
        }
      }
      return false;
    } catch (e) {
      developer_log.log('Hardware Check Error: $e', name: 'HardwareService');
      return false;
    }
  }
}