import 'dart:ui';

class MyColors {
  // Nền đen tuyệt đối giúp các điểm ảnh LED tắt hoàn toàn, chữ nổi lên cực rõ
  static const Color bgDark = Color(0xFF000000);

  // Màu vàng Gold cho các thông tin quan trọng nhất (Tiêu đề, Mic)
  static const Color primaryGold = Color(0xFFFBBD08);

  // Màu trắng tinh cho nội dung chi tiết
  static const Color textWhite = Color(0xFFFFFFFF);

  // Màu xám nhẹ cho các đường kẻ hoặc chữ gợi ý
  static const Color textGrey = Color(0xFFB0B0B0);

  // Màu xanh cho hành động Xác nhận
  static const Color successGreen = Color(0xFF2ECC71);

  // Màu đỏ cho hành động Hủy
  static const Color errorRed = Color(0xFFE74C3C);

  // Màu Cyan cho các hành động bổ trợ (từ config cũ)
  static const Color actionCyan = Color(0xFF00E5FF);
}
