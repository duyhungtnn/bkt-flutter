import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'constant.dart';
import 'evaluation_update_listener.dart';

class EvaluationUpdateListenerDispatcher {

  static const _eventChannelName =
      "${Constant.methodChannelName}::evaluation.update.listener";
  static const EventChannel _eventChannel = EventChannel(_eventChannelName);
  static const _listeners = <String, EvaluationUpdateListener>{};

  EvaluationUpdateListenerDispatcher() {
    _eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  void _onEvent(Object? event) {
    _listeners.forEach((key, value) {
      value.onUpdate();
    });
  }

  String addEvaluationUpdateListener(EvaluationUpdateListener listener) {
    final key = UniqueKey().hashCode.toString();
    _listeners[key] = listener;
    return key;
  }

  void removeEvaluationUpdateListener(String key) {
    _listeners.remove(key);
  }

  void clearEvaluationUpdateListeners() {
    _listeners.clear();
  }
}
