import 'dart:typed_data';
import 'package:camera/camera.dart';

double calculateBlurScore(CameraImage image) {
  try {
    final Plane plane = image.planes[0];
    final Uint8List bytes = plane.bytes;
    final int width = image.width;
    final int height = image.height;
    final int bytesPerRow = plane.bytesPerRow;

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 4; y < height - 4; y += 8) {
      for (int x = 4; x < width - 4; x += 8) {
        int index = y * bytesPerRow + x;

        int center = bytes[index];
        int left = bytes[index - 1];
        int right = bytes[index + 1];
        int up = bytes[index - bytesPerRow];
        int down = bytes[index + bytesPerRow];

        int laplacian = up + down + left + right - (4 * center);

        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 0;

    double mean = sum / count;
    double variance = (sumSq / count) - (mean * mean);

    return variance;
  } catch (e) {
    rethrow;
  }
}
