import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/models/history/history_model.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/storage/database_helper.dart';
import 'package:build_access/core/utils/dependency_injection.dart';

class HistoryViewModel extends BaseModel {
  final DatabaseHelper _dbHelper = getIt<DatabaseHelper>();
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();

  List<HistoryModel> historyList = [];
  int currentIndex = 0;

  @override
  void dispose() {
    _voice.stopSpeaking();
    super.dispose();
  }

  Future<void> loadHistory() async {
    await runSafe(() async {
      final data = await _dbHelper.readData(
        'scan_history',
        'created_time DESC',
        10,
        0,
      );
      historyList = data.map((e) => HistoryModel.fromMap(e)).toList();

      if (historyList.isEmpty) {
        await _voice.speak("Không có lịch sử quét nào.");
      } else {
        await _voice.speak(
          "Đã mở lịch sử. Vuốt lên hoặc xuống để duyệt. Đang ở mục đầu tiên.",
        );
      }
    }, "HistoryViewModel.loadHistory");
  }

  void onPageChanged(int index) {
    currentIndex = index;
  }

  Future<void> readCurrentHistory() async {
    if (historyList.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= historyList.length) {
      return;
    }
    final item = historyList[currentIndex];
    await _voice.speak("Lịch sử: ${item.title}. Tóm tắt: ${item.aiSummary}");
  }

  Future<void> deleteCurrentHistory() async {
    if (historyList.isEmpty) return;
    await runSafe(() async {
      final item = historyList[currentIndex];

      await _dbHelper.deleteCurrent(item);

      historyList.removeAt(currentIndex);
      notifyListeners();

      if (historyList.isEmpty) {
        await _voice.speak("Đã xóa. Hiện không còn lịch sử nào.");
      } else {
        if (currentIndex >= historyList.length) {
          currentIndex = historyList.length - 1;
        }
        await _voice.speak("Đã xóa lịch sử.");
      }
    }, "HistoryViewModel.deleteCurrentHistory");
  }
}
