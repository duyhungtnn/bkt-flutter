import 'dart:ffi';

import 'package:bucketeer_example/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bucketeer/bucketeer.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String APP_VERSION = "1.2.3";
  const String OLD_APP_VERSION = "0.0.1";
  const bool DEBUGGING = true;

  // E2E iOS
  const String FEATURE_TAG = "ios";
  const String USER_ID = 'bucketeer-ios-user-id-1';

  const String FEATURE_ID_BOOLEAN = "feature-ios-e2e-bool";
  const bool FEATURE_ID_BOOLEAN_VALUE = true;

  const String FEATURE_ID_STRING = "feature-ios-e2e-string";
  const String FEATURE_ID_STRING_VALUE = "value-1";
  const String FEATURE_ID_STRING_VALUE_UPDATE = "value-2";

  const String FEATURE_ID_INT = "feature-ios-e2e-integer";
  const int FEATURE_ID_INT_VALUE = 10;

  const String FEATURE_ID_DOUBLE = "feature-ios-e2e-double";
  const double FEATURE_ID_DOUBLE_VALUE = 2.1;

  const String FEATURE_ID_JSON = "feature-ios-e2e-json";
  const Map<String, dynamic> FEATURE_ID_JSON_VALUE = {"key": "value-1"};

  const String GOAL_ID = "goal-ios-e2e-1";
  const double GOAL_VALUE = 1.0;
  // const String FEATURE_TAG = "flutter";
  // const String USER_ID = 'bucketeer-flutter-user-id-1';
  // const String FEATURE_ID_BOOLEAN = "feature-flutter-e2e-boolean";
  // const String FEATURE_ID_STRING = "feature-flutter-e2e-string";
  // const String FEATURE_ID_INT = "feature-flutter-e2e-int";
  // const String FEATURE_ID_DOUBLE = "feature-flutter-e2e-double";
  // const String FEATURE_ID_JSON = "feature-flutter-e2e-json";
  // const String GOAL_ID = "goal-flutter-e2e-1";
  // const double GOAL_VALUE = 1.0;

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

    testWidgets('testStringVariation', (WidgetTester _) async {
      expectLater(
        Bucketeer.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_STRING_VALUE)),
        ),
      );
    });

    testWidgets('testStringVariationDetail', (WidgetTester _) async {
      var result =
          await Bucketeer.instance.evaluationDetails(FEATURE_ID_STRING);
      var expected = const BKTResult.success(
          data: BKTEvaluation(
              id: "feature-ios-e2e-string:2:bucketeer-ios-user-id-1",
              featureId: FEATURE_ID_STRING,
              featureVersion: 2,
              userId: USER_ID,
              variationId: "349ed945-d2f9-4d04-8e83-82344cffd1ec",
              variationValue: "value-1",
              reason: "DEFAULT"));
      expect(result, expected);
    });

    testWidgets('testDoubleVariation', (WidgetTester _) async {
      expectLater(
        Bucketeer.instance
            .doubleVariation(FEATURE_ID_DOUBLE, defaultValue: 100.0),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_DOUBLE_VALUE)),
        ),
      );
    });
    testWidgets('testDoubleVariationDetail', (WidgetTester _) async {
      var result =
          await Bucketeer.instance.evaluationDetails(FEATURE_ID_DOUBLE);
      var expected = const BKTResult.success(
          data: BKTEvaluation(
              id: "feature-ios-e2e-double:2:bucketeer-ios-user-id-1",
              featureId: FEATURE_ID_DOUBLE,
              featureVersion: 2,
              userId: USER_ID,
              variationId: "38078d8f-c6eb-4b93-9d58-c3e57010983f",
              variationValue: "2.1",
              reason: "DEFAULT"));
      expect(result, expected);
    });

    testWidgets('testBoolVariation', (WidgetTester _) async {
      expectLater(
        Bucketeer.instance
            .boolVariation(FEATURE_ID_BOOLEAN, defaultValue: false),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_BOOLEAN_VALUE)),
        ),
      );
    });
    testWidgets('testBoolVariationDetail', (WidgetTester _) async {
      var result =
          await Bucketeer.instance.evaluationDetails(FEATURE_ID_BOOLEAN);
      var expected = const BKTResult.success(
          data: BKTEvaluation(
              id: "feature-ios-e2e-bool:2:bucketeer-ios-user-id-1",
              featureId: FEATURE_ID_BOOLEAN,
              featureVersion: 2,
              userId: USER_ID,
              variationId: "4f9e0f88-e053-42a9-93e1-95d407f67021",
              variationValue: "true",
              reason: "DEFAULT"));
      expect(result, expected);
    });

    testWidgets('testIntVariation', (WidgetTester _) async {
      expectLater(
        Bucketeer.instance.intVariation(FEATURE_ID_INT, defaultValue: 1000),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_INT_VALUE)),
        ),
      );
    });
    testWidgets('testIntVariationDetail', (WidgetTester _) async {
      var result = await Bucketeer.instance.evaluationDetails(FEATURE_ID_INT);
      var expected = const BKTResult.success(
          data: BKTEvaluation(
              id: "feature-ios-e2e-integer:2:bucketeer-ios-user-id-1",
              featureId: FEATURE_ID_INT,
              featureVersion: 2,
              userId: USER_ID,
              variationId: "9c5fd2d2-d587-4ba2-8de2-0fc9454d564e",
              variationValue: "10",
              reason: "DEFAULT"));
      expect(result, expected);
    });

    testWidgets('testJSONVariation', (WidgetTester _) async {
      var result = await Bucketeer.instance
          .jsonVariation(FEATURE_ID_JSON, defaultValue: {});
      var expected = const BKTResult.success(data: FEATURE_ID_JSON_VALUE);
      expect(result.asSuccess.data, expected.asSuccess.data);
    });
    testWidgets('testJSONVariationDetail', (WidgetTester _) async {
      var result = await Bucketeer.instance.evaluationDetails(FEATURE_ID_JSON);
      var expected = const BKTResult.success(
          data: BKTEvaluation(
              id: "feature-ios-e2e-json:2:bucketeer-ios-user-id-1",
              featureId: FEATURE_ID_JSON,
              featureVersion: 2,
              userId: USER_ID,
              variationId: "06f5be6b-0c79-431f-a057-822babd9d3eb",
              variationValue: "{ \"key\": \"value-1\" }",
              reason: "DEFAULT"));
      expect(result, expected);
    });

    testWidgets('testTrack', (WidgetTester _) async {
      var result = await Bucketeer.instance.track(GOAL_ID, value: GOAL_VALUE);
      expect(result, const BKTResult.success(data: true));

      await Future.delayed(Duration(milliseconds: 100));
      var flushResult = await Bucketeer.instance.flush();
      expect(flushResult, const BKTResult.success(data: true));
    });

    testWidgets('testEvaluationUpdateFlow', (WidgetTester _) async {
      await expectLater(
        Bucketeer.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_STRING_VALUE)),
        ),
      );

      await expectLater(
        Bucketeer.instance.updateUserAttributes(USER_ID,
            userMap: {'app_version': OLD_APP_VERSION}),
        completion(
          equals(const BKTResult.success(data: true)),
        ),
      );

      await expectLater(
        Bucketeer.instance.fetchEvaluations(30000),
        completion(
          equals(const BKTResult.success(data: true)),
        ),
      );

      await expectLater(
        Bucketeer.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(const BKTResult.success(data: FEATURE_ID_STRING_VALUE_UPDATE)),
        ),
      );
    });


    // testWidgets('testSwitchUser', (WidgetTester _) async {
    //   var result = await Bucketeer.instance.track(GOAL_ID, value: GOAL_VALUE);
    //   expect(result, const BKTResult.success(data: true));
    //
    //   await Future.delayed(Duration(milliseconds: 100));
    //   var flushResult = await Bucketeer.instance.flush();
    //   expect(flushResult, const BKTResult.success(data: true));
    // });
  }

  group('Bucketeer', () {
    setUp(() async {
      var result = await Bucketeer.instance.initialize(
          apiKey: Constants.API_KEY,
          apiEndpoint: Constants.API_ENDPOINT,
          featureTag: FEATURE_TAG,
          userId: USER_ID,
          debugging: DEBUGGING,
          eventsFlushInterval: Constants.DEFAULT_EVENTS_FLUSH_INTERVAL,
          eventsMaxQueueSize: Constants.DEFAULT_EVENT_MAX_QUEUE_SIZE,
          pollingInterval: Constants.DEFAULT_POLLING_INTERVAL,
          backgroundPollingInterval:
              Constants.DEFAULT_BACKGROUND_POLLING_INTERVAL,
          appVersion: APP_VERSION);
      expect(result.isSuccess, true, reason: "initialize() should success");

      var fetchEvaluationsResult =
          await Bucketeer.instance.fetchEvaluations(30000);
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should success");
    });

    tearDown(() async {
      var result = await Bucketeer.instance.destroy();
      expect(result.isSuccess, true);
      expect(result, const BKTResult.success(data: true),
          reason: "destroy() should success");
    });

    runAllTests();
  });
}
