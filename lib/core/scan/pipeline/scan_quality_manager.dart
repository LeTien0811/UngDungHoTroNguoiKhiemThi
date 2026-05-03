import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/providers/camera_provider.dart';

class ScanQualityManager {
  final CameraProvider _cameraProvider = getIt<CameraProvider>();

  // Biến đếm số frame lỗi liên tiếp để áp dụng chiến thuật "Gom nhóm 5 frame"
  // nhằm tối ưu UX, tránh spam âm thanh cho người dùng.
  int _consecutiveErrorCount = 0;

  /// Kiểm tra xem đã đạt ngưỡng 5 frame lỗi liên tiếp chưa.
  /// - Nếu status là ok/success: Reset biến đếm và trả về false.
  /// - Nếu là lỗi: Tăng biến đếm. Trả về true CHỈ KHI đủ 5 frame, sau đó reset về 0.
  bool isThresholdReached(ScanStatus status) {
    if (status == ScanStatus.ok) {
      _consecutiveErrorCount = 0;
      _cameraProvider.setCameraStatus(CameraStatus.success);
      return false;
    } else {
      _consecutiveErrorCount++;
      if (_consecutiveErrorCount == 5) {
        // Đạt ngưỡng 5 frame lỗi liên tiếp -> kích hoạt thông báo và reset đếm
        _consecutiveErrorCount = 0;
        return true;
      }
      // Chưa đủ 5 frame -> bỏ qua
      return false;
    }
  }
}