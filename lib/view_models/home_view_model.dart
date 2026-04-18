import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/global_provider.dart';

class HomeViewModel extends BaseModel {
  final GlobalProvider globalProvider = getIt<GlobalProvider>();

  void initializeSystem() {
    runSafe(() async {
      if (!globalProvider.isReady) {
        await globalProvider.initializeSystem();
      }
      globalProvider.stopSpeaking();
    }, 'HomeViewModel.initializeSystem');
  }

  @override
  Future<void> dispose() async{
    super.dispose();
  }
}
