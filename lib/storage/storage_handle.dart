import 'package:shared_preferences/shared_preferences.dart';

class StorageHandle {
  static final StorageHandle _instance = StorageHandle._internal();
  factory StorageHandle() => _instance;
  StorageHandle._internal();

  late SharedPreferences? prefs;

  Future<void> init() async{
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveData(String data, String key) async {
    if (prefs == null) await init();
    prefs!.setString(key, data);
  }

  Future<String?> getData(String key) async {
    if (prefs == null) return "";
    final data = prefs!.getString(key);
    return data;
  }
}