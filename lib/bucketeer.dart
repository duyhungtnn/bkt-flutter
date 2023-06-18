library bucketeer;

import 'dart:io';

import 'package:flutter/services.dart';

import 'bucketeer_user.dart';
import 'evaluation.dart';
import 'result.dart';

/// Bucketeer Flutter SDK
class Bucketeer {
  const Bucketeer._();

  static const Bucketeer instance = Bucketeer._();

  static const MethodChannel _channel =
      MethodChannel('jp.bucketeer.plugin/flutter');

  Future<Result<void>> initialize({
    required String apiKey,
    required String endpoint,
    required String featureTag,
    bool debugging = false,
    int logSendingIntervalMillis = 60000,
    int logSendingMaxBatchQueueCount = 50,
    int pollingEvaluationIntervalMillis = 600000,
  }) async {
    return _resultGuard(
      await _invokeMethod('initialize', argument: {
        'apiKey': apiKey,
        'endpoint': endpoint,
        'featureTag': featureTag,
        'debugging': debugging,
        'logSendingIntervalMillis': logSendingIntervalMillis,
        'logSendingMaxBatchQueueCount': logSendingMaxBatchQueueCount,
        'pollingEvaluationIntervalMillis': pollingEvaluationIntervalMillis,
      }),
    );
  }

  Future<Result<void>> setUser(
    String userId, {
    Map<String, String> userMap = const {},
  }) async {
    return _resultGuard(
      await _invokeMethod('setUser', argument: {
        'userId': userId,
        ...userMap,
      }),
    );
  }

  Future<Result<BucketeerUser>> getUser() async {
    return _resultGuard<BucketeerUser>(
      await _invokeMethod('getUser'),
      onDataChange: (response) {
        return BucketeerUser(
          id: response['id'],
          data: Map<String, String>.from(response['data']),
        );
      },
    );
  }

  Future<Result<Evaluation>> getEvaluation(String featureId) async {
    return _resultGuard<Evaluation>(
        await _invokeMethod('getEvaluation', argument: {
          'featureId': featureId,
        }), onDataChange: (response) {
      return Evaluation(
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

  Future<Result<String>> getStringVariation(
    String featureId, {
    String defaultValue = '',
  }) async {
    return _resultGuard<String>(
      await _invokeMethod('getStringVariation', argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<Result<int>> getIntVariation(
    String featureId, {
    int defaultValue = 0,
  }) async {
    return _resultGuard<int>(
      await _invokeMethod('getIntVariation', argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<Result<double>> getDoubleVariation(
    String featureId, {
    double defaultValue = 0.0,
  }) async {
    return _resultGuard<double>(
      await _invokeMethod('getDoubleVariation', argument: {
        'featureId': featureId,
        'defaultValue': defaultValue,
      }),
    );
  }

  Future<Result<bool>> getBoolVariation(
    String featureId, {
    bool defaultValue = false,
  }) async {
    return _resultGuard<bool>(
        await _invokeMethod('getBoolVariation', argument: {
      'featureId': featureId,
      'defaultValue': defaultValue,
    }));
  }

  Future<Result<void>> track(
    String goalId, {
    double value = 0.0,
  }) async {
    return _resultGuard(
      await _invokeMethod('track', argument: {
        'goalId': goalId,
        'value': value,
      }),
    );
  }

  Future<Result<void>> start() async {
    // Only run on Android
    if (Platform.isIOS) return Future.value(const Result.success());
    return _resultGuard(await _invokeMethod('start'));
  }

  Future<Result<void>> stop() async {
    // Only run on Android
    if (Platform.isIOS) return Future.value(const Result.success());
    return _resultGuard(await _invokeMethod('stop'));
  }

  Result<T> _resultGuard<T>(Map<String, dynamic> result,
      {T Function(Map<String, dynamic>)? onDataChange}) {
    if (result['status']) {
      if (result['response'] != null) {
        if (onDataChange != null) {
          return Result<T>.success(
            data: onDataChange(
              Map<String, dynamic>.from(result['response']),
            ),
          );
        } else {
          return Result<T>.success(data: result['response']);
        }
      } else {
        return const Result.success();
      }
    } else {
      return Result.failure(result['errorMessage']);
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
