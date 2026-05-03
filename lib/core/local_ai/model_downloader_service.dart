import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer_log;

class ModelDownloaderService {
  static const String _modelUrl = "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf";
  static const String _fileName = "qwen2.5_0.5b_q4.gguf";
  int _lastSpokenProgress = 0;

  Future<String> downloadModel({required Function(String) onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$_fileName';
    final file = File(savePath);

    if (await file.exists()) {
      final size = await file.length();
      if (size > 350 * 1024 * 1024) {
        developer_log.log("Model đã có sẵn trong máy ($size bytes). Bỏ qua tải!", name: "ModelDownloader");
        return savePath;
      } else {
        developer_log.log("Model cũ bị lỗi (chưa đủ dung lượng). Xóa và tải lại...", name: "ModelDownloader");
        await file.delete();
      }
    }

    developer_log.log("Bắt đầu tải model từ Hugging Face...", name: "ModelDownloader");
    final dio = Dio();

    try {
      await dio.download(
        _modelUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            int currentProgress = ((received / total) * 100).toInt();

            if (currentProgress > _lastSpokenProgress && currentProgress % 20 == 0) {
              _lastSpokenProgress = currentProgress;
              onProgress("$currentProgress phần trăm");
              developer_log.log("Tiến độ tải model: $currentProgress%", name: "ModelDownloaderService");
            }
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 15),
        ),
      );

      developer_log.log("Tải model thành công!", name: "ModelDownloader");
      return savePath;
    } catch (e) {
      if (await file.exists()) {
        await file.delete();
      }
      throw Exception('DownloadFailed: $e');
    }
  }
}