package jp.bucketeer.plugin

import android.content.Context
import io.bucketeer.sdk.android.BKTClient
import io.bucketeer.sdk.android.BKTConfig
import io.bucketeer.sdk.android.BKTException
import io.bucketeer.sdk.android.BKTUser
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

/**
 * BucketeerPlugin
 */
class BucketeerPlugin : MethodCallHandler, FlutterPlugin {
  private var applicationContext: Context? = null
  private var methodChannel: MethodChannel? = null
  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
  }

  private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
    this.applicationContext = applicationContext
    methodChannel = MethodChannel(messenger, "jp.bucketeer.plugin/flutter")
    methodChannel!!.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    applicationContext = null
    methodChannel!!.setMethodCallHandler(null)
    methodChannel = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      val method = CallMethods.values().firstOrNull { call.method.lowercase() == it.name.lowercase() } ?: CallMethods.Unknown
      when (method) {
        CallMethods.Initialize -> {
          val debugging = (call.argument("debugging") as? Boolean) ?: false
          val userId = call.argument("userId") as? String
          val apiKey = call.argument("apiKey") as? String
          val apiEndpoint = call.argument("apiEndpoint") as? String
          val featureTag = call.argument("featureTag") as? String
          val eventsFlushInterval =
            call.argument("eventsFlushInterval") as? Long
          val eventsMaxQueueSize =
            call.argument("eventsMaxQueueSize") as? Int
          val pollingInterval =
            call.argument("pollingInterval") as? Long
          val backgroundPollingInterval =
            call.argument("backgroundPollingInterval") as? Long
          val appVersion = call.argument("appVersion") as? String
          if (apiKey.isNullOrEmpty()) {
            return fail(result, "Missing apiKey")
          }
          if (apiEndpoint.isNullOrEmpty()) {
            return fail(result, "Missing apiEndpoint")
          }
          if (featureTag.isNullOrEmpty()) {
            return fail(result, "Missing featureTag")
          }
          if (userId.isNullOrEmpty()) {
            return fail(result, "Missing userId")
          }
          if (appVersion.isNullOrEmpty()) {
            return fail(result, "Missing appVersion")
          }
          try {
            val config: BKTConfig = BKTConfig.builder()
              .apiKey(apiKey)
              .apiEndpoint(apiEndpoint)
              .featureTag(featureTag).let {
                if (eventsFlushInterval != null && eventsFlushInterval > 0) {
                  return@let it.eventsFlushInterval(eventsFlushInterval)
                }
                return@let it
              }.let {
                if (eventsMaxQueueSize != null && eventsMaxQueueSize > 0) {
                  return@let it.eventsMaxQueueSize(eventsMaxQueueSize)
                }
                return@let it
              }.let {
                if (pollingInterval != null && pollingInterval > 0) {
                  return@let it.pollingInterval(pollingInterval)
                }
                return@let it
              }.let {
                if (backgroundPollingInterval != null && backgroundPollingInterval > 0) {
                  return@let it.pollingInterval(backgroundPollingInterval)
                }
                return@let it
              }
              .appVersion(appVersion)
              .build()
            val user: BKTUser = BKTUser.builder().id(userId).build()
            BKTClient.destroy()
            BKTClient.initialize(applicationContext!!, config, user, 5000)
            success(result, true)
          } catch (ex: Exception) {
            fail(result, ex.message)
          }
        }

        CallMethods.CurrentUser -> {
          assertInitialize()
          val user = BKTClient.getInstance().currentUser()
          val map: MutableMap<String, Any> = HashMap()
          map["id"] = user.id
          map["data"] = user.attributes
          success(result, map)
        }

        CallMethods.EvaluationDetails -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val evaluation = BKTClient.getInstance().evaluationDetails(featureId)
          if (evaluation == null) {
            return fail(result, "Failed to fetch the evaluation.")
          } else {
            val map: MutableMap<String, Any> = HashMap()
            map["id"] = evaluation.id
            map["featureId"] = evaluation.featureId
            map["featureVersion"] = evaluation.featureVersion
            map["userId"] = evaluation.userId
            map["variationId"] = evaluation.variationId
            map["variationValue"] = evaluation.variationValue
            map["reason"] = evaluation.reason
            success(result, map)
          }
        }

        CallMethods.StringVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val defaultValue = args["defaultValue"] as? String
            ?: return fail(result, "Missing defaultValue")
          val response = BKTClient.getInstance().stringVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.IntVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val defaultValue = args["defaultValue"] as? Int
            ?: return fail(result, "Missing defaultValue")
          val response = BKTClient.getInstance().intVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.DoubleVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val defaultValue = args["defaultValue"] as? Double
            ?: return fail(result, "Missing defaultValue")
          val response = BKTClient.getInstance().doubleVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.BoolVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val defaultValue = args["defaultValue"] as? Boolean
            ?: return fail(result, "Missing defaultValue")
          val response = BKTClient.getInstance().booleanVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.Track -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val goalId = args["goalId"] as? String
            ?: return fail(result, "Missing goalId")
          val value = args["value"] as? Double
            ?: return fail(result, "Missing goal value")
          BKTClient.getInstance().track(goalId, value)
          success(result, true)
        }

        CallMethods.JsonVariation -> {
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = args["featureId"] as? String
            ?: return fail(result, "Missing featureId")
          val defaultValue = args["defaultValue"] as? Map<String, String > ?: mapOf()
          val response = BKTClient.getInstance().jsonVariation(featureId, JSONObject(defaultValue))
          success(result, response)
        }
        CallMethods.UpdateUserAttributes -> {
          val args = call.arguments<Map<String, String>>()!!
          BKTClient.getInstance().updateUserAttributes(args)
        }
        CallMethods.FetchEvaluations -> {
          val args = call.arguments<Map<String, Any>>()!!
          val timeoutMillis = args["timeoutMillis"] as? Long
          MainScope().launch {
            val err = withContext(Dispatchers.IO) {
              return@withContext BKTClient.getInstance().fetchEvaluations(timeoutMillis).get()
            }
            if (err != null) {
              fail(result, err.message)
            } else {
              success(result, true)
            }
          }
        }
        CallMethods.Flush -> {
          MainScope().launch {
            val err = withContext(Dispatchers.IO) {
              return@withContext BKTClient.getInstance().flush().get()
            }
            if (err != null) {
              success(result, err.message)
            } else {
              success(result, true)
            }
          }
        }
        CallMethods.AddEvaluationUpdateListener -> {
          result.notImplemented()
        }
        CallMethods.RemoveEvaluationUpdateListener -> {
          result.notImplemented()
        }
        CallMethods.ClearEvaluationUpdateListeners -> {
          result.notImplemented()
        }
        CallMethods.Unknown -> {
          result.notImplemented()
        }
      }
    } catch (e: BKTException) {
      fail(result, e.message)
    } catch (e: RuntimeException) {
      fail(result, e.message)
    }
  }

  @Throws(IllegalStateException::class)
  private fun assertInitialize() {
    BKTClient.getInstance()
  }

  private fun success(result: MethodChannel.Result?, response: Any? = null) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = true
    map["response"] = response
    result?.success(map)
  }

  private fun fail(result: MethodChannel.Result?, message: String?) {
    val map: MutableMap<String, Any?> = HashMap()
    map["status"] = false
    map["errorMessage"] = message
    result?.success(map)
  }
}

internal enum class CallMethods {
  Initialize,
  StringVariation,
  IntVariation,
  DoubleVariation,
  BoolVariation,
  JsonVariation,
  Track,
  CurrentUser,
  UpdateUserAttributes,
  FetchEvaluations,
  Flush,
  EvaluationDetails,
  AddEvaluationUpdateListener,
  RemoveEvaluationUpdateListener,
  ClearEvaluationUpdateListeners,
  Unknown
}
