import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'dart:developer' as developer_log;

double calculateBrightness(Uint8List bytes) {
  int sum = 0;
  for (int i = 0; i < bytes.length; i += 10) {
    sum += bytes[i];
  }
  return sum / (bytes.length / 10);
}

double getDynamicThreshold(double brightness) {
  if (brightness < 50) return 150.0;
  if (brightness < 100) return 300.0;
  return 500.0;
}

double calculateBlurScore(CameraImage image) {
  try {
    final Plane plane = image.planes[0];
    final Uint8List bytes = plane.bytes;
    final int stride = plane.bytesPerRow;
    final int physicalHeight = bytes.length ~/ stride;


    final int startY = physicalHeight ~/ 4;
    final int endY = physicalHeight * 3 ~/ 4;
    final int startX = stride ~/ 4;
    final int endX = stride * 3 ~/ 4;

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    //Khoảng cách an toàn để không bị tràn mảng khi lấy 5 điểm xung quanh
    final int safePadding = stride * 2 + 2;

    for (int y = startY; y <  endY; y += 4) {
      for (int x = startX; x <  endX; x += 4) {
        int index = y * stride  + x;

        if (index - safePadding < 0 || index + safePadding >= bytes.length) continue;

        int getBlurredPixel(int idx) {
          return (bytes[idx] + bytes[idx - 1] + bytes[idx + 1] + bytes[idx - stride] + bytes[idx + stride]) ~/ 5;
        }

        int center = getBlurredPixel(index);
        int up = getBlurredPixel(index - stride * 2);
        int down = getBlurredPixel(index + stride * 2);
        int left = getBlurredPixel(index - 2);
        int right = getBlurredPixel(index + 2);

        int laplacian = up + down + left + right - (4 * center);

        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 0.0;

    double mean = sum / count;
    double variance = (sumSq / count) - (mean * mean);

    return variance;
  } catch (e) {
    developer_log.log("❌ Lỗi Ải 1 (BlurChecker): $e");
    return 1000.0;
  }
}
