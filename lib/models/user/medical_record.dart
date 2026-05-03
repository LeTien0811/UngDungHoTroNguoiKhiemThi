class MedicalRecord {
  final String condition;
  final String allergy;
  final String emergencyContact;

  MedicalRecord({
    this.condition = "Không rõ",
    this.allergy = "Không rõ",
    this.emergencyContact = "Không rõ",
  });

  MedicalRecord copyWith({
    String? condition,
    String? allergy,
    String? emergencyContact,
  }) {
    return MedicalRecord(
      condition: condition ?? this.condition,
      allergy: allergy ?? this.allergy,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'allergy': allergy,
      'emergencyContact': emergencyContact,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      condition: map['condition'] ?? "Không rõ",
      allergy: map['allergy'] ?? "Không rõ",
      emergencyContact: map['emergencyContact'] ?? "Không rõ",
    );
  }
}