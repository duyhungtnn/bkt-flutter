package jp.bucketeer.plugin

import android.content.Context
import io.bucketeer.sdk.android.BKTClient.Companion.getInstance
import io.bucketeer.sdk.android.BKTClient.Companion.initialize
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
import java.util.concurrent.CompletableFuture

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
      when (CallMethods.values().firstOrNull { call.method.lowercase() == it.name.lowercase() } ?: CallMethods.Unknown) {
        CallMethods.Initialize -> {
          val debugging = safeCast(call.argument("debugging"), Boolean::class.java)
          val userId = safeCast(call.argument("userId"), String::class.java)
          val apiKey = safeCast(call.argument("apiKey"), String::class.java)
          val apiEndpoint = safeCast(call.argument("apiEndpoint"), String::class.java)
          val featureTag = safeCast(call.argument("featureTag"), String::class.java)
          val eventsFlushInterval =
            safeCast(call.argument("eventsFlushInterval"), Long::class.java)
          val eventsMaxQueueSize =
            safeCast(call.argument("eventsMaxQueueSize"), Int::class.java)
          val pollingInterval =
            safeCast(call.argument("pollingInterval"), Long::class.java)
          val backgroundPollingInterval =
            safeCast(call.argument("backgroundPollingInterval"), Long::class.java)
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
            .build()
          val user: BKTUser = BKTUser.builder().id(userId).build()
          initialize(applicationContext!!, config, user, 5000)
          success(result)
        }

        CallMethods.CurrentUser -> {
          assertInitialize()
          val user = getInstance().currentUser()
          val map: MutableMap<String, Any> = HashMap()
          map["id"] = user.id
          map["data"] = user.attributes
          success(result, map)
        }

        CallMethods.EvaluationDetails -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val evaluation = getInstance().evaluationDetails(featureId)
          if (evaluation == null) {
            fail(result, "Failed to fetch the evaluation.")
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
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val defaultValue = safeCast(args["defaultValue"], String::class.java)!!
          val response = getInstance().stringVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.IntVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val defaultValue = safeCast(args["defaultValue"], Int::class.java)!!
          val response = getInstance().intVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.DoubleVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val defaultValue = safeCast(args["defaultValue"], Double::class.java)!!
          val response = getInstance().doubleVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.BoolVariation -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val defaultValue = safeCast(args["defaultValue"], Boolean::class.java)!!
          val response = getInstance().booleanVariation(featureId, defaultValue)
          success(result, response)
        }

        CallMethods.Track -> {
          assertInitialize()
          val args = call.arguments<Map<String, Any>>()!!
          val goalId = safeCast(args["goalId"], String::class.java)!!
          val value = safeCast(args["value"], Double::class.java)!!
          getInstance().track(goalId, value)
          success(result)
        }

        CallMethods.JsonVariation -> {
          val args = call.arguments<Map<String, Any>>()!!
          val featureId = safeCast(args["featureId"], String::class.java)!!
          val defaultValue = safeCast(args["defaultValue"], Map::class.java) ?: mutableMapOf<String, String>()
          val response = getInstance().jsonVariation(featureId, JSONObject(defaultValue))
          success(result, response)
        }
        CallMethods.UpdateUserAttributes -> {
          val args = call.arguments<Map<String, String>>()!!
          getInstance().updateUserAttributes(args)
        }
        CallMethods.FetchEvaluations -> {
          val args = call.arguments<Map<String, Any>>()!!
          val timeoutMillis = safeCast(args["timeoutMillis"], Long::class.java)!!
          MainScope().launch {
            val err = withContext(Dispatchers.IO) {
              getInstance().fetchEvaluations(timeoutMillis).get()
            }
            if (err != null) {
              success(result, err.message)
            } else {
              success(result, true)
            }
          }
        }
        CallMethods.Flush -> {
          MainScope().launch {
            val err = withContext(Dispatchers.IO) {
              getInstance().flush().get()
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

  private fun <T> safeCast(o: Any?, clazz: Class<T>?): T? {
    return if (clazz != null && clazz.isInstance(o)) clazz.cast(o) else null
  }

  @Throws(IllegalStateException::class)
  private fun assertInitialize() {
    getInstance()
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