package jp.bucketeer.plugin;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.bucketeer.sdk.android.BKTClient;
import io.bucketeer.sdk.android.BKTConfig;
import io.bucketeer.sdk.android.BKTEvaluation;
import io.bucketeer.sdk.android.BKTException;
import io.bucketeer.sdk.android.BKTUser;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.HashMap;
import java.util.Map;

/**
 * BucketeerPlugin
 */
public class BucketeerPlugin implements MethodCallHandler, FlutterPlugin {
  private Context applicationContext;
  private MethodChannel methodChannel;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final BucketeerPlugin instance = new BucketeerPlugin();
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    this.applicationContext = applicationContext;
    methodChannel = new MethodChannel(messenger, "jp.bucketeer.plugin/flutter");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = null;
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
  }

  @Override
  public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
    try {
      switch (call.method) {
        case "initialize": {
          Boolean debugging = safeCast(call.argument("debugging"), Boolean.class);
          String userId = safeCast(call.argument("userId"), String.class);
          String apiKey = safeCast(call.argument("apiKey"), String.class);
          String apiEndpoint = safeCast(call.argument("apiEndpoint"), String.class);
          String featureTag = safeCast(call.argument("featureTag"), String.class);
          Integer eventsFlushInterval = safeCast(call.argument("eventsFlushInterval"), Integer.class);
          Integer eventsMaxQueueSize = safeCast(call.argument("eventsMaxQueueSize"), Integer.class);
          Integer pollingInterval = safeCast(call.argument("pollingInterval"), Integer.class);
          Integer backgroundPollingInterval = safeCast(call.argument("backgroundPollingInterval"), Integer.class)

          final BKTConfig config = new BKTConfig.Builder()
            .apiKey(apiKey)
            .apiEndpoint(apiEndpoint)
            .featureTag(featureTag)
            .eventsFlushInterval(eventsFlushInterval)
            .eventsMaxQueueSize(eventsMaxQueueSize)
            .pollingInterval(pollingInterval)
            .backgroundPollingInterval(backgroundPollingInterval)
            .build();
          final BKTUser user = new BKTUser.Builder().id(userId).build();
          BKTClient.Companion.initialize(applicationContext, config, user, 5000);
          success(result);
          break;
        }

        case "currentUser": {
          assertInitialize();
          final BKTUser user = BKTClient.Companion.getInstance().currentUser();
          if (user == null) {
            fail(result, "Failed to fetch the user.");
          } else {
            Map<String, Object> map = new HashMap<>();
            map.put("id", user.getId());
            map.put("data", user.getAttributes());
            success(result, map);
          }
          break;
        }
        case "getEvaluation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);

          final BKTEvaluation evaluation = BKTClient.Companion.getInstance().evaluationDetails(featureId);
          if (evaluation == null) {
            fail(result, "Failed to fetch the evaluation.");
          } else {
            Map<String, Object> map = new HashMap<>();
            map.put("id", evaluation.getId());
            map.put("featureId", evaluation.getFeatureId());
            map.put("featureVersion", evaluation.getFeatureVersion());
            map.put("userId", evaluation.getUserId());
            map.put("variationId", evaluation.getVariationId());
            map.put("variationValue", evaluation.getVariationValue());
            map.put("reason", evaluation.getReason());
            success(result, map);
          }
          break;
        }
        case "getStringVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final String defaultValue = safeCast(args.get("defaultValue"), String.class);
          final String response = BKTClient.Companion.getInstance().stringVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getIntVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Integer defaultValue = safeCast(args.get("defaultValue"), Integer.class);
          final Integer response = BKTClient.Companion.getInstance().intVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getDoubleVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Double defaultValue = safeCast(args.get("defaultValue"), Double.class);
          final Double response = BKTClient.Companion.getInstance().doubleVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getBoolVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Boolean defaultValue = safeCast(args.get("defaultValue"), Boolean.class);
          final Boolean response = BKTClient.Companion.getInstance().booleanVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "track": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String goalId = safeCast(args.get("goalId"), String.class);
          final Double value = safeCast(args.get("value"), Double.class);
          BKTClient.Companion.getInstance().track(goalId, value);
          success(result);
          break;
        }
        default:
          result.notImplemented();
          break;
      }
    } catch (BKTException | RuntimeException e) {
      fail(result, e.getMessage());
    }
  }

  <T> T safeCast(Object o, Class<T> clazz) {
    return clazz != null && clazz.isInstance(o) ? clazz.cast(o) : null;
  }

  void assertInitialize() throws BKTException.IllegalStateException {
    if (BKTClient.Companion.getInstance() == null) {
      throw new BKTException.IllegalStateException("Required call the initialize method.");
    }
  }

  void success(Result result) {
    success(result, null);
  }

  void success(Result result, @Nullable Object response) {
    Map<String, Object> map = new HashMap<>();
    map.put("status", true);
    map.put("response", response);
    if (result != null) result.success(map);
  }

  void fail(Result result, String message) {
    Map<String, Object> map = new HashMap<>();
    map.put("status", false);
    map.put("errorMessage", message);
    if (result != null) result.success(map);
  }
}
