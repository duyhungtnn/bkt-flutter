import 'package:bucketeer_example/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:mocktail/mocktail.dart';

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String APP_VERSION = "1.2.3";
  const String OLD_APP_VERSION = "0.0.1";
  const bool DEBUGGING = true;

  // E2E Flutter
  const String FEATURE_TAG = "flutter";
  const String USER_ID = 'bucketeer-flutter-user-id-1';

  const String FEATURE_ID_BOOLEAN = "feature-flutter-e2e-boolean";
  const bool FEATURE_ID_BOOLEAN_VALUE = true;

  const String FEATURE_ID_STRING = "feature-flutter-e2e-string";
  const String FEATURE_ID_STRING_VALUE = "value-1";
  const String FEATURE_ID_STRING_VALUE_UPDATE = "value-2";

  const String FEATURE_ID_INT = "feature-flutter-e2e-int";
  const int FEATURE_ID_INT_VALUE = 10;

  const String FEATURE_ID_DOUBLE = "feature-flutter-e2e-double";
  const double FEATURE_ID_DOUBLE_VALUE = 2.1;

  const String FEATURE_ID_JSON = "feature-flutter-e2e-json";
  const Map<String, dynamic> FEATURE_ID_JSON_VALUE = {"key": "value-1"};

  const String GOAL_ID = "goal-flutter-e2e-1";
  const double GOAL_VALUE = 1.0;

  final listener = MockEvaluationUpdateListener();

  void runAllTests() {
    testWidgets('testStringVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(FEATURE_ID_STRING_VALUE),
        ),
      );
    });

    testWidgets('testStringVariationDetail', (WidgetTester _) async {
      var result =
          await BKTClient.instance.evaluationDetails(FEATURE_ID_STRING);
      var expected = const BKTEvaluation(
          id: "$FEATURE_ID_STRING:4:$USER_ID",
          featureId: FEATURE_ID_STRING,
          featureVersion: 4,
          userId: USER_ID,
          variationId: "2e696c59-ac2f-4b54-82a7-4aecfdd80224",
          variationName: "variation 1",
          variationValue: "value-1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testDoubleVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .doubleVariation(FEATURE_ID_DOUBLE, defaultValue: 100.0),
        completion(
          equals(FEATURE_ID_DOUBLE_VALUE),
        ),
      );
    });
    testWidgets('testDoubleVariationDetail', (WidgetTester _) async {
      var result =
          await BKTClient.instance.evaluationDetails(FEATURE_ID_DOUBLE);
      var expected = const BKTEvaluation(
          id: "$FEATURE_ID_DOUBLE:3:$USER_ID",
          featureId: FEATURE_ID_DOUBLE,
          featureVersion: 3,
          userId: USER_ID,
          variationId: "a141d1fa-85ef-4124-af5e-25374225474b",
          variationName: "variation 2.1",
          variationValue: "2.1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testBoolVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .boolVariation(FEATURE_ID_BOOLEAN, defaultValue: false),
        completion(
          equals(FEATURE_ID_BOOLEAN_VALUE),
        ),
      );
    });
    testWidgets('testBoolVariationDetail', (WidgetTester _) async {
      var result =
          await BKTClient.instance.evaluationDetails(FEATURE_ID_BOOLEAN);
      var expected = const BKTEvaluation(
          id: "$FEATURE_ID_BOOLEAN:3:$USER_ID",
          featureId: FEATURE_ID_BOOLEAN,
          featureVersion: 3,
          userId: USER_ID,
          variationId: "cbd42331-094e-4306-aacd-d7bf3f07cf65",
          variationName: "variation true",
          variationValue: "true",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testIntVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.intVariation(FEATURE_ID_INT, defaultValue: 1000),
        completion(
          equals(FEATURE_ID_INT_VALUE),
        ),
      );
    });
    testWidgets('testIntVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(FEATURE_ID_INT);
      var expected = const BKTEvaluation(
          id: "$FEATURE_ID_INT:3:$USER_ID",
          featureId: FEATURE_ID_INT,
          featureVersion: 3,
          userId: USER_ID,
          variationId: "36f14c02-300a-48f3-b4eb-b296afba3953",
          variationName: "variation 10",
          variationValue: "10",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testJSONVariation', (WidgetTester _) async {
      var result = await BKTClient.instance
          .jsonVariation(FEATURE_ID_JSON, defaultValue: {});
      expect(result, FEATURE_ID_JSON_VALUE);
    });
    testWidgets('testJSONVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(FEATURE_ID_JSON);
      var expected = const BKTEvaluation(
          id: "$FEATURE_ID_JSON:3:$USER_ID",
          featureId: FEATURE_ID_JSON,
          featureVersion: 3,
          userId: USER_ID,
          variationId: "813070cf-7d6b-45a9-8713-cf9816d63997",
          variationName: "variation 1",
          variationValue: "{ \"key\": \"value-1\" }",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testTrack', (WidgetTester _) async {
      var result = await BKTClient.instance.track(GOAL_ID, value: GOAL_VALUE);
      expect(result, const BKTResult.success(data: true));

      await Future.delayed(Duration(milliseconds: 100));
      var flushResult = await BKTClient.instance.flush();
      expect(flushResult, const BKTResult.success(data: true));
    });

    testWidgets('testEvaluationUpdateFlow', (WidgetTester _) async {
      await expectLater(
        BKTClient.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(FEATURE_ID_STRING_VALUE),
        ),
      );

      await expectLater(
        BKTClient.instance.updateUserAttributes(
          userAttributes: {'app_version': OLD_APP_VERSION},
        ),
        completion(
          equals(const BKTResult.success(data: true)),
        ),
      );

      await expectLater(
        BKTClient.instance.fetchEvaluations(timeoutMillis: 30000),
        completion(
          equals(const BKTResult.success(data: true)),
        ),
      );

      await expectLater(
        BKTClient.instance
            .stringVariation(FEATURE_ID_STRING, defaultValue: "hh"),
        completion(
          equals(FEATURE_ID_STRING_VALUE_UPDATE),
        ),
      );
    });

    testWidgets('testSwitchUser', (WidgetTester _) async {
      var result = await BKTClient.instance.destroy();
      expect(result.isSuccess, true);
      expect(result, const BKTResult.success(data: true),
          reason: "destroy() should success");
      final config = BKTConfigBuilder()
          .apiKey(Constants.API_KEY)
          .apiEndpoint(Constants.API_ENDPOINT)
          .featureTag(FEATURE_TAG)
          .debugging(DEBUGGING)
          .eventsMaxQueueSize(Constants.EXAMPLE_EVENT_MAX_QUEUE_SIZE)
          .eventsFlushInterval(Constants.EXAMPLE_EVENTS_FLUSH_INTERVAL)
          .pollingInterval(Constants.EXAMPLE_POLLING_INTERVAL)
          .backgroundPollingInterval(
              Constants.EXAMPLE_BACKGROUND_POLLING_INTERVAL)
          .appVersion(APP_VERSION)
          .build();
      final user = BKTUserBuilder().id("test_id").data({}).build();

      var instanceResult = await BKTClient.instance.initialize(
        config: config,
        user: user,
      );
      expect(instanceResult.isSuccess, true,
          reason: "initialize() should success");

      var updateUserInfoRs = await BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': APP_VERSION},
      );
      expect(updateUserInfoRs.isSuccess, true,
          reason: "updateUserAttributes() should success");

      var currentUser = await BKTClient.instance.currentUser();
      expect(currentUser.asSuccess.data.id, "test_id",
          reason: "user_id should be `test_id`");
      expect(currentUser.asSuccess.data.data, {'app_version': APP_VERSION},
          reason: "user_data should match");

      var fetchEvaluationsResult =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 30000);
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should success");
    });
  }

  group('Bucketeer', () {
    setUp(() async {
      final config = BKTConfigBuilder()
          .apiKey(Constants.API_KEY)
          .apiEndpoint(Constants.API_ENDPOINT)
          .featureTag(FEATURE_TAG)
          .debugging(DEBUGGING)
          .eventsMaxQueueSize(Constants.EXAMPLE_EVENT_MAX_QUEUE_SIZE)
          .eventsFlushInterval(Constants.EXAMPLE_EVENTS_FLUSH_INTERVAL)
          .pollingInterval(Constants.EXAMPLE_POLLING_INTERVAL)
          .backgroundPollingInterval(
              Constants.EXAMPLE_BACKGROUND_POLLING_INTERVAL)
          .appVersion(APP_VERSION)
          .build();
      final user = BKTUserBuilder().id(USER_ID).data({}).build();

      var result = await BKTClient.instance.initialize(
        config: config,
        user: user,
      );
      expect(result.isSuccess, true, reason: "initialize() should success");

      BKTClient.instance.addEvaluationUpdateListener(listener);

      var updateUserInfoRs = await BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': APP_VERSION},
      );
      expect(updateUserInfoRs.isSuccess, true,
          reason: "updateUserAttributes() should success");

      var fetchEvaluationsResult =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 30000);
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should success");
    });

    tearDown(() async {
      var result = await BKTClient.instance.destroy();
      expect(result.isSuccess, true);
      expect(result, const BKTResult.success(data: true),
          reason: "destroy() should success");
    });

    tearDownAll(() async {
      // listener should be called from the native side
      final onUpdateCallCount = verify(() => listener.onUpdate()).callCount;
      expect(onUpdateCallCount > 0, true);
      print("All tests passed");
    });

    runAllTests();
  });
}
