import 'package:build_access/config/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:build_access/providers/service_provider.dart';

class HomeViewModel extends BaseModel{
  final ProviderSevice providerSevice = getIt<ProviderSevice>();

  void initializeSystem() {
    runSafe(() async{
      await providerSevice.initializeSystem();
    }, 'HomeViewModel.initializeSystem');
  }

  @override
  void dispose() {
    super.dispose();
  }
}