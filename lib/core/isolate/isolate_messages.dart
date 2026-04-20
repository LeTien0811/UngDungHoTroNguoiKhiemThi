import 'dart:isolate';

class WorkerInit<I> {
  final SendPort sendPort;
  final I initData;

  WorkerInit(this.sendPort, this.initData);
}

class WorkerTask<T> {
  final SendPort replyPort;
  final T data;
  WorkerTask(this.replyPort, this.data);
}
