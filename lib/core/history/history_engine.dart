import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/history/history_model.dart';
import 'package:build_access/services/storage/database_helper.dart';

class HistoryEngine {
  final DatabaseHelper _database = getIt<DatabaseHelper>();
  final String key = "scan_history";
  int defaultLimit = 5;
  int defaultOffset = 0;

  Future<bool> saveScan(HistoryModel model) async {
    return await _database.insertData(key, model.toMap());
  }

  Future<HistoryModel?> getLatestHistory() async {
    final List<HistoryModel> models = await readScan(limitProps: 1, offsetProps: 0);
    return models.isNotEmpty ? models.first : null;
  }

  Future<List<HistoryModel>> readScan({
    int? limitProps,
    int? offsetProps,
    String? sort = "",
  }) async {
    int limit = limitProps ?? defaultLimit;
    int offset = offsetProps ?? defaultOffset;
    String finalSort = (sort == null || sort.isEmpty)
        ? "created_time DESC"
        : sort;
    List<Map<String, dynamic>> data = await _database.readData(
      key,
      finalSort,
      limit,
      offset,
    );

    final List<HistoryModel> newModel = [];
    for (var item in data) {
      newModel.add(HistoryModel.fromMap(item));
    }
    return newModel;
  }

  Future<void> cleanHistory({int daysToKeep = 30}) async {
    await _database.deleteOld(key, daysToKeep);
  }
}
