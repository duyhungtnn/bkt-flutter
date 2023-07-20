import 'package:bucketeer_example/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:mocktail/mocktail.dart';

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String appVersion = "1.2.3";
  const String oldAppVersion = "0.0.1";
  const bool debugging = true;

  // E2E Flutter
  const String featureTag = "flutter";
  const String userId = 'bucketeer-flutter-user-id-1';

  const String featureIdBoolean = "feature-flutter-e2e-boolean";
  const bool featureIdBooleanValue = true;

  const String featureIdString = "feature-flutter-e2e-string";
  const String featureIdStringValue = "value-1";
  const String featureIdStringValueUpdate = "value-2";

  const String featureIdInt = "feature-flutter-e2e-int";
  const int featureIdIntValue = 10;

  const String featureIdDouble = "feature-flutter-e2e-double";
  const double featureIdDoubleValue = 2.1;

  const String featureIdJson = " eature-flutter-e2e-json";
  const Map<String, dynamic> featureIdJsonValue = {"key": "value-1"};

  const String goalId = "goal-flutter-e2e-1";
  const double goalValue = 1.0;

  final listener = MockEvaluationUpdateListener();

  void runAllTests() {
    testWidgets('testStringVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.stringVariation(featureIdString, defaultValue: "hh"),
        completion(
          equals(featureIdStringValue),
        ),
      );
    });

    testWidgets('testStringVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdString);
      var expected = const BKTEvaluation(
          id: "$featureIdString:4:$userId",
          featureId: featureIdString,
          featureVersion: 4,
          userId: userId,
          variationId: "2e696c59-ac2f-4b54-82a7-4aecfdd80224",
          variationName: "variation 1",
          variationValue: "value-1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testDoubleVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .doubleVariation(featureIdDouble, defaultValue: 100.0),
        completion(
          equals(featureIdDoubleValue),
        ),
      );
    });
    testWidgets('testDoubleVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdDouble);
      var expected = const BKTEvaluation(
          id: "$featureIdDouble:3:$userId",
          featureId: featureIdDouble,
          featureVersion: 3,
          userId: userId,
          variationId: "a141d1fa-85ef-4124-af5e-25374225474b",
          variationName: "variation 2.1",
          variationValue: "2.1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testBoolVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.boolVariation(featureIdBoolean, defaultValue: false),
        completion(
          equals(featureIdBooleanValue),
        ),
      );
    });
    testWidgets('testBoolVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdBoolean);
      var expected = const BKTEvaluation(
          id: "$featureIdBoolean:3:$userId",
          featureId: featureIdBoolean,
          featureVersion: 3,
          userId: userId,
          variationId: "cbd42331-094e-4306-aacd-d7bf3f07cf65",
          variationName: "variation true",
          variationValue: "true",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testIntVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.intVariation(featureIdInt, defaultValue: 1000),
        completion(
          equals(featureIdIntValue),
        ),
      );
    });
    testWidgets('testIntVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdInt);
      var expected = const BKTEvaluation(
          id: "$featureIdInt:3:$userId",
          featureId: featureIdInt,
          featureVersion: 3,
          userId: userId,
          variationId: "36f14c02-300a-48f3-b4eb-b296afba3953",
          variationName: "variation 10",
          variationValue: "10",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testJSONVariation', (WidgetTester _) async {
      var result = await BKTClient.instance
          .jsonVariation(featureIdJson, defaultValue: {});
      expect(result, featureIdJsonValue);
    });
    testWidgets('testJSONVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdJson);
      var expected = const BKTEvaluation(
          id: "$featureIdJson:3:$userId",
          featureId: featureIdJson,
          featureVersion: 3,
          userId: userId,
          variationId: "813070cf-7d6b-45a9-8713-cf9816d63997",
          variationName: "variation 1",
          variationValue: "{ \"key\": \"value-1\" }",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testTrack', (WidgetTester _) async {
      await BKTClient.instance.track(goalId, value: goalValue).onError(
          (error, stackTrace) =>
              fail("BKTClient.instance.track should success"));

      var flushResult = await BKTClient.instance.flush();
      expect(flushResult, const BKTResult.success());
    });

    testWidgets('testEvaluationUpdateFlow', (WidgetTester _) async {
      await expectLater(
        BKTClient.instance.stringVariation(featureIdString, defaultValue: "hh"),
        completion(
          equals(featureIdStringValue),
        ),
      );

      await BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': oldAppVersion},
      ).onError(
        (error, stackTrace) => fail(
            "BKTClient.instance.updateUserAttributes should success and should not throw exception"),
      );

      await expectLater(
        BKTClient.instance.fetchEvaluations(timeoutMillis: 30000),
        completion(
          equals(const BKTResult.success()),
        ),
      );

      await expectLater(
        BKTClient.instance.stringVariation(featureIdString, defaultValue: "hh"),
        completion(
          equals(featureIdStringValueUpdate),
        ),
      );
    });

    testWidgets('testSwitchUser', (WidgetTester _) async {
      await BKTClient.instance.destroy().onError((error, stackTrace) => fail(
          "BKTClient.instance.destroy should success and should not throw exception"));
      final config = BKTConfigBuilder()
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .featureTag(featureTag)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(
              Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      final user = BKTUserBuilder().id("test_id").data({}).build();

      var instanceResult = await BKTClient.initialize(
        config: config,
        user: user,
      );
      expect(instanceResult.isSuccess, true,
          reason: "initialize() should success");

      await BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': appVersion},
      ).onError(
        (error, stackTrace) => fail(
            "BKTClient.instance.updateUserAttributes should success and should not throw exception"),
      );

      var currentUser = await BKTClient.instance.currentUser();
      expect(currentUser != null, true,
          reason:
              "BKTClient.instance.currentUser() should return non-null user data");
      expect(currentUser!.id, "test_id", reason: "user_id should be `test_id`");
      expect(currentUser.data, {'app_version': appVersion},
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
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .featureTag(featureTag)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(
              Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      final user = BKTUserBuilder().id(userId).data({}).build();

      var result = await BKTClient.initialize(
        config: config,
        user: user,
      );
      expect(result.isSuccess, true, reason: "initialize() should success");

      BKTClient.instance.addEvaluationUpdateListener(listener);

      await BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': appVersion},
      ).onError((error, stackTrace) => fail(
          "BKTClient.instance.updateUserAttributes should success and should not throw exception"));

      var fetchEvaluationsResult =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 30000);
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should success");
    });

    tearDown(() async {
      await BKTClient.instance.destroy().onError((error, stackTrace) => fail(
          "BKTClient.instance.destroy should success and should not throw exception"));
    });

    tearDownAll(() async {
      // listener should be called from the native side
      final onUpdateCallCount = verify(() => listener.onUpdate()).callCount;
      expect(onUpdateCallCount > 0, true);
      debugPrint("All tests passed");
    });

    runAllTests();
  });
}
