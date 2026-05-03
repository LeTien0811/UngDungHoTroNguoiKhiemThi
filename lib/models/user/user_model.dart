import 'dart:convert';

import 'package:build_access/models/user/medical_record.dart';

class UserModel {
  final String name;
  final String phone;
  final String address;
  final bool isSynced;
  final MedicalRecord? medicalRecord;

  UserModel({
    this.name = "Không rõ",
    this.phone = "Không rõ",
    this.address = "Không rõ",
    this.isSynced = false,
    this.medicalRecord,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? address,
    bool? isSynced,
    MedicalRecord? medicalRecord,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isSynced: isSynced ?? this.isSynced,
      medicalRecord: medicalRecord ?? this.medicalRecord,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
      'address': address,
      'isSynced': isSynced,
    };

    if (medicalRecord != null) {
      map['medicalRecord'] = medicalRecord!.toMap();
    }

    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? "Không rõ",
      phone: map['phone'] ?? "Không rõ",
      address: map['address'] ?? "Không rõ",
      isSynced: map['isSynced'] ?? false,
      medicalRecord: map['medicalRecord'] != null
          ? MedicalRecord.fromMap(map['medicalRecord'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
