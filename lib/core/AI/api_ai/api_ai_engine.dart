import 'dart:convert';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/providers/AI/api_ai_provider.dart';
import 'package:build_access/services/AI_service/api_service.dart';
import 'package:build_access/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer_log;

class APIAIEngine {
  final APIAIProvider provider = getIt<APIAIProvider>();
  final APIService _apiService = getIt<APIService>();
  final SecureStorageService _storage = getIt<SecureStorageService>();

  Stream<String> streamAIResponse(
    String type,
    String dataContent,
    List<Map<String, String>> history,
  ) async* {
    try {
      provider.setProcessing();

      final String userProfile =
          await _storage.readData('user_medical_profile') ?? "";

      Response<ResponseBody> response = await _apiService.post(
        '/stream',
        data: {"type": type, "data": dataContent, "history": history},
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final dataString = line.substring(6);
          if (dataString == '[DONE]')
            break;

          yield dataString;
        }
      }
    } on DioException catch (e) {
      developer_log.log("Lỗi Dio Stream: ${e.message}", name: "APIAIEngine");
      throw Exception("Lỗi kết nối Stream tới máy chủ.");
    } catch (e) {
      developer_log.log(
        "Cloud AI Error: $e",
        name: "ApiAiEngine.streamAIResponse",
      );
      rethrow;
    } finally {
      provider.setReady(true);
    }
  }
}
