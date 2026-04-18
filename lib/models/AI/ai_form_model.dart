class AiFormModel {
  String ocrContext;
  String? userProfile;

  AiFormModel({required this.ocrContext, this.userProfile});

  static String orCorrectionForm() =>
      "Bạn là chuyên gia sửa lỗi văn bản. Sửa lỗi chính tả, thêm dấu, tách từ.\n"
      "Tuyệt đối chỉ in ra kết quả, không giải thích dài dòng.\n"
      "---VÍ DỤ---\n"
      "Đầu vào: UONO LẠNH THÁNH PHÁN\n"
      "Đầu ra: Uống lạnh. Thành phần.\n"
      "-----------";

  String voiceAssistantQA() =>
      "Bạn là trợ lý cho người khiếm thị. Trả lời câu hỏi ngắn gọn tối đa 2 câu.\n"
      "Thông tin sản phẩm: $ocrContext\n"
      "Hồ sơ người dùng (Dị ứng/Bệnh lý): ${userProfile ?? 'Không có'}\n"
      "Nhiệm vụ: Phân tích thông tin sản phẩm và hồ sơ để trả lời câu hỏi sau một cách chính xác nhất.";
}
