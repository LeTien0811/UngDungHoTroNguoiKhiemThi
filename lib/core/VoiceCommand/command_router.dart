import 'dart:convert';
import 'package:build_access/core/AI/ai_orchestrator.dart';
import 'package:build_access/core/history/history_engine.dart';
import 'package:build_access/core/setting/setting_orchestrator.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/features/history_feature/history_feature.dart';
import 'package:build_access/models/history/history_model.dart';
import 'package:build_access/providers/user_profile_provider.dart';
import 'dart:developer' as developer_log;
import 'package:get/get.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';

class CommandRouter {
  final SettingOrchestrator _settingOrchestrator = getIt<SettingOrchestrator>();
  final AIOrchestrator _aiEngine = getIt<AIOrchestrator>();
  final VoiceInteractionProvider _voice = getIt<VoiceInteractionProvider>();
  final HistoryEngine _historyEngine = getIt<HistoryEngine>();
  bool settingCheck(IntentType intentType) {
    String command = intentType.toString();
    return (command.contains("SETTING")) ? true : false;
  }

  Future<bool> runAI({required AIType type, required String userChat}) async {
    try {
      final latest = await _historyEngine.getLatestHistory();

      if (type == AIType.VOICE_ASSISTANT && latest == null) {
        await _voice.speak('voice_require_scan_first'.tr);
        return false;
      }
      final Stream<String> aiStream = _aiEngine.executeAiTask(
        type: type,
        data: latest != null ? jsonEncode(latest.toMap()) : "",
        history: "",
        userProfile: getIt<UserProfileProvider>().userProfile.toString(),
        userText: userChat,
      );

      StringBuffer buffer = StringBuffer();
      await for (final chunk in aiStream) {
        try {
          final Map<String, dynamic> map = jsonDecode(chunk);
          if (map.containsKey('text')) buffer.write(map['text']);
        } catch (e) {
          buffer.write(chunk);
        }
      }
      await _voice.speak(buffer.toString());
      return true;
    } catch (e) {
      developer_log.log("Lỗi $e", name: "CommandRouter");
      return false;
    }
  }

  Future<bool> runHistory() async {
    try {
      List<HistoryModel> model = await _historyEngine.readScan(
        limitProps: 1,
        offsetProps: 0,
      );
      await _voice.speak(model.first.aiSummary);
      return true;
    } catch (e) {
      developer_log.log("Lỗi $e", name: "CommandRouter");
      return false;
    }
  }

  Future<void> router(IntentType intentType, String userChat) async {
    try {
      bool isSetting = settingCheck(intentType);
      if (isSetting) {
        await _settingOrchestrator.process(intentType);
        await _voice.speak('setting_success'.tr);
        return;
      }

      switch (intentType) {
        case IntentType.USAGE:
          try {
            await runAI(type: AIType.PRODUCT_USAGE, userChat: userChat);
            return;
          } catch (e) {
            developer_log.log('có lỗi xảy ra: $e', name: "CommandRouter");
            await _voice.speak('voice_error_timeout'.tr);
            return;
          }
        case IntentType.SAFETY:
          try {
            await runAI(type: AIType.PRODUCT_SAFETY, userChat: userChat);
            return;
          } catch (e) {
            developer_log.log('có lỗi xảy ra: $e', name: "CommandRouter");
            await _voice.speak('voice_error_timeout'.tr);
            return;
          }
        case IntentType.DETAILS:
          try {
            await runAI(type: AIType.PRODUCT_DETAILS, userChat: userChat);
            return;
          } catch (e) {
            developer_log.log('có lỗi xảy ra: $e', name: "CommandRouter");
            await _voice.speak('voice_error_timeout'.tr);
            return;
          }
        case IntentType.REPEAT:
          List<HistoryModel> model = await _historyEngine.readScan(
            limitProps: 1,
            offsetProps: 0,
          );
          await _voice.speak(model.first.aiSummary);
          break;
        case IntentType.HISTORY:
          try {
            await _voice.speak('confirm_open_history'.tr);
            Get.toNamed(HistoryFeature.routerName);
            return;
          } catch(e) {
            developer_log.log('có lỗi xảy ra: $e', name: "CommandRouter");
            await _voice.speak('voice_error_timeout'.tr);
            return;
          }
        case IntentType.CANCEL:
          return;
        case IntentType.GENERAL:
          try {
            await runAI(type: AIType.GENERAL_CHAT, userChat: userChat);
            return;
          } catch (e) {
            developer_log.log('có lỗi xảy ra: $e', name: "CommandRouter");
            await _voice.speak('voice_error_timeout'.tr);
            return;
          }
          break;
        case IntentType.UNKNOWN:
          await _voice.speak('voice_not_understood'.tr);
          return;
        case IntentType.ERROR:
          await _voice.speak('voice_error_timeout'.tr);
          return;
        default:
          return;
      }
      return;
    } catch (e) {
      developer_log.log("Lỗi $e", name: "CommandRouter");
      return;
    }
  }
}
