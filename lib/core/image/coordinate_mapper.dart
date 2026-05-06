import 'dart:ui';

class CoordinateMapper {
  // AI-added: Nới box object detector thêm một biên an toàn để không cắt mất
  // mép nhãn/bao bì. Tăng ngang nhiều hơn dọc vì thông tin sản phẩm thường trải
  // theo chiều ngang trên mặt bao bì.
  static const double _horizontalPaddingRatio = 0.08;
  static const double _verticalPaddingRatio = 0.06;

  // AI-added: Thống nhất crop dưới dạng tọa độ chuẩn hóa 0..1 để worker
  // OpenCV chỉ phải quy đổi sang pixel đúng một lần trên sensor raw.
  static Map<String, double> mapRotatedMlKitToRawSensor({
    required Rect mlKitRect,
    required Size mlKitImageSize, // Kích thước ảnh mà ML Kit đã xử lý
    required int sensorOrientation,
  }) {
    // Tọa độ chuẩn hóa (0.0 -> 1.0) để triệt tiêu sự khác biệt về độ phân giải
    double left = mlKitRect.left / mlKitImageSize.width;
    double top = mlKitRect.top / mlKitImageSize.height;
    double width = mlKitRect.width / mlKitImageSize.width;
    double height = mlKitRect.height / mlKitImageSize.height;

    double finalX, finalY, finalW, finalH;

    // Giả định Sensor Raw luôn là Landscape (W > H)
    // Nếu sensorOrientation = 90, ảnh ML Kit là Portrait (H > W)
    switch (sensorOrientation) {
      case 90:
        finalX = top;
        finalY = 1.0 - left - width;
        finalW = height;
        finalH = width;
        break;
      case 270:
        finalX = 1.0 - top - height;
        finalY = left;
        finalW = height;
        finalH = width;
        break;
      default:
        finalX = left;
        finalY = top;
        finalW = width;
        finalH = height;
    }

    return {
      ..._expandNormalizedCrop(
        x: finalX,
        y: finalY,
        w: finalW,
        h: finalH,
      ),
    };
  }

  // AI-added: Clamp sau khi nới box để tránh out-of-range ở worker OpenCV.
  static Map<String, double> _expandNormalizedCrop({
    required double x,
    required double y,
    required double w,
    required double h,
  }) {
    final double padX = w * _horizontalPaddingRatio;
    final double padY = h * _verticalPaddingRatio;

    final double expandedX = (x - padX).clamp(0.0, 1.0);
    final double expandedY = (y - padY).clamp(0.0, 1.0);
    final double expandedRight = (x + w + padX).clamp(0.0, 1.0);
    final double expandedBottom = (y + h + padY).clamp(0.0, 1.0);

    return {
      'x': expandedX,
      'y': expandedY,
      'w': (expandedRight - expandedX).clamp(0.0, 1.0),
      'h': (expandedBottom - expandedY).clamp(0.0, 1.0),
    };
  }
}
