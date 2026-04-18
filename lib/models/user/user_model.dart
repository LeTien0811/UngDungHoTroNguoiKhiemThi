class UserModel {
  final name;
  final int age;
  final String address;
  final String medicalHistory;

  final int impairmentLevel;

  final String emergencyPhone;

  final String emergencyNotes;

  UserModel({
    required this.name,
    required this.age,
    required this.address,
    required this.medicalHistory,
    required this.impairmentLevel,
    required this.emergencyPhone,
    required this.emergencyNotes,
  });

  UserModel copyWith({
    String? name,
    int? age,
    String? address,
    String? medicalHistory,
    int? impairmentLevel,
    String? emergencyPhone,
    String? emergencyNotes,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      impairmentLevel: impairmentLevel ?? this.impairmentLevel,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      emergencyNotes: emergencyNotes ?? this.emergencyNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'medicalHistory': medicalHistory,
      'impairmentLevel': impairmentLevel,
      'emergencyPhone': emergencyPhone,
      'emergencyNotes': emergencyNotes,
    };
  }


}
