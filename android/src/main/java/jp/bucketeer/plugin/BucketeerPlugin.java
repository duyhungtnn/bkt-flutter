package jp.bucketeer.plugin;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import jp.bucketeer.sdk.Bucketeer;
import jp.bucketeer.sdk.Evaluation;
import jp.bucketeer.sdk.User;
import jp.bucketeer.sdk.BucketeerConfig;
import jp.bucketeer.sdk.BucketeerException;

import java.util.HashMap;
import java.util.Map;

/**
 * BucketeerPlugin
 */
public class BucketeerPlugin implements MethodCallHandler, FlutterPlugin {
  private Context applicationContext;
  private MethodChannel methodChannel;
  private Bucketeer bucketeer;

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
          final BucketeerConfig config = new BucketeerConfig.Builder()
            .logSendingIntervalMillis(safeCast(call.argument("logSendingIntervalMillis"), Integer.class))
            .logSendingMaxBatchQueueCount(safeCast(call.argument("logSendingMaxBatchQueueCount"), Integer.class))
            .pollingEvaluationIntervalMillis(safeCast(call.argument("pollingEvaluationIntervalMillis"), Integer.class))
            .build();

          bucketeer = new Bucketeer.Builder(applicationContext)
            .config(config)
            .apiKey(safeCast(call.argument("apiKey"), String.class))
            .endpoint(safeCast(call.argument("endpoint"), String.class))
            .featureTag(safeCast(call.argument("featureTag"), String.class))
            .logcatLogging(safeCast(call.argument("debugging"), Boolean.class))
            .build();
          success(result);
          break;
        }
        case "setUser": {
          assertInitialize();
          final Map<String, String> args = call.arguments();
          final String userId = args.get("userId");
          args.remove("userId");

          if (userId == null) {
            fail(result, "The userId is null.");
            break;
          }

          if (args.isEmpty()) {
            bucketeer.setUser(userId);
          } else {
            bucketeer.setUser(userId, args);
          }

          bucketeer.fetchUserEvaluations(new Bucketeer.FetchUserEvaluationsCallback() {
            final Result r = result;
            @Override
            public void onError(@NonNull BucketeerException e) {
              fail(r, "Failed to fetch the user.");
            }

            @Override
            public void onSuccess() {
              success(r);
            }
          });
          break;
        }
        case "getUser": {
          assertInitialize();
          final User user = bucketeer.getUser();
          if (user == null) {
            fail(result, "Failed to fetch the user.");
          } else {
            Map<String, Object> map = new HashMap<>();
            map.put("id", user.getId());
            map.put("data", user.getData());
            success(result, map);
          }
          break;
        }
        case "getEvaluation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);

          final Evaluation evaluation = bucketeer.getEvaluation(featureId);
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
          final String response = bucketeer.getVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getIntVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Integer defaultValue = safeCast(args.get("defaultValue"), Integer.class);
          final Integer response = bucketeer.getVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getDoubleVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Double defaultValue = safeCast(args.get("defaultValue"), Double.class);
          final Double response = bucketeer.getVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "getBoolVariation": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String featureId = safeCast(args.get("featureId"), String.class);
          final Boolean defaultValue = safeCast(args.get("defaultValue"), Boolean.class);
          final Boolean response = bucketeer.getVariation(featureId, defaultValue);
          success(result, response);
          break;
        }
        case "track": {
          assertInitialize();
          final Map<String, Object> args = call.arguments();
          final String goalId = safeCast(args.get("goalId"), String.class);
          final Double value = safeCast(args.get("value"), Double.class);
          bucketeer.track(goalId, value);
          success(result);
          break;
        }
        case "start":
          assertInitialize();
          bucketeer.start();
          success(result);
          break;
        case "stop":
          assertInitialize();
          bucketeer.stop();
          success(result);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (BucketeerException | RuntimeException e) {
      fail(result, e.getMessage());
    }
  }

  <T> T safeCast(Object o, Class<T> clazz) {
    return clazz != null && clazz.isInstance(o) ? clazz.cast(o) : null;
  }

  void assertInitialize() throws BucketeerException.IllegalStateException {
    if (bucketeer == null) {
      throw new BucketeerException.IllegalStateException("Required call the initialize method.");
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
