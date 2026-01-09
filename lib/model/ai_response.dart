import 'dart:convert';

import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';

class AIResponse {
  final String location; // đang ở đâu
  final String purpose;  // để làm gì
  final String action;   // hành động
  final String content;  // nội dung để đọc

  AIResponse({
    required this.location,
    required this.purpose,
    required this.action,
    required this.content,
  });

  factory AIResponse.fromJsonString(String jsonString) {
    try {
      // Bước 1: Làm sạch chuỗi (AI hay thêm ```json ... ```)
      String cleanJson = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return AIResponse(
        location: data['location'] ?? 'home',
        purpose: data['purpose'] ?? 'chat',
        action: data['action'] ?? 'NONE',
        content: data['content'] ?? 'Xin lỗi, con chưa hiểu ý cô chú.',
      );
    } catch (e) {
      LogErrorServices.showLog(where: 'Ai Response -> chuyển json', type: 'chuyển json', message: 'Loi dinh dang $e');
      return AIResponse(
        location: 'error',
        purpose: 'error',
        action: 'NONE',
        content: jsonString,
      );
    }
  }
}