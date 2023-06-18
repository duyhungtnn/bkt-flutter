import 'package:flutter/services.dart';
import 'package:flutter_bucketeer/bucketeer.dart';
import 'package:flutter_bucketeer/bucketeer_user.dart';
import 'package:flutter_bucketeer/evaluation.dart' as bucketeer;
import 'package:flutter_bucketeer/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('jp.bucketeer.plugin/flutter');

  setUp(() async {
    channel.setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
        case 'start':
        case 'stop':
        case 'setUser':
        case 'track':
          return {'status': true};
        case 'getUser':
          return {
            'status': true,
            'response': {
              'id': 'userId',
              'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
            }
          };
        case 'getStringVariation':
          return {'status': true, 'response': 'datadata'};
        case 'getIntVariation':
          return {'status': true, 'response': 1234};
        case 'getDoubleVariation':
          return {'status': true, 'response': 55.2};
        case 'getBoolVariation':
          return {'status': true, 'response': true};
        case 'getEvaluation':
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationValue': 'variationValue123',
              'reason': 3,
            }
          };
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('Bucketeer Tests', () async {
    expectLater(
      Bucketeer.instance.initialize(
        apiKey: "apikeyapikeyapikeyapikeyapikeyapikeyapikey",
        endpoint: 'demo.bucketeer.jp',
        featureTag: 'Flutter',
        debugging: true,
        logSendingIntervalMillis: 3000,
        logSendingMaxBatchQueueCount: 3,
        pollingEvaluationIntervalMillis: 3000,
      ),
      completion(equals(Result.success())),
    );

    expectLater(
      Bucketeer.instance.start(),
      completion(
        equals(Result.success()),
      ),
    );

    expectLater(
      Bucketeer.instance.stop(),
      completion(equals(Result.success())),
    );

    expectLater(
      Bucketeer.instance.getUser(),
      completion(
        equals(
          Result<BucketeerUser>.success(
            data: BucketeerUser(
                id: 'userId', data: {'appVersion': '9.9.9', 'platform': 'iOS'}),
          ),
        ),
      ),
    );

    expectLater(
      Bucketeer.instance.getStringVariation('feature-id'),
      completion(
        equals(Result.success(data: 'datadata')),
      ),
    );

    expectLater(
      Bucketeer.instance.getIntVariation('feature-id'),
      completion(
        equals(Result.success(data: 1234)),
      ),
    );

    expectLater(Bucketeer.instance.getDoubleVariation('feature-id'),
        completion(equals(Result.success(data: 55.2))));

    expectLater(
      Bucketeer.instance.getBoolVariation('feature-id'),
      completion(
        equals(Result.success(data: true)),
      ),
    );

    expectLater(
      Bucketeer.instance.getEvaluation('featureId'),
      completion(
        equals(
          Result.success(
              data: bucketeer.Evaluation(
            id: 'id123',
            featureId: 'featureId123',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationValue: 'variationValue123',
            reason: 3,
          )),
        ),
      ),
    );

    expectLater(
      Bucketeer.instance.track('goal-id'),
      completion(
        equals(Result.success()),
      ),
    );

    final success = Result.success(data: 'Success');
    expect(success.isSuccess, equals(true));
    expect(success.isFailure, equals(false));
    expect(success.asSuccess.data, equals('Success'));

    final failure = Result.failure('Failed');
    expect(failure.isFailure, equals(true));
    expect(failure.isSuccess, equals(false));
    expect(failure.asFailure.message, equals('Failed'));
  });
}
