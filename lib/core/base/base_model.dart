import 'package:build_access/enum/config.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer_log;

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  void setState(ViewState propState) {
        _state = propState;
        notifyListeners();
  }

  Future<void> runSafe(Future<void> Function() action, String messageFrom) async {
    try {
      setState(ViewState.busy);
      await action();
    } catch (e) {
      developer_log.log('====>  Lỗi: $e', name: messageFrom);
      rethrow;
    } finally {
      setState(ViewState.idle);
    }
  }
}