import 'dart:async';
import 'dart:isolate';
import 'isolate_messages.dart';

class LongLivedWorker<I, TReq, TRes> {
  SendPort? _sendPort;
  Isolate? _isolate;
  final void Function(WorkerInit<I>) _entryPoint;

  LongLivedWorker(this._entryPoint);

  Future<void> init(I initData) async {
    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _entryPoint,
      WorkerInit<I>(receivePort.sendPort, initData),
    );

    _sendPort = await receivePort.first as SendPort;
  }

  Future<TRes?> execute(TReq payload) async {
    if (_sendPort == null) return null;

    final responsePort = ReceivePort();
    _sendPort!.send(WorkerTask<TReq>(responsePort.sendPort, payload));

    final result = await responsePort.first as TRes?;
    responsePort.close();

    return result;
  }

  Stream<TRes> streamExecute(TReq payload) {
    if (_sendPort == null) {
      throw Exception('Worker chưa được khởi tạo');
    }

    final responsePort = ReceivePort();
    _sendPort!.send(WorkerTask<TReq>(responsePort.sendPort, payload));

    return responsePort.takeWhile((message) => message != null).cast<TRes>();
  }

  void dispose() {
    if (_sendPort != null) {
      _sendPort!.send('SHUTDOWN_NOW');
    }

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }
}