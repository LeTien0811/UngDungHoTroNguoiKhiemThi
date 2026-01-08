class LogErrorServices {
  LogErrorServices._();

  static void showLog({
    required String where,
    required String type,
    required String message,
  }) {
    String new_message = "Từ $where. => Kiểu Lỗi $type => Lỗi $message";
    print(new_message);
  }
}
