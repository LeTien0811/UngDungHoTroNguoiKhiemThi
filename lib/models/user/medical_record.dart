class MedicalRecord {
  final String condition;
  final String allergy;

  MedicalRecord({this.condition = "Không rõ", this.allergy = "Không rõ"});

  MedicalRecord copyWith({String? condition, String? allergy}) {
    return MedicalRecord(
      condition: condition ?? this.condition,
      allergy: allergy ?? this.allergy,
    );
  }

  Map<String, dynamic> toMap() {
    return {'condition': condition, 'allergy': allergy};
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      condition: map['condition'] ?? "Không rõ",
      allergy: map['allergy'] ?? "Không rõ",
    );
  }
}
