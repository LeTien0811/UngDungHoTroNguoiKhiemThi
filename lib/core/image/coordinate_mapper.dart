import 'dart:ui';

class CoordinateMapper {
  static Map<String, int> mapRotatedMlKitToRawSensor({
    required Rect mlKitRect,
    required Size imageSize,
    required int sensorOrientation,
  }) {
    final int x = mlKitRect.left.toInt();
    final int y = mlKitRect.top.toInt();
    final int w = mlKitRect.width.toInt();
    final int h = mlKitRect.height.toInt();

    final int imgW = imageSize.width.toInt();
    final int imgH = imageSize.height.toInt();

    switch (sensorOrientation) {
      case 90:
        return {
          'x': y,
          'y': imgW - x - w,
          'w': h,
          'h': w,
        };

      case 270:
        return {
          'x': imgH - y - h,
          'y': x,
          'w': h,
          'h': w,
        };

      case 180:
        return {
          'x': imgW - x - w,
          'y': imgH - y - h,
          'w': w,
          'h': h,
        };

      case 0:
      default:
        return {
          'x': x,
          'y': y,
          'w': w,
          'h': h,
        };
    }
  }
}