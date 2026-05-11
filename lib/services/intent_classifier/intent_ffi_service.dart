import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:developer' as developer_log;

typedef CreateFastTextC = Pointer<Void> Function();
typedef CreateFastTextDart = Pointer<Void> Function();

typedef LoadModelC = Void Function(Pointer<Void> handle, Pointer<Utf8> path);
typedef LoadModelDart = void Function(Pointer<Void> handle, Pointer<Utf8> path);

typedef PredictC = Pointer<Utf8> Function(Pointer<Void> handle, Pointer<Utf8> text);
typedef PredictDart = Pointer<Utf8> Function(Pointer<Void> handle, Pointer<Utf8> text);

typedef FreeStringC = Void Function(Pointer<Utf8> str);
typedef FreeStringDart = void Function(Pointer<Utf8> str);

typedef DestroyC = Void Function(Pointer<Void> handle);
typedef DestroyDart = void Function(Pointer<Void> handle);

class IntentFFIService {
  late final DynamicLibrary _lib;
  Pointer<Void>? _handle;

  late final CreateFastTextDart _create;
  late final LoadModelDart _load;
  late final PredictDart _predict;
  late final FreeStringDart _freeStr;
  late final DestroyDart _destroy;

  bool _isNativeReady = false;

  bool initialize() {
    try {
      _lib = Platform.isAndroid
          ? DynamicLibrary.open('libfasttext_wrapper.so')
          : DynamicLibrary.process();

      _create = _lib.lookupFunction<CreateFastTextC, CreateFastTextDart>('create_fasttext');
      _load = _lib.lookupFunction<LoadModelC, LoadModelDart>('load_model');
      _predict = _lib.lookupFunction<PredictC, PredictDart>('predict_intent');
      _freeStr = _lib.lookupFunction<FreeStringC, FreeStringDart>('free_string');
      _destroy = _lib.lookupFunction<DestroyC, DestroyDart>('destroy_fasttext');

      _handle = _create();
      return _handle != nullptr;
    } catch (e) {
      developer_log.log('init không thành công: $e', name: "IntentFFIService.initialize");
      return false;
    }
  }

  bool loadModel(String absolutePath) {
    try {
      final pathPtr = absolutePath.toNativeUtf8();
      _load(_handle!, pathPtr);
      malloc.free(pathPtr);
      _isNativeReady = true;
      return true;
    } catch(e) {
      developer_log.log('loadModel không thành công: $e', name: "IntentFFIService.loadModel");
      return false;
    }
  }

  String predict(String text) {
    if (!_isNativeReady) {
      developer_log.log('Model chưa được nạp, từ chối dự đoán để chống Crash C++', name: "IntentFFIService.predict");
      return "ERROR";
    }

    final textPtr = text.toNativeUtf8();
    final resultPtr = _predict(_handle!, textPtr);

    final String result = resultPtr.toDartString();

    _freeStr(resultPtr);
    malloc.free(textPtr);

    return result.replaceAll("__label__", "").toUpperCase();
  }

  void dispose() {
    _isNativeReady = false;
    _destroy(_handle!);
  }
}