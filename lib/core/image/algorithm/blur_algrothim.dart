import 'dart:isolate';
import 'dart:typed_data';
import 'dart:developer' as developer_log;
import 'package:build_access/core/isolate/isolate_messages.dart';
import 'package:build_access/models/image/blur_score_params.dart';
import 'package:build_access/models/image/blur_score_response.dart';

class BlurAlgrothm {
  void computeLaplacianVariance(WorkerInit<void> init) {
    final receivePort = ReceivePort();
    init.sendPort.send(receivePort.sendPort);
    receivePort.listen((dynamic message) {
      if (message == 'SHUTDOWN_NOW') {
        receivePort.close();
        return;
      }
      if (message is WorkerTask<BlurScoreParams>) {
        try {
          final Uint8List bytes = message.data.bytes;
          final int stride = message.data.stride;
          final int width = message.data.width;
          final int height = message.data.height;

          final int startY = height ~/ 4;
          final int endY = height * 3 ~/ 4;
          final int startX = width ~/ 4;
          final int endX = width * 3 ~/ 4;

          double sum = 0;
          double sumSq = 0;
          int count = 0;
          int sumBrightness = 0;

          // tránh out-of-bounds
          final int safeStartY = startY < 2 ? 2 : startY;
          final int safeEndY = endY > height - 2 ? height - 2 : endY;

          final int safeStartX = startX < 2 ? 2 : startX;
          final int safeEndX = endX > width - 2 ? width - 2 : endX;

          for (int y = safeStartY; y < safeEndY; y += 4) {
            final int row = y * stride;

            for (int x = safeStartX; x < safeEndX; x += 4) {
              final int idx = row + x;

              int center =
                  (bytes[idx] +
                      bytes[idx - 1] +
                      bytes[idx + 1] +
                      bytes[idx - stride] +
                      bytes[idx + stride]) ~/
                  5;
              final int up =
                  (bytes[idx - (stride * 2)] +
                      bytes[idx - (stride * 2) - 1] +
                      bytes[idx - (stride * 2) + 1]) ~/
                      3;

              final int down =
                  (bytes[idx + (stride * 2)] +
                      bytes[idx + (stride * 2) - 1] +
                      bytes[idx + (stride * 2) + 1]) ~/
                      3;


              final int left = bytes[idx - 2];
              final int right = bytes[idx + 2];


              int laplacian = up + down + left + right - (4 * center);

              sum += laplacian;
              sumSq += laplacian * laplacian;
              sumBrightness += center;
              count++;
            }
          }

          double variance = 0.0;
          double avgBrightness = 0.0;

          if (count > 0) {
            final double mean = sum / count;

            variance = (sumSq / count) - (mean * mean);

            avgBrightness = sumBrightness / count;
          }

          message.replyPort.send(BlurScoreResponse(variance: variance, avgBrightness: avgBrightness));
        } catch (e) {
          developer_log.log("Lỗi Ải 1 (BlurChecker): $e");
          rethrow;
        }
      }
    });
  }
}
