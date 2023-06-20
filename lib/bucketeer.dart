library bucketeer;

export 'src/evaluation.dart';
export 'src/bucketeer_user.dart';
export 'src/result.dart';

import 'dart:ffi';
import 'dart:io';
import 'package:flutter/services.dart';
import 'src/bucketeer_user.dart';
import 'src/call_methods.dart';
import 'src/evaluation.dart';
import 'src/result.dart';

/// Bucketeer Flutter SDK
class Bucketeer {
  const Bucketeer._();

  static const Bucketeer instance = Bucketeer._();

  static const MethodChannel _channel =
      MethodChannel('jp.bucketeer.plugin/flutter');

  Future<BKTResult<void>> initialize({
    required String apiKey,
    required String apiEndpoint,
    required String featureTag,
    bool debugging = false,
    int? eventsFlushInterval,
    int? eventsMaxQueueSize,
    int? pollingInterval,
    int? backgroundPollingInterval,
    String? appVersion,
  }) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.initialize.name, argument: {
        'apiKey': apiKey,
        'apiEndpoint': apiEndpoint,
        'featureTag': featureTag,
        'debugging': debugging,
        'eventsFlushInterval': eventsFlushInterval,
        'eventsMaxQueueSize': eventsMaxQueueSize,
        'pollingInterval': pollingInterval,
        'backgroundPollingInterval': backgroundPollingInterval,
        'appVersion': appVersion,
      }),
    );
  }

  Future<BKTResult<String>> stringVariation(
    String featureId, {
    String defaultValue = '',
  }) async {
    return _resultGuard<String>(
      await _invokeMethod(CallMethods.stringVariation.name, argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<BKTResult<int>> intVariation(
    String featureId, {
    int defaultValue = 0,
  }) async {
    return _resultGuard<int>(
      await _invokeMethod(CallMethods.intVariation.name, argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<BKTResult<double>> doubleVariation(
    String featureId, {
    double defaultValue = 0.0,
  }) async {
    return _resultGuard<double>(
      await _invokeMethod(CallMethods.doubleVariation.name, argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<BKTResult<bool>> boolVariation(
    String featureId, {
    bool defaultValue = false,
  }) async {
    return _resultGuard<bool>(
        await _invokeMethod(CallMethods.boolVariation.name, argument: {
      'featureId': featureId,
      'defaultValue': defaultValue,
    }));
  }

  Future<BKTResult<Map<String, dynamic>>> jsonVariation(
    String featureId, {
    Map<String, dynamic> defaultValue = const {},
  }) async {
    return _resultGuard<Map<String, dynamic>>(
        await _invokeMethod(CallMethods.jsonVariation.name, argument: {
      'featureId': featureId,
      'defaultValue': defaultValue,
    }));
  }

  Future<BKTResult<void>> track(
    String goalId, {
    double value = 0.0,
  }) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.track.name, argument: {
        'goalId': goalId,
        'value': value,
      }),
    );
  }

  Future<BKTResult<BucketeerUser>> currentUser() async {
    return _resultGuard<BucketeerUser>(
      await _invokeMethod(CallMethods.currentUser.name),
      onDataChange: (response) {
        return BucketeerUser(
          id: response['id'],
          data: Map<String, String>.from(response['data']),
        );
      },
    );
  }

  Future<BKTResult<void>> updateUserAttributes(
    String userId, {
    Map<String, String> userMap = const {},
  }) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.updateUserAttributes.name, argument: userMap),
    );
  }

  Future<BKTResult<void>> fetchEvaluations(Int64 timeoutMillis) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.fetchEvaluations.name, argument: {
        'timeoutMillis': timeoutMillis,
      }),
    );
  }

  Future<BKTResult<void>> flush() async {
    return _resultGuard(
      await _invokeMethod('flush'),
    );
  }

  Future<BKTResult<BKTEvaluation>> evaluationDetails(String featureId) async {
    return _resultGuard<BKTEvaluation>(
        await _invokeMethod(CallMethods.evaluationDetails.name, argument: {
          'featureId': featureId,
        }), onDataChange: (response) {
      return BKTEvaluation(
        id: response['id'],
        featureId: response['featureId'],
        featureVersion: response['featureVersion'],
        userId: response['userId'],
        variationId: response['variationId'],
        variationValue: response['variationValue'],
        reason: response['reason'],
      );
    });
  }

  Future<BKTResult<void>> start() async {
    // Only run on Android
    if (Platform.isIOS) return Future.value(const BKTResult.success());
    return _resultGuard(await _invokeMethod('start'));
  }

  Future<BKTResult<void>> stop() async {
    // Only run on Android
    if (Platform.isIOS) return Future.value(const BKTResult.success());
    return _resultGuard(await _invokeMethod('stop'));
  }

  BKTResult<T> _resultGuard<T>(Map<String, dynamic> result,
      {T Function(Map<String, dynamic>)? onDataChange}) {
    if (result['status']) {
      if (result['response'] != null) {
        if (onDataChange != null) {
          return BKTResult<T>.success(
            data: onDataChange(
              Map<String, dynamic>.from(result['response']),
            ),
          );
        } else {
          return BKTResult<T>.success(data: result['response']);
        }
      } else {
        return const BKTResult.success();
      }
    } else {
      return BKTResult.failure(result['errorMessage']);
    }
  }

  Future<Map<String, dynamic>> _invokeMethod(
    String method, {
    Map<String, dynamic> argument = const {},
  }) async {
    return Map<String, dynamic>.from(
      await _channel.invokeMethod(method, argument),
    );
  }
}
