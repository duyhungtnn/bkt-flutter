import 'dart:async';

import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/evaluation_update_listener_dispatcher.dart';
import 'package:bucketeer_flutter_client_sdk/src/proxy_evaluation_update_listener.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockEvaluationUpdateListener extends Mock implements BKTEvaluationUpdateListener {}

void main() {
  final eventController = StreamController<bool>.broadcast();

  test('ProxyEvaluationUpdateListenToken tests', () async {
    expect(ProxyEvaluationUpdateListenToken.getToken(), null);
    ProxyEvaluationUpdateListenToken.setToken("token001");
    expect(ProxyEvaluationUpdateListenToken.getToken(), "token001");
    ProxyEvaluationUpdateListenToken.clearToken();
    expect(ProxyEvaluationUpdateListenToken.getToken(), null);
    ProxyEvaluationUpdateListenToken.setToken("token002");
    expect(ProxyEvaluationUpdateListenToken.getToken(), "token002");
  });

  test('EvaluationUpdateListener tests', () async {
    final dispatcher = EvaluationUpdateListenerDispatcher(eventController.stream);
    final mockListener = MockEvaluationUpdateListener();
    final neverCalledMockListener = MockEvaluationUpdateListener();
    final listenToken = dispatcher.addEvaluationUpdateListener(mockListener);
    expect(listenToken.isNotEmpty, true);
    expect(dispatcher.listenerCount(), 1);
    // sent event 3 times
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);
    // wait 50ms because Stream is async
    await Future.delayed(const Duration(milliseconds: 50));
    verify(() => mockListener.onUpdate()).called(3);

    dispatcher.removeEvaluationUpdateListener(listenToken);
    expect(dispatcher.listenerCount(), 0);

    dispatcher.addEvaluationUpdateListener(mockListener);
    dispatcher.addEvaluationUpdateListener(neverCalledMockListener);
    expect(dispatcher.listenerCount(), 2);

    dispatcher.clearEvaluationUpdateListeners();
    expect(dispatcher.listenerCount(), 0);

    // the new event sent. But no one listen to it
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);
    // wait 50ms because Stream is async
    await Future.delayed(const Duration(milliseconds: 50));
    // neverCalledMockListener is removed before any update sent
    // so that, it will never get an update anymore
    verifyNever(() => neverCalledMockListener.onUpdate());
    // the same with mockListener
    verifyNever(() => mockListener.onUpdate());
  });
}
