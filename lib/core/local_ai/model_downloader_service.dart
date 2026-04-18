import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloaderService {
  static const String _modelUrl = "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf";
  static const String _fileName = "qwen2.5_0.5b_q4.gguf";

  Future<String> downloadModel({required Function(String) onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$_fileName';
    final file = File(savePath);

    if (await file.exists()) {
      final size = await file.length();
      if (size > 350 * 1024 * 1024) {
        return savePath;
      } else {
        await file.delete();
      }
    }

    final dio = Dio();

    try {
      await dio.download(
        _modelUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            if(progress % 20 == 0) {
              onProgress(progress.toString());
            }
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 15),
        ),
      );

      return savePath;
    } catch (e) {
      if (await file.exists()) {
        await file.delete();
      }
      throw Exception('DownloadFailed: $e');
    }
  }
}