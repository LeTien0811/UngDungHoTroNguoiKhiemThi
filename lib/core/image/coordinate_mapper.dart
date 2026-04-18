import 'dart:math' as math;
import 'dart:ui';

class CoordinateMapper {
  static Map<String, int> mapToImagePixels({
    required Rect mlKitRect,
    required Size imageSize, // Frame thô từ camera (ví dụ: 1920x1080)
    required Size
    previewSize, // Kích thước Widget trên màn hình (ví dụ: 1080x1920)
    required int sensorOrientation, // Thường là 90 hoặc 270 trên Android
  }) {
    // 1. Xử lý swap width/height nếu ảnh bị xoay (Android chuẩn)
    bool isRotated = sensorOrientation == 90 || sensorOrientation == 270;

    double imgW = isRotated ? imageSize.height : imageSize.width;
    double imgH = isRotated ? imageSize.width : imageSize.height;

    //Tính scale theo BoxFit.cover
    final double scale = math.max(
      imgW / previewSize.width,
      imgH / previewSize.height,
    );

    // 2. Tính tỉ lệ Scale
    double scaledW = previewSize.width * scale;
    double scaledH = previewSize.height * scale;

    // 3. Tính offset do crop (letterbox)
    final double offsetX = (scaledW - imgW) / 2;
    final double offsetY = (scaledH - imgH) / 2;

    // 3. Map tọa độ
    int x = ((mlKitRect.left * scale) - offsetX).toInt();
    int y = ((mlKitRect.top * scale) - offsetY).toInt();
    int w = (mlKitRect.width * scale).toInt();
    int h = (mlKitRect.height * scale).toInt();

    // 4. Chốt chặn biên
    int padding = 4;
    x = (x - padding).clamp(0, imgW.toInt() - 1);
    y = (y - padding).clamp(0, imgH.toInt() - 1);
    w = (w + padding * 2).clamp(1, imgW.toInt() - x);
    h = (h + padding * 2).clamp(1, imgH.toInt() - y);

    final int maxCropW = (imgW * 0.82).toInt();
    final int maxCropH = (imgH * 0.82).toInt();

    if (w > maxCropW) {
      final int centerX = x + (w ~/ 2);
      w = maxCropW;
      x = (centerX - (w ~/ 2)).clamp(0, imgW.toInt() - w);
    }

    if (h > maxCropH) {
      final int centerY = y + (h ~/ 2);
      h = maxCropH;
      y = (centerY - (h ~/ 2)).clamp(0, imgH.toInt() - h);
    }

    switch (sensorOrientation) {
      case 90:
        final int newX = y;
        final int newY = imgW.toInt() - x - w;
        return {'x': newX, 'y': newY, 'w': h, 'h': w};

      case 270:
        final int newX = imgH.toInt() - y - h;
        final int newY = x;
        return {'x': newX, 'y': newY, 'w': h, 'h': w};

      case 180:
        return {
          'x': imgW.toInt() - x - w,
          'y': imgH.toInt() - y - h,
          'w': w,
          'h': h,
        };

      default:
        return {'x': x, 'y': y, 'w': w, 'h': h};
    }
  }
}
