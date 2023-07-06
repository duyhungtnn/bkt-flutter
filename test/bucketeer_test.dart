import 'package:flutter/services.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/call_methods.dart';
import 'package:bucketeer_flutter_client_sdk/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(Constants.methodChannelName);
  var enableMockRuntimeError = false;
  var enableMockGetEvaluationDetailsNotFound = false;

  setUp(() async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      if (enableMockRuntimeError) {
        throw Exception("test runtime error");
      }
      var callMethod = CallMethods.values.firstWhere(
          (element) => element.name == methodCall.method,
          orElse: () => CallMethods.unknown);
      switch (callMethod) {
        case CallMethods.initialize:
        case CallMethods.updateUserAttributes:
        case CallMethods.track:
        case CallMethods.flush:
        case CallMethods.fetchEvaluations:
        case CallMethods.destroy:
          return {'status': true};
        case CallMethods.currentUser:
          return {
            'status': true,
            'response': {
              'id': 'userId',
              'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
            }
          };
        case CallMethods.stringVariation:
          return {'status': true, 'response': 'datadata'};
        case CallMethods.intVariation:
          return {'status': true, 'response': 1234};
        case CallMethods.doubleVariation:
          return {'status': true, 'response': 55.2};
        case CallMethods.boolVariation:
          return {'status': true, 'response': true};
        case CallMethods.evaluationDetails:
          if (enableMockGetEvaluationDetailsNotFound) {
            return {'status': true, 'errorMessage': 'Feature flag not found.'};
          }
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': 'variationValue123',
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.jsonVariation:
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'enable': true,
            }
          };
        case CallMethods.addEvaluationUpdateListener:
        case CallMethods.removeEvaluationUpdateListener:
        case CallMethods.clearEvaluationUpdateListeners:
        case CallMethods.unknown:
          return null;
      }
    });
  });

  tearDown(() {});

  test('Bucketeer Tests', () async {
    final config = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.jp")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000)
        .appVersion("1.0.0")
        .build();
    final user =
        BKTUserBuilder().id("2023").data({'app_version': '1.0.0'}).build();

    expectLater(
      BKTClient.instance.initialize(
        config: config,
        user: user,
      ),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.currentUser(),
      completion(
        equals(
          BKTResult<BKTUser>.success(
            data: BKTUserBuilder().id('userId').data(
              {
                'appVersion': '9.9.9',
                'platform': 'iOS',
              },
            ).build(),
          ),
        ),
      ),
    );

    expectLater(
      BKTClient.instance.stringVariation('feature-id', defaultValue: ''),
      completion(
        equals('datadata'),
      ),
    );

    // Current equal operator of BKTResult is not supported runtime type `Map`
    // Compare 2 map if dart is not easy
    // https://stackoverflow.com/questions/61765518/how-to-check-two-maps-are-equal-in-dart
    // We will not compare 2 BKTResult, we will compare the final output
    expect(
      (await BKTClient.instance.jsonVariation('feature-id', defaultValue: {})),
      Map<String, dynamic>.from(
        {
          'id': 'id123',
          'featureId': 'featureId123',
          'featureVersion': 123,
          'enable': true,
        },
      ),
    );

    expectLater(
      BKTClient.instance.intVariation('feature-id', defaultValue: 0),
      completion(
        equals(1234),
      ),
    );

    expectLater(
      BKTClient.instance.doubleVariation('feature-id', defaultValue: 0.0),
      completion(
        equals(55.2),
      ),
    );

    expectLater(
      BKTClient.instance.boolVariation('feature-id', defaultValue: false),
      completion(
        equals(true),
      ),
    );

    expectLater(
      BKTClient.instance.evaluationDetails('featureId'),
      completion(
        equals(
          const BKTEvaluation(
            id: 'id123',
            featureId: 'featureId123',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 'variationValue123',
            reason: "DEFAULT",
          ),
        ),
      ),
    );

    expectLater(
      BKTClient.instance.updateUserAttributes(
        userAttributes: {'app_version': '1.0.0'},
      ),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.track('goal-id'),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.flush(),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.flush(),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.fetchEvaluations(timeoutMillis: 10000),
      completion(
        equals(const BKTResult.success()),
      ),
    );
    const success = BKTResult.success(data: 'Success');
    expect(success.isSuccess, equals(true));
    expect(success.isFailure, equals(false));
    expect(success.asSuccess.data, equals('Success'));

    final failure = BKTResult.failure('Failed');
    expect(failure.isFailure, equals(true));
    expect(failure.isSuccess, equals(false));
    expect(failure.asFailure.message, equals('Failed'));

    /// Test runtime error
    enableMockRuntimeError = true;
    final fetchEvaluationsFailRs =
        await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
    expect(fetchEvaluationsFailRs.isFailure, equals(true));

    final flushFailRs = await BKTClient.instance.flush();
    expect(flushFailRs.isFailure, equals(true));

    final trackFailRs = await BKTClient.instance.track('goal-id');
    expect(trackFailRs.isFailure, equals(true));

    var evaluationDetailsRs =
        await BKTClient.instance.evaluationDetails("not_found_featureId");
    expect(evaluationDetailsRs == null, equals(true));

    /// Should return the default value 200.0 when catching an error
    expectLater(
      BKTClient.instance.stringVariation('feature-id', defaultValue: 'bkt'),
      completion(
        equals('bkt'),
      ),
    );

    expect(
      (await BKTClient.instance.jsonVariation(
        'feature-id',
        defaultValue: {'value': 'default'},
      )),
      {'value': 'default'},
    );

    expectLater(
      BKTClient.instance.intVariation('feature-id', defaultValue: 90),
      completion(
        equals(90),
      ),
    );

    expectLater(
      BKTClient.instance.doubleVariation('feature-id', defaultValue: 110.0),
      completion(
        equals(110.0),
      ),
    );

    expectLater(
      BKTClient.instance.boolVariation('feature-id', defaultValue: false),
      completion(
        equals(false),
      ),
    );

    enableMockGetEvaluationDetailsNotFound = true;

    /// Should return the null when catching an error
    evaluationDetailsRs =
        await BKTClient.instance.evaluationDetails("not_found_featureId");
    expect(evaluationDetailsRs == null, equals(true));
  });
}
