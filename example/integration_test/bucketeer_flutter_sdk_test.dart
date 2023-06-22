import 'dart:ffi';

import 'package:bucketeer_example/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bucketeer/bucketeer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String featureTag = "flutter";
  const String userId001 = 'user_id_001';
  const String appVersion = "1.0.0";
  const bool debugging = true;
  void runAllTests() {
    /*
    enum CallMethods {
    initialize,
    stringVariation,
    intVariation,
    doubleVariation,
    boolVariation,
    jsonVariation,
    track,
    currentUser,
    updateUserAttributes,
    fetchEvaluations,
    flush,
    evaluationDetails,
    addEvaluationUpdateListener,
    removeEvaluationUpdateListener,
    clearEvaluationUpdateListeners,
    destroy,
    unknown,
  }
*/
    testWidgets('testStringVariation', (WidgetTester _) async {});
    testWidgets('testStringVariationDetail', (WidgetTester _) async {});
    testWidgets('testIntVariation', (WidgetTester _) async {});
    testWidgets('testIntVariationDetail', (WidgetTester _) async {});
    testWidgets('testDoubleVariation', (WidgetTester _) async {});
    testWidgets('testDoubleVariationDetail', (WidgetTester _) async {});
    testWidgets('testBoolVariation', (WidgetTester _) async {});
    testWidgets('testBoolVariationDetail', (WidgetTester _) async {});
    testWidgets('testJSONVariation', (WidgetTester _) async {});
    testWidgets('testJSONVariationDetail', (WidgetTester _) async {});

    testWidgets('testEvaluationUpdateFlow', (WidgetTester _) async {});
    testWidgets('testTrack', (WidgetTester _) async {});

  }

  group('SharedPreferences', () {
    setUp(() async {
      var result = await Bucketeer.instance.initialize(
            apiKey:
            Constants.API_KEY,
            apiEndpoint: Constants.API_ENDPOINT,
            featureTag: featureTag,
            userId: userId001,
            debugging: debugging,
            eventsFlushInterval: Constants.DEFAULT_EVENTS_FLUSH_INTERVAL,
            eventsMaxQueueSize: Constants.DEFAULT_EVENT_MAX_QUEUE_SIZE,
            pollingInterval: Constants.DEFAULT_POLLING_INTERVAL,
            backgroundPollingInterval: Constants.DEFAULT_BACKGROUND_POLLING_INTERVAL,
            appVersion: appVersion
        );
       expect(result.isSuccess, true);
    });

    tearDown(() async {
      var result = await Bucketeer.instance.destroy();
      expect(result.isSuccess, true);
      expect(result, const BKTResult.success(data: true));
    });

    runAllTests();
  });
}
