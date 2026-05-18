import 'dart:isolate';
import 'dart:typed_data';
import 'dart:developer' as developer_log;
import 'package:build_access/core/isolate/isolate_messages.dart';
import 'package:build_access/models/image/blur_score_params.dart';
import 'package:build_access/models/image/blur_score_response.dart';

class BlurAlgrothm {
  int getBlurredPixel(Uint8List bytes, int idx, int stride) {
    return (bytes[idx] +
            bytes[idx - 1] +
            bytes[idx + 1] +
            bytes[idx - stride] +
            bytes[idx + stride]) ~/
        5;
  }

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
          final Uint8List bytes = message.bytes;
          final int stride = message.stride;
          final int physicalHeight = bytes.length ~/ stride;

          final int startY = physicalHeight ~/ 4;
          final int endY = physicalHeight * 3 ~/ 4;
          final int startX = stride ~/ 4;
          final int endX = stride * 3 ~/ 4;

          double sum = 0;
          double sumSq = 0;
          int count = 0;

          final int safePadding = stride * 2 + 2;

          for (int y = startY; y < endY; y += 4) {
            for (int x = startX; x < endX; x += 4) {
              int index = y * stride + x;

              if (index - safePadding < 0 ||
                  index + safePadding >= bytes.length) {
                continue;
              }

              int center = getBlurredPixel(bytes, index, stride);
              int up = getBlurredPixel(bytes, index - stride * 2, stride);
              int down = getBlurredPixel(bytes, index + stride * 2, stride);
              int left = getBlurredPixel(bytes, index - 2, stride);
              int right = getBlurredPixel(bytes, index + 2, stride);

              int laplacian = up + down + left + right - (4 * center);

              sum += laplacian;
              sumSq += laplacian * laplacian;
              count++;
            }
          }

          if (count == 0) return 0.0;

          double mean = sum / count;
          double variance = (sumSq / count) - (mean * mean);
          message.responsePort.send(BlurScoreResponse(blurScore: variance));
        } catch (e) {
          developer_log.log("Lỗi Ải 1 (BlurChecker): $e");
          rethrow;
        }
      }
    });
  }
}
