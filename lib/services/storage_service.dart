import 'package:hotronguoikhiemthi_app/storage/storage_handle.dart';

class StorageService {
  String keyHistoryChat = 'History_chat';
  Future<String?> getLocalHistoryChat() async{
    String? historyChat = await StorageHandle().getData(keyHistoryChat);
    return historyChat;
  }

  Future<void> saveLocalHistoryChat(String chat) async{
    String? oldHistory = await getLocalHistoryChat() ?? '';

    oldHistory += chat;

    await StorageHandle().saveData(oldHistory, keyHistoryChat);
  }
}