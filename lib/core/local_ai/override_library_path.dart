import 'dart:ffi';
import 'dart:io';
import 'dart:developer' as developer_log;
import 'dart:math';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void overrideLibraryPath() {
  if (Platform.isAndroid) {
    try {
      final requiredLibs = [
        "libc++_shared.so",
        "libomp.so",
        "libggml-base.so",
        "libggml.so",
        "libggml-cpu.so",
        "libggml-vulkan.so",
        "libllama.so",
        "libmtmd.so",
      ];
      for (final lib in requiredLibs) {
        try {
          DynamicLibrary.open(lib);
        } catch (e) {
          developer_log.log('Crash lib: $e', name: 'LocalEngineService');
        }
      }
      Llama.libraryPath = "libmtmd.so";
    } catch (e) {
      developer_log.log('LinkError: $e', name: 'LocalAiEngineService');
    }
  }
}

int getDeviceRamMB() {
  if (Platform.isAndroid) {
    try {
      final lines = File('/proc/meminfo').readAsLinesSync();
      for (String line in lines) {
        if (line.startsWith('MemTotal:')) {
          final parts = line.split(RegExp(r'\s+'));
          return int.parse(parts[1]) ~/ 1024;
        }
      }
    } catch (e) {
      return 4096;
    }
  }
  return 4096;
}

int checkHardwareTier(Function(bool isLowEndDevice) seLowdevice) {
  int coreCount = Platform.numberOfProcessors;
  int ramMB = getDeviceRamMB();

  if (coreCount <= 4 || ramMB <= 5000) {
    seLowdevice(true);
    return max(1, coreCount - 1);
  }

  seLowdevice(false);
  int calculated = coreCount - 2;
  if (calculated % 2 != 0) {
    calculated -= 1;
  }
  return max(4, calculated);
}