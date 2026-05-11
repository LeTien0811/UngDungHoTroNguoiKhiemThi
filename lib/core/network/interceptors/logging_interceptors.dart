import 'package:dio/dio.dart';
import 'dart:developer' as developer_log;

class LogingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer_log.log(
      "🚀 REQUEST: [${options.method}] => PATH: ${options.path}",
      name: "NETWORK",
    );
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer_log.log(
      "✅ RESPONSE: [${response.statusCode}] => DATA: ${response.data}",
      name: "NETWORK",
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer_log.log(
      "❌ ERROR: [${err.response?.statusCode}] => PATH: ${err.requestOptions.path} => MSG: ${err.message}",
      name: "NETWORK",
    );
    return handler.next(err);
  }
}