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
    MedicalRecord? Function()? medicalRecord,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isSynced: isSynced ?? this.isSynced,
      medicalRecord: medicalRecord != null ? medicalRecord() : this.medicalRecord,
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
    String parseData(dynamic value) {
      if (value == null || value == "N/A" || value.toString().trim().isEmpty) {
        return "Không rõ";
      }
      return value.toString();
    }

    return UserModel(
      name: parseData(map['name']),
      phone: parseData(map['phone']),
      address: parseData(map['address']),
      isSynced: map['isSynced'] as bool? ?? false,
      medicalRecord: map['medicalRecord'] != null
          ? MedicalRecord.fromMap(map['medicalRecord'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}