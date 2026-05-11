import 'dart:async';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/voice_interaction_provider.dart'; // Đã sửa Path chuẩn của ní
import 'dart:developer' as developer_log;

class SpeechToTextEngine {
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  Completer<String>? _inputCompleter;

  Future<void> startWalkieTalkie() async {
    try {
      developer_log.log("BỘ ĐÀM: Bắt đầu thu...", name: "SpeechToTextEngine");
      await _voice.stopSpeaking();

      await Future.delayed(const Duration(milliseconds: 200));

      _inputCompleter = Completer<String>();

      await _voice.startListening();
      return;
    } catch (e) {
      developer_log.log("Lỗi khởi động bộ đàm: $e", name: "SpeechToTextEngine");
      return;
    }
  }

  Future<String> stopWalkieTalkie() async {

    if (_inputCompleter == null) {
      developer_log.log("Cảnh báo: Gọi stop khi chưa start", name: "SpeechToTextEngine");
      return "";
    }

    try {
      developer_log.log("BỘ ĐÀM: Ngắt thu...", name: "SpeechToTextEngine");

      await _voice.stopListening();

      String text = _voice.recognizedText;

      if (!_inputCompleter!.isCompleted) {
        _inputCompleter!.complete(text);
      }

      return await _inputCompleter!.future;
    } catch (e) {
      developer_log.log("Lỗi khi ngắt bộ đàm: $e", name: "SpeechToTextEngine");
      return "";
    } finally {
      _inputCompleter = null;
    }
  }
}