package io.bucketeer.sdk.flutter

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
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * BucketeerPlugin
 */
class BucketeerFlutterClientSdkPlugin : MethodCallHandler, FlutterPlugin {
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

  private fun initialize(call: MethodCall, result: MethodChannel.Result) {
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
      BKTClient.initialize(applicationContext!!, config, user, 5000)
      success(result, true)
    } catch (ex: Exception) {
      fail(result, ex.message)
    }
  }

  private fun currentUser(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val user = BKTClient.getInstance().currentUser()
    val map: MutableMap<String, Any> = HashMap()
    map["id"] = user.id
    map["data"] = user.attributes
    success(result, map)
  }

  private fun evaluationDetails(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "Missing featureId")
    val evaluation = BKTClient.getInstance().evaluationDetails(featureId)
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
      map["reason"] = evaluation.reason.name
      success(result, map)
    }
  }

  private fun stringVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "Missing featureId")
    val defaultValue = args["defaultValue"] as? String
      ?: return fail(result, "Missing defaultValue")
    val response = BKTClient.getInstance().stringVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun intVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "Missing featureId")
    val defaultValue = args["defaultValue"] as? Int
      ?: return fail(result, "Missing defaultValue")
    val response = BKTClient.getInstance().intVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun doubleVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "Missing featureId")
    val defaultValue = args["defaultValue"] as? Double
      ?: return fail(result, "Missing defaultValue")
    val response = BKTClient.getInstance().doubleVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun boolVariation(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val featureId = args["featureId"] as? String
      ?: return fail(result, "Missing featureId")
    val defaultValue = args["defaultValue"] as? Boolean
      ?: return fail(result, "Missing defaultValue")
    val response = BKTClient.getInstance().booleanVariation(featureId, defaultValue)
    success(result, response)
  }

  private fun track(call: MethodCall, result: MethodChannel.Result) {
    assertInitialize()
    val args = call.arguments<Map<String, Any>>()!!
    val goalId = args["goalId"] as? String
      ?: return fail(result, "Missing goalId")
    val value = args["value"] as? Double
      ?: return fail(result, "Missing goal value")
    BKTClient.getInstance().track(goalId, value)
    success(result, true)
  }

  private fun jsonVariation(call: MethodCall, result: MethodChannel.Result) {
    try {
      val args = call.arguments<Map<String, Any>>()!!
      val featureId = args["featureId"] as? String
        ?: return fail(result, "Missing featureId")
      val defaultValue = args["defaultValue"] as? Map<String, String> ?: mapOf()
      val response =
        BKTClient.getInstance().jsonVariation(featureId, JSONObject(defaultValue))
      val rawJson = response.toMap()
      success(result, rawJson)
    } catch (ex: Exception) {
      fail(result, message = ex.message ?: "get JsonVariation fail")
    }
  }

  private fun updateUserAttributes(call: MethodCall, result: MethodChannel.Result) {
    val args = call.arguments<Map<String, String>>()!!
    BKTClient.getInstance().updateUserAttributes(args)
    success(result, true)
  }

  private fun fetchEvaluations(call: MethodCall, result: MethodChannel.Result) {
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

  private fun flush(call: MethodCall, result: MethodChannel.Result) {
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

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      when (CallMethods.values().firstOrNull { call.method.lowercase() == it.name.lowercase() }
        ?: CallMethods.Unknown) {
        CallMethods.Initialize -> {
          initialize(call, result)
        }

        CallMethods.CurrentUser -> {
          currentUser(call, result)
        }

        CallMethods.EvaluationDetails -> {
          evaluationDetails(call, result)
        }

        CallMethods.StringVariation -> {
          stringVariation(call, result)
        }

        CallMethods.IntVariation -> {
          intVariation(call, result)
        }

        CallMethods.DoubleVariation -> {
          doubleVariation(call, result)
        }

        CallMethods.BoolVariation -> {
          boolVariation(call, result)
        }

        CallMethods.Track -> {
          track(call, result)
        }

        CallMethods.JsonVariation -> {
         jsonVariation(call, result)
        }

        CallMethods.UpdateUserAttributes -> {
          updateUserAttributes(call, result)
        }

        CallMethods.FetchEvaluations -> {
          fetchEvaluations(call, result)
        }

        CallMethods.Flush -> {
          flush(call, result)
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

        CallMethods.Destroy -> {
          BKTClient.destroy()
          success(result, true)
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
  Destroy,
  Unknown
}

@Throws(JSONException::class)
fun JSONObject.toMap(): Map<String, Any> {
  val map = mutableMapOf<String, Any>()
  val keysItr: Iterator<String> = this.keys()
  while (keysItr.hasNext()) {
    val key = keysItr.next()
    var value: Any = this.get(key)
    when (value) {
      is JSONArray -> value = value.toList()
      is JSONObject -> value = value.toMap()
    }
    map[key] = value
  }
  return map
}

@Throws(JSONException::class)
fun JSONArray.toList(): List<Any> {
  val list = mutableListOf<Any>()
  for (i in 0 until this.length()) {
    var value: Any = this[i]
    when (value) {
      is JSONArray -> value = value.toList()
      is JSONObject -> value = value.toMap()
    }
    list.add(value)
  }
  return list
}