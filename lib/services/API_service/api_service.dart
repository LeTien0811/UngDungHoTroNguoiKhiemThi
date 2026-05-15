import 'package:build_access/core/network/interceptors/auth_interceptors.dart';
import 'package:build_access/core/network/interceptors/logging_interceptors.dart';
import 'package:dio/dio.dart';

class APIService {
  late Dio _dio;
  static const String _baseUrl = "https://hotronguoikhiemthi-backend.shares.zrok.io/api/";
  APIService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([AuthInterceptor(), LoggingInterceptor()]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
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
