import 'package:dio/dio.dart';
import 'dart:developer' as developer_log;

class APIService {
  late Dio _dio;
  static const String _baseUrl = "http://10.87.181.169:3000/api/v1/ai";
  APIService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 13),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          developer_log.log(
            "🚀 REQUEST: [${options.method}] => PATH: ${options.path}",
            name: "NETWORK",
          );
          return handler.next(options);
        },

        onResponse: (response, handler) {
          developer_log.log(
            "✅ RESPONSE: [${response.statusCode}] => DATA: ${response.data}",
            name: "NETWORK",
          );
          return handler.next(response);
        },

        onError: (DioException e, handler) {
          developer_log.log(
            "❌ ERROR: [${e.response?.statusCode}] => MSG: ${e.message}",
            name: "NETWORK",
          );
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: options ?? Options(responseType: ResponseType.json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
