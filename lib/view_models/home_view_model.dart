import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';

class HomeViewModel extends BaseModel {
  Future<void> init() async{
    await getIt<VoiceInteractionProvider>().speak("Xin chào, Vuốt từ trên xuống để thực hiện chức năng quét thông thông minh, nhấn giữ giữa màn hình để dùng chức năng hỏi.");
  }
  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
