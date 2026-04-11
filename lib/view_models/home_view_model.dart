import 'package:build_access/config/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/global_provider.dart';

class HomeViewModel extends BaseModel{
  final GlobalProvider globalProvider = getIt<GlobalProvider>();

  void initializeSystem() {
    runSafe(() async{
      await globalProvider.initializeSystem();
    }, 'HomeViewModel.initializeSystem');
  }

  @override
  void dispose() {
    super.dispose();
  }
}