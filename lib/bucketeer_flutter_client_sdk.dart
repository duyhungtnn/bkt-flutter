library bucketeer;

export 'src/evaluation.dart';
export 'src/user.dart';
export 'src/result.dart';
export 'src/evaluation_update_listener.dart';
export 'src/config.dart';

import 'package:bucketeer_flutter_client_sdk/src/config.dart';
import 'package:flutter/services.dart';
import 'src/user.dart';
import 'src/call_methods.dart';
import 'src/constants.dart';
import 'src/evaluation.dart';
import 'src/evaluation_update_listener.dart';
import 'src/evaluation_update_listener_dispatcher.dart';
import 'src/result.dart';

/// Bucketeer Flutter SDK
class BKTClient {
  const BKTClient._();

  static const BKTClient instance = BKTClient._();

  static const MethodChannel _channel =
      MethodChannel(Constants.methodChannelName);
  static const EventChannel _eventChannel =
      EventChannel(Constants.eventChannelName);
  static final EvaluationUpdateListenerDispatcher _dispatcher =
      EvaluationUpdateListenerDispatcher(
          _eventChannel.receiveBroadcastStream());

  Future<BKTResult<void>> initialize({
    required BKTConfig config,
    required BKTUser user,
    int? timeoutMillis,
  }) async {
    var rs = await _invokeMethod(
      CallMethods.initialize.name,
      argument: {
        'apiKey': config.apiKey,
        'apiEndpoint': config.apiEndpoint,
        'featureTag': config.featureTag,
        'debugging': config.debugging,
        'eventsFlushInterval': config.eventsFlushInterval,
        'eventsMaxQueueSize': config.eventsMaxQueueSize,
        'pollingInterval': config.pollingInterval,
        'backgroundPollingInterval': config.backgroundPollingInterval,
        'appVersion': config.appVersion,
        'timeoutMillis': timeoutMillis,
        'userId': user.id,
        'userAttributes': user.data,
      },
    );
    return _resultGuard(rs);
  }

  Future<BKTResult<String>> stringVariation(
    String featureId, {
    required String defaultValue,
  }) async {
    return _resultGuard<String>(
      await _invokeMethod(
        CallMethods.stringVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    );
  }

  Future<BKTResult<int>> intVariation(
    String featureId, {
    required int defaultValue,
  }) async {
    return _resultGuard<int>(
      await _invokeMethod(
        CallMethods.intVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    );
  }

  Future<BKTResult<double>> doubleVariation(
    String featureId, {
    required double defaultValue,
  }) async {
    return _resultGuard<double>(
      await _invokeMethod(
        CallMethods.doubleVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    );
  }

  Future<BKTResult<bool>> boolVariation(
    String featureId, {
    required bool defaultValue,
  }) async {
    return _resultGuard<bool>(
      await _invokeMethod(
        CallMethods.boolVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    );
  }

  Future<BKTResult<Map<String, dynamic>>> jsonVariation(
    String featureId, {
    required Map<String, dynamic> defaultValue,
  }) async {
    return _resultGuard<Map<String, dynamic>>(
      await _invokeMethod(
        CallMethods.jsonVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
      onDataChange: (response) {
        return response;
      },
    );
  }

  Future<BKTResult<void>> track(
    String goalId, {
    double? value,
  }) async {
    return _resultGuard(
      await _invokeMethod(
        CallMethods.track.name,
        argument: {
          'goalId': goalId,
          'value': value,
        },
      ),
    );
  }

  Future<BKTResult<BKTUser>> currentUser() async {
    return _resultGuard<BKTUser>(
      await _invokeMethod(CallMethods.currentUser.name),
      onDataChange: (response) {
        return BKTUserBuilder()
            .id(response['id'])
            .data(
              Map<String, String>.from(response['data']),
            )
            .build();
      },
    );
  }

  Future<BKTResult<bool>> updateUserAttributes({
    required Map<String, String> userAttributes,
  }) async {
    return _resultGuard(
      await _invokeMethod(
        CallMethods.updateUserAttributes.name,
        argument: userAttributes,
      ),
    );
  }

  Future<BKTResult<void>> fetchEvaluations({int? timeoutMillis}) async {
    return _resultGuard(
      await _invokeMethod(
        CallMethods.fetchEvaluations.name,
        argument: {
          'timeoutMillis': timeoutMillis,
        },
      ),
    );
  }

  Future<BKTResult<void>> flush() async {
    return _resultGuard(
      await _invokeMethod(CallMethods.flush.name),
    );
  }

  Future<BKTResult<bool>> destroy() async {
    return _resultGuard(
      await _invokeMethod(CallMethods.destroy.name).then(
        (value) async {
          // Remove all listener for the current client
          clearEvaluationUpdateListeners();
          return value;
        },
      ),
    );
  }

  Future<BKTResult<BKTEvaluation>> evaluationDetails(String featureId) async {
    return _resultGuard<BKTEvaluation>(
      await _invokeMethod(CallMethods.evaluationDetails.name, argument: {
        'featureId': featureId,
      }),
      onDataChange: (response) {
        return BKTEvaluation(
          id: response['id'],
          featureId: response['featureId'],
          featureVersion: response['featureVersion'],
          userId: response['userId'],
          variationId: response['variationId'],
          variationName: response['variationName'],
          variationValue: response['variationValue'],
          reason: response['reason'],
        );
      },
    );
  }

  String addEvaluationUpdateListener(BKTEvaluationUpdateListener listener) {
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
