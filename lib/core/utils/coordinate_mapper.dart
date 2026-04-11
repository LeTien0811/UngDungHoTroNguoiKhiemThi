import 'dart:ui';

class CoordinateMapper {
  /// Chuyển đổi tọa độ từ ML Kit sang Tọa độ Pixel thực tế của Frame
  static Map<String, int> mapToImagePixels({
    required Rect mlKitRect,
    required Size imageSize,   // Kích thước thực của Frame (ví dụ 1080x1920)
    required Size previewSize, // Kích thước Widget hiển thị trên màn hình
  }) {
    // 1. Tính tỉ lệ giữa Ảnh thực và Preview
    double scaleX = imageSize.width / previewSize.width;
    double scaleY = imageSize.height / previewSize.height;

    // 2. Nhân tỉ lệ để ra tọa độ Pixel thực
    int x = (mlKitRect.left * scaleX).toInt();
    int y = (mlKitRect.top * scaleY).toInt();
    int w = (mlKitRect.width * scaleX).toInt();
    int h = (mlKitRect.height * scaleY).toInt();

    // 3. Chốt chặn an toàn (Tránh giá trị âm hoặc vượt quá kích thước ảnh)
    x = x.clamp(0, imageSize.width.toInt());
    y = y.clamp(0, imageSize.height.toInt());

    // Đảm bảo rộng/cao không làm tràn biên ảnh
    if (x + w > imageSize.width) w = imageSize.width.toInt() - x;
    if (y + h > imageSize.height) h = imageSize.height.toInt() - y;

    return {'x': x, 'y': y, 'w': w, 'h': h};
  }
}