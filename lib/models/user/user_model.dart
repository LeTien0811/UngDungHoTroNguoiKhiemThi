import 'dart:convert';
import 'package:build_access/models/user/medical_record.dart';

class UserModel {
  final String name;
  final String email;
  final String phoneNumber; // ✅ Đã có
  final String imageUrl; // ✅ Đã thêm mới
  final String address;
  final bool isSynced;
  final String? secureAccessToken;
  final String? secureRefreshToken;

  UserModel({
    this.name = "Không rõ",
    this.email = "Không rõ",
    this.phoneNumber = "Không rõ", // ✅ Sửa dấu ; thành dấu ,
    this.imageUrl = "Không rõ", // ✅ Thêm giá trị mặc định
    this.address = "Không rõ",
    this.isSynced = false,
    this.secureAccessToken,
    this.secureRefreshToken,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber, // ✅ Thêm vào copyWith
    String? imageUrl, // ✅ Thêm vào copyWith
    String? address,
    bool? isSynced,
    MedicalRecord? Function()? medicalRecord,
    String? secureAccessToken,
    String? secureRefreshToken,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber, // ✅ Cập nhật ở đây
      imageUrl: imageUrl ?? this.imageUrl, // ✅ Cập nhật ở đây
      address: address ?? this.address,
      isSynced: isSynced ?? this.isSynced,
      secureAccessToken: secureAccessToken ?? this.secureAccessToken,
      secureRefreshToken: secureRefreshToken ?? this.secureRefreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phone_number': phoneNumber, // ✅ Map key cho backend
      'image_url': imageUrl, // ✅ Map key cho backend
      'address': address,
      'isSynced': isSynced,
      'secure_access_token': secureAccessToken,
      'secure_refresh_token': secureRefreshToken,
    };

    return map;
  }

  Map<String, String?> get tokens => {
    'access': secureAccessToken,
    'refresh': secureRefreshToken,
  };

  String get authorizationHeader => 'Bearer $secureAccessToken';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    String parseData(dynamic value) {
      if (value == null || value == "N/A" || value.toString().trim().isEmpty) {
        return "Không rõ";
      }
      return value.toString();
    }

    return UserModel(
      name: parseData(map['name']),
      email: parseData(map['email']),
      phoneNumber: parseData(map['phone_number']), // ✅ Parse từ Map
      imageUrl: parseData(map['image_url']), // ✅ Parse từ Map
      address: parseData(map['address']),
      isSynced: map['isSynced'] as bool? ?? false,
      secureAccessToken: map['secure_access_token'] as String?,
      secureRefreshToken: map['secure_refresh_token'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
