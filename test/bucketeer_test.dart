import 'package:flutter/services.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/call_methods.dart';
import 'package:bucketeer_flutter_client_sdk/src/constants.dart';
import 'package:bucketeer_flutter_client_sdk/src/evaluation.dart' as bucketeer;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(Constants.methodChannelName);

  setUp(() async {
    channel.setMockMethodCallHandler((methodCall) async {
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
          return {'status': true, 'response': true};
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
          break;
        case CallMethods.removeEvaluationUpdateListener:
          break;
        case CallMethods.clearEvaluationUpdateListeners:
          break;
        case CallMethods.unknown:
          break;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('Bucketeer Tests', () async {
    expectLater(
      BKTClient.instance.initialize(
          apiKey: "apikeyapikeyapikeyapikeyapikeyapikeyapikey",
          apiEndpoint: 'demo.bucketeer.jp',
          featureTag: 'Flutter',
          userId: '2023',
          debugging: true,
          eventsFlushInterval: 10000,
          eventsMaxQueueSize: 10000,
          pollingInterval: 10000,
          backgroundPollingInterval: 10000,
          appVersion: '1.0.0',
          userAttributes: {'app_version': '1.0.0'}),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.currentUser(),
      completion(
        equals(
          const BKTResult<BKTUser>.success(
            data: BKTUser(
                id: 'userId', data: {'appVersion': '9.9.9', 'platform': 'iOS'}),
          ),
        ),
      ),
    );

    expectLater(
      BKTClient.instance.stringVariation('feature-id', defaultValue: ''),
      completion(
        equals(const BKTResult.success(data: 'datadata')),
      ),
    );

    // Current equal operator of BKTResult is not supported runtime type `Map`
    // Compare 2 map if dart is not easy
    // https://stackoverflow.com/questions/61765518/how-to-check-two-maps-are-equal-in-dart
    // We will not compare 2 BKTResult, we will compare the final output
    expect(
      (await BKTClient.instance.jsonVariation('feature-id', defaultValue: {}))
          .asSuccess
          .data,
      BKTResult<Map<String, dynamic>>.success(
          data: Map<String, dynamic>.from({
        'id': 'id123',
        'featureId': 'featureId123',
        'featureVersion': 123,
        'enable': true,
      })).asSuccess.data,
    );

    expectLater(
      BKTClient.instance.intVariation('feature-id', defaultValue: 0),
      completion(
        equals(const BKTResult.success(data: 1234)),
      ),
    );

    expectLater(
        BKTClient.instance.doubleVariation('feature-id', defaultValue: 0.0),
        completion(equals(const BKTResult.success(data: 55.2))));

    expectLater(
      BKTClient.instance.boolVariation('feature-id', defaultValue: false),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.evaluationDetails('featureId'),
      completion(
        equals(
          const BKTResult.success(
              data: bucketeer.BKTEvaluation(
            id: 'id123',
            featureId: 'featureId123',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 'variationValue123',
            reason: "DEFAULT",
          )),
        ),
      ),
    );

    expectLater(
      BKTClient.instance.updateUserAttributes('user-id',
          userAttributes: {'app_version': '1.0.0'}),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.track('goal-id'),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.flush(),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.flush(),
      completion(
        equals(const BKTResult.success(data: true)),
      ),
    );

    expectLater(
      BKTClient.instance.fetchEvaluations(timeoutMillis: 10000),
      completion(
        equals(const BKTResult.success(data: true)),
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
  });
}
