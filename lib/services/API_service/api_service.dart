import 'package:build_access/core/network/interceptors/auth_interceptors.dart';
import 'package:build_access/core/network/interceptors/logging_interceptors.dart';
import 'package:dio/dio.dart';

class APIService {
  late Dio _dio;
  static const String _baseUrl = "https://s7bel7bigtop.shares.zrok.io/api/v1/ai";
  APIService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([AuthInterceptor(), LoggingInterceptor()]);
  }

  Future<Response<T>> getConfig<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return await _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> postConfig<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return await _dio.post<T>(path, data: data, options: options);
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
