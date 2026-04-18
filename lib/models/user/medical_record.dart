class MedicalRecord {
  final String substance; // Ví dụ: Paracetamol
  final String note;      // Ví dụ: Dị ứng nặng hơn khi dùng với thuốc tê

  MedicalRecord({required this.substance, required this.note});

  // Chuyển sang Map để lưu xuống database/json
  Map<String, dynamic> toMap() {
    return {
      'substance': substance,
      'note': note,
    };
  }

  // Khôi phục từ database/json
  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      substance: map['substance'] ?? '',
      note: map['note'] ?? '',
    );
  }
}