import 'dart:async';

import 'package:flutter_bucketeer/bucketeer.dart';
import 'package:flutter_bucketeer/src/evaluation_update_listener_dispatcher.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockEvaluationUpdateListener extends Mock implements EvaluationUpdateListener {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final eventController = StreamController<bool>.broadcast();

  test('Bucketeer Tests', () async {
    final dispatcher = EvaluationUpdateListenerDispatcher(eventController.stream);
    final mockListener = MockEvaluationUpdateListener();
    final listenToken = dispatcher.addEvaluationUpdateListener(mockListener);
    expect(listenToken.isNotEmpty, true);
    expect(dispatcher.listenerCount(), 1);
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);
    // wait 50ms because Stream is async
    await Future.delayed(const Duration(milliseconds: 50));
    verify(() => mockListener.onUpdate()).called(3);

    dispatcher.removeEvaluationUpdateListener(listenToken);
    expect(dispatcher.listenerCount(), 0);

    dispatcher.addEvaluationUpdateListener(mockListener);
    dispatcher.addEvaluationUpdateListener(mockListener);
    expect(dispatcher.listenerCount(), 2);

    dispatcher.clearEvaluationUpdateListeners();
    expect(dispatcher.listenerCount(), 0);
  });
}
