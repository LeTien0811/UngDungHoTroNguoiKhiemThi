class HistoryModel {
  final String title; // tên vật đã quét
  final String rawOcrText; // Nội dung
  final String aiSummary;
  final String directoryPath; // Đường dẫn hình ảnh
  final DateTime createdTime; // ngày quét

  HistoryModel({
    required this.title,
    required this.rawOcrText,
    required this.aiSummary,
    required this.directoryPath,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'raw_ocr_text': rawOcrText,
      'ai_summary': aiSummary,
      'directory_path': directoryPath,
      'created_time': createdTime.toIso8601String(),
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      title: map['title'] ?? '',
      rawOcrText: map['raw_ocr_text'] ?? '',
      aiSummary: map['ai_summary'] ?? '',
      directoryPath: map['directory_path'] ?? '',
      createdTime: DateTime.parse(map['created_time']),
    );
  }
}
