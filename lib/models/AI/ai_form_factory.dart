class AiPromptFactory {
  static String buildOcrCorrectionPrompt(String rawText) {
    return "<|im_start|>system\n"
        "Bạn là chuyên gia hiệu đính văn bản. Nhiệm vụ: Sửa lỗi chính tả, thêm dấu câu và tách từ cho văn bản OCR bị lỗi.\n"
        "TUYỆT ĐỐI CHỈ TRẢ VỀ VĂN BẢN ĐÃ SỬA, KHÔNG GIẢI THÍCH, KHÔNG CHÀO HỎI.\n"
        "---VÍ DỤ---\n"
        "Đầu vào: UONO LẠNH THÁNH PHÁN mch extract from malt barleyl\n"
        "Đầu ra: Uống lạnh. Thành phần: Mạch nha.\n"
        "-----------\n"
        "<|im_end|>\n"
        "<|im_start|>onboarding\n"
        "Đầu vào: $rawText\n"
        "Đầu ra:<|im_end|>\n"
        "<|im_start|>assistant\n";
  }

  static String buildVoiceAssistantPrompt({
    required String ocrContext,
    required String userQuestion,
    String? userProfile,
  }) {
    final String profileContext = (userProfile != null && userProfile.isNotEmpty)
        ? userProfile
        : "Không có";

    return "<|im_start|>system\n"
        "Bạn là trợ lý ảo hỗ trợ người khiếm thị. Trả lời ngắn gọn, súc tích tối đa 2 câu.\n"
        "QUY TẮC BẮT BUỘC:\n"
        "1. Chỉ dựa vào 'Thông tin sản phẩm'. Nếu không có dữ liệu, trả lời 'Không có thông tin'.\n"
        "2. So sánh 'Thông tin sản phẩm' với 'Hồ sơ y tế'. Nếu phát hiện thành phần gây dị ứng hoặc nguy hiểm, PHẢI CẢNH BÁO NGAY LẬP TỨC.\n"
        "Hồ sơ y tế của người dùng: $profileContext\n"
        "<|im_end|>\n"
        "<|im_start|>onboarding\n"
        "Thông tin sản phẩm: $ocrContext\n"
        "Câu hỏi của tôi: $userQuestion\n"
        "<|im_end|>\n"
        "<|im_start|>assistant\n";
  }

  static String buildExtractBasicProfilePrompt({required String voiceText}) {
    return "<|im_start|>system\n"
        "Nhiệm vụ: Trích xuất thông tin cá nhân từ đoạn văn và xuất ra định dạng JSON.\n"
        "Yêu cầu: Chỉ trích xuất 3 trường: name (Họ tên), phone (Số điện thoại), address (Địa chỉ).\n"
        "Nếu thiếu thông tin nào, điền giá trị là \"Không rõ\".\n"
        "TUYỆT ĐỐI KHÔNG XUẤT THÊM BẤT KỲ VĂN BẢN NÀO NGOÀI ĐOẠN MÃ JSON.\n"
        "Ví dụ đầu ra:\n"
        "{\n"
        "  \"name\": \"Nguyễn Văn A\",\n"
        "  \"phone\": \"0901234567\",\n"
        "  \"address\": \"Hà Nội\"\n"
        "}\n"
        "<|im_end|>\n"
        "<|im_start|>onboarding\n"
        "Đoạn văn: $voiceText\n"
        "<|im_end|>\n"
        "<|im_start|>assistant\n";
  }
}