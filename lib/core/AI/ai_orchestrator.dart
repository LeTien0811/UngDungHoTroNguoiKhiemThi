import 'dart:convert';

import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/enum/ai_form_factory.dart';
import 'package:build_access/providers/AI/api_ai_provider.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/AI_service/hardware_service.dart';
import 'dart:developer' as developer_log;

import 'package:build_access/services/AI_service/network_service.dart';

class AIOrchestrator {
  final APIAIEngine cloudEngine = getIt<APIAIEngine>();
  final APIAIProvider cloudProvider = getIt<APIAIProvider>();

  final LocalAIEngine localEngine = getIt<LocalAIEngine>();
  final LocalAiProvider localProvider = getIt<LocalAiProvider>();

  final NetworkService networkService = getIt<NetworkService>();
  final HardwareService hardwareService = getIt<HardwareService>();
  final VoiceInteractionProvider voiceProvider =
      getIt<VoiceInteractionProvider>();

  bool hasNet = false;
  bool canRunLocal = false;

  Future<void> initializer() async {
    hasNet = await networkService.hasRealInternet();
    canRunLocal = await hardwareService.isCapableForLocalAI();

    if (!hasNet && !canRunLocal) {
      developer_log.log('Thiết bị yếu & Không có mạng', name: 'AiOrchestrator');
      await voiceProvider.speak(
        "Không có kết nối mạng và thiết bị không hỗ trợ chế độ ngoại tuyến. Vui lòng kết nối Wifi hoặc 4G để tiếp tục.",
      );
      return;
    }

    if (hasNet) {
      if (cloudProvider.status == AIStatus.uninitialized) {
        developer_log.log('Đang khởi tạo Cloud AI...', name: 'AiOrchestrator');
        cloudProvider.setReady(true);
      }
    }

    if (canRunLocal) {
      if (localProvider.status == AIStatus.uninitialized) {
        try {
          developer_log.log(
            'Đang khởi tạo Local AI...',
            name: 'AiOrchestrator',
          );
          String modelPath = await getIt<ModelDownloaderService>()
              .downloadModel(
                onProgress: getIt<VoiceInteractionProvider>().speak,
              );
          await localEngine.initialize(modelPath);
        } catch (e) {
          developer_log.log(
            'Lỗi tải/khởi tạo model: $e',
            name: 'AiOrchestrator',
          );
        }
      }
    } else {
      developer_log.log('Thiết bị yếu & Không có mạng', name: 'AiOrchestrator');
      await getIt<VoiceInteractionProvider>().speak(
        "Không có kết nối mạng và thiết bị không hỗ trợ chế độ ngoại tuyến. Vui lòng kết nối Wifi hoặc 4G để tiếp tục.",
      );
      return;
    }
  }

  Stream<String> executeAiTask({
    required AIType type,
    required String data,
    bool isStream = true,
    String? userText,
    String? userProfile,
    String? history,
    String? imageBase64
  }) async* {
    final bool currentNetworkStatus = await networkService.hasRealInternet();
    if (currentNetworkStatus) {
      developer_log.log('Đang gọi Cloud AI...', name: 'AiOrchestrator');
      try {
        if (cloudProvider.status == AIStatus.processing) {
          developer_log.log('AI đang bận', name: 'AiOrchestrator');
          return;
        }

        if (cloudProvider.status != AIStatus.ready ||
            cloudProvider.status != AIStatus.uninitialized) {
          cloudProvider.setReady(true);
        }

        final rawStream =  cloudEngine.streamAIResponse(
          type: type.name,
          data: data,
          history: history,
          userProfile: userProfile,
          userText: userText,
          imageBase64: imageBase64,
        );
        
        yield* rawStream.map((chunk) {
          try {
            final Map<String, dynamic> chunkMap = jsonDecode(chunk);
            if(chunkMap.containsKey('text')) {
              return chunkMap['text'];
            }
            return chunk;
          } catch (e) {
            developer_log.log(
              'có lỗi ở catch chỗ lọc chunk: $e',
              name: 'AiOrchestrator',
            );
              return chunk;
          }
        });

        return;
      } catch (e) {
        developer_log.log(
          'Cloud AI thất bại, chuyển Fallback... $e',
          name: 'AiOrchestrator',
        );
        yield "Đường truyền gián đoạn. Chờ một chút, hệ thống ngoại tuyến đang kích hoạt.\n";
      }
    }

    if (canRunLocal) {
      developer_log.log('Đang gọi Local AI...', name: 'AiOrchestrator');
      try {
        if (cloudProvider.status == AIStatus.processing) {
          developer_log.log('AI đang bận', name: 'AiOrchestrator');
          return;
        }

        if (localProvider.status != AIStatus.ready ||
            localProvider.status != AIStatus.uninitialized) {
          getIt<VoiceInteractionProvider>().speak(
            "Đang khởi động AI vui lòng đợi chút",
          );
          await initializer();
        }

        String finalLocalPrompt = AiPromptFactory.generateLocalPrompt(
          type,
          data,
          "",
        );

        final String localResponse = await localEngine.executeTask(
          finalLocalPrompt,
        );
        yield localResponse;
      } catch (e) {
        yield "Hệ thống AI ngoại tuyến gặp sự cố. Vui lòng khởi động lại ứng dụng.";
      }
    } else {
      developer_log.log('Thiết bị yếu & Không có mạng', name: 'AiOrchestrator');
      yield "Không có kết nối mạng và thiết bị không hỗ trợ chế độ ngoại tuyến. Vui lòng kết nối Wifi hoặc 4G để tiếp tục.";
    }
  }

  Future<void> dispose() async {
    localEngine.dispose();
    localProvider.dispose();
    cloudProvider.dispose();
  }
}
