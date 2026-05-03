import 'dart:async';
import 'dart:developer' as developer;
import 'package:build_access/enum/state.dart';

abstract class BaseService {
  String get serviceName;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ServiceState _isProcess = ServiceState.idle;
  ServiceState get isProcess => _isProcess;

  Future<void> init();

  Future<void> dispose() async {
    log("Đã được giải phóng tài nguyên.");
    _isInitialized = false;
  }

  void log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: serviceName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<T?> runSafe<T>(
    Future<T> Function() action, {
    String? methodName,
  }) async {
    try {
      setBusy();
      return await action();
    } catch (e, stack) {
      log(
        "Lỗi tại ${methodName ?? 'một phương thức'}: $e",
        error: e,
        stackTrace: stack,
      );
      rethrow;
    } finally {
      setIdle();
    }
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    if (value) log("Service đã sẵn sàng hoạt động.");
  }

  void setBusy() {
    _isProcess = ServiceState.busy;
  }

  void setIdle() {
    _isProcess = ServiceState.idle;
  }
}
