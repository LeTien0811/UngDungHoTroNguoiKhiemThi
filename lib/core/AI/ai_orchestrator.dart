import 'dart:convert';

import 'package:build_access/core/AI/api_ai/api_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/local_ai_engine.dart';
import 'package:build_access/core/AI/local_ai/model_downloader_service.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/enum/state.dart';
import 'package:build_access/enum/ai_form_factory.dart';
import 'package:build_access/models/vision_assistant/vision_assistant_input.dart';
import 'package:build_access/models/vision_assistant/vision_assistant_request.dart';
import 'package:build_access/providers/AI/api_ai_provider.dart';
import 'package:build_access/providers/AI/local_ai_provider.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/AI_service/hardware_service.dart';
import 'dart:developer' as developer_log;
import 'package:get/get.dart';

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
      await voiceProvider.speak('ai_no_network_no_local'.tr);
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
        'ai_no_network_no_local'.tr,
      );
      return;
    }
  }

  Stream<String> executeAiTask({
    bool isStream = true,
    required VisionAssistantRequest visionAssistantRequest,
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
        final rawStream = cloudEngine.streamAIResponse(
          visionAssistantRequest: visionAssistantRequest,
        );

        yield* rawStream.map((chunk) {
          try {
            final Map<String, dynamic> chunkMap = jsonDecode(chunk);
            if (chunkMap.containsKey('text')) {
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
        yield 'ai_network_interrupted_fallback'.tr;
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
          getIt<VoiceInteractionProvider>().speak('ai_starting_please_wait'.tr);
          await initializer();
        }

        String finalLocalPrompt = AiPromptFactory.generateLocalPrompt(
          visionAssistantRequest.type,
          visionAssistantRequest.userRequest ?? '',
          "",
        );

        final String localResponse = await localEngine.executeTask(
          finalLocalPrompt,
        );
        yield localResponse;
      } catch (e) {
        yield 'ai_local_system_error'.tr;
      }
    } else {
      developer_log.log('Thiết bị yếu & Không có mạng', name: 'AiOrchestrator');
      yield 'ai_no_network_no_local'.tr;
    }
  }

  Future<void> dispose() async {
    localEngine.dispose();
    localProvider.dispose();
    cloudProvider.dispose();
  }
}
