import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;
  AppPreferences(this._prefs);

  Future<void> saveData(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? readData(String key) {
    return _prefs.getString(key);
  }

  Future<void> deleteData(String key) async {
    await _prefs.remove(key);
  }

  // 3. Hàm hỗ trợ lưu Object
  Future<void> saveObject(String key, Map<String, dynamic> map) async {
    String jsonString = jsonEncode(map); // Biến Map thành chuỗi JSON
    await _prefs.setString(key, jsonString);
  }

  // 4. Hàm hỗ trợ đọc Object
  Map<String, dynamic>? readObject(String key) {
    String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
