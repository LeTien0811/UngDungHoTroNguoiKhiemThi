class LogErrorServices {
  LogErrorServices._();

  static void showLog({
    required String where,
    required String type,
    required String message,
  }) {
    String dot = '=========================================================================================>';
    String new_message = "Bắt Log => Từ $where. => $type => $message";
    print(dot);
    print(new_message);
    print(dot);
  }
}
