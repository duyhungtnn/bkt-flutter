library bucketeer;

export 'src/evaluation.dart';
export 'src/bucketeer_user.dart';
export 'src/result.dart';
export 'src/evaluation_update_listener.dart';

import 'package:flutter/services.dart';
import 'src/bucketeer_user.dart';
import 'src/call_methods.dart';
import 'src/constants.dart';
import 'src/evaluation.dart';
import 'src/evaluation_update_listener.dart';
import 'src/evaluation_update_listener_dispatcher.dart';
import 'src/result.dart';

/// Bucketeer Flutter SDK
class Bucketeer {
  const Bucketeer._();

  static const Bucketeer instance = Bucketeer._();

  static const MethodChannel _channel =
      MethodChannel(Constants.methodChannelName);
  static const EventChannel _eventChannel =
      EventChannel(Constants.eventChannelName);
  static final EvaluationUpdateListenerDispatcher _dispatcher =
      EvaluationUpdateListenerDispatcher(
          _eventChannel.receiveBroadcastStream());

  Future<BKTResult<void>> initialize({
    required String apiKey,
    required String apiEndpoint,
    required String featureTag,
    required String userId,
    required String appVersion,
    bool debugging = false,
    int? eventsFlushInterval,
    int? eventsMaxQueueSize,
    int? pollingInterval,
    int? backgroundPollingInterval,
    int? timeoutMillis,
    Map<String, String>? userAttributes,
  }) async {
    var rs = await _invokeMethod(CallMethods.initialize.name, argument: {
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
      'featureTag': featureTag,
      'userId': userId,
      'debugging': debugging,
      'eventsFlushInterval': eventsFlushInterval,
      'eventsMaxQueueSize': eventsMaxQueueSize,
      'pollingInterval': pollingInterval,
      'backgroundPollingInterval': backgroundPollingInterval,
      'appVersion': appVersion,
      'timeoutMillis': timeoutMillis,
      'userAttributes': userAttributes,
    });
    return _resultGuard(rs);
  }

  Future<BKTResult<String>> stringVariation(
    String featureId, {
    required String defaultValue,
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
    required int defaultValue,
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
    required double defaultValue,
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
    required bool defaultValue,
  }) async {
    return _resultGuard<bool>(
        await _invokeMethod(CallMethods.boolVariation.name, argument: {
      'featureId': featureId,
      'defaultValue': defaultValue,
    }));
  }

  Future<BKTResult<Map<String, dynamic>>> jsonVariation(
    String featureId, {
    required Map<String, dynamic> defaultValue,
  }) async {
    return _resultGuard<Map<String, dynamic>>(
        await _invokeMethod(CallMethods.jsonVariation.name, argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        }), onDataChange: (response) {
      return response;
    });
  }

  Future<BKTResult<void>> track(
    String goalId, {
    double? value,
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

  Future<BKTResult<bool>> updateUserAttributes(
    String userId, {
    required Map<String, String> userAttributes,
  }) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.updateUserAttributes.name,
          argument: userAttributes),
    );
  }

  Future<BKTResult<void>> fetchEvaluations({int? timeoutMillis}) async {
    return _resultGuard(
      await _invokeMethod(CallMethods.fetchEvaluations.name, argument: {
        'timeoutMillis': timeoutMillis,
      }),
    );
  }

  Future<BKTResult<void>> flush() async {
    return _resultGuard(
      await _invokeMethod(CallMethods.flush.name),
    );
  }

  Future<BKTResult<bool>> destroy() async {
    return _resultGuard(
        await _invokeMethod(CallMethods.destroy.name).then((value) async {
      // Remove all listener for the current client
      clearEvaluationUpdateListeners();
      // Wait 100ms after destroy, temp work around with iOS destroy problem is not run in Main Thread

      return await Future.delayed(const Duration(milliseconds: 100), () {
        return value;
      });
      // return value;
    }));
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

  String addEvaluationUpdateListener(EvaluationUpdateListener listener) {
    return _dispatcher.addEvaluationUpdateListener(listener);
  }

  void removeEvaluationUpdateListener(String key) {
    _dispatcher.removeEvaluationUpdateListener(key);
  }

  void clearEvaluationUpdateListeners() {
    _dispatcher.clearEvaluationUpdateListeners();
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
      await _channel.invokeMapMethod(method, argument) ?? {},
    );
  }
}
