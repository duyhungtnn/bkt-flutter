import Flutter
import UIKit
import Bucketeer

public class BucketeerPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "jp.bucketeer.plugin/flutter", binaryMessenger: registrar.messenger())
    let instance = BucketeerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    let arguments = call.arguments as? [String: Any]

    switch call.method {
    case "initialize":
      guard let apiKey = arguments?["apiKey"] as? String else {
        fail(result: result, message: "Required apiKey value.")
        return
      }
      guard let endpoint = arguments?["endpoint"] as? String else {
        fail(result: result, message: "Required endpoint value.")
        return
      }
      guard let featureTag = arguments?["featureTag"] as? String else {
        fail(result: result, message: "Required featureTag value.")
        return
      }
      let debugging = arguments?["debugging"] as? Bool ?? false

      var config = Config(sdkKey: apiKey, apiURL: endpoint, tag: featureTag)
      config.logLevel = debugging ? .debug : .none
      config.getEvaluationsPollingInterval = arguments?["pollingEvaluationIntervalMillis"] as? TimeInterval ?? 120_000
      config.registerEventsPollingInterval = arguments?["logSendingIntervalMillis"] as? TimeInterval ?? 60_000
      config.maxEventsPerRequest = arguments?["logSendingMaxBatchQueueCount"] as? Int ?? 100
      BucketeerSDK.setup(config: config)
      success(result: result)
      break
    case "setUser":
      guard let userId = arguments?["userId"] as? String else {
        fail(result: result, message: "Required userId value.")
        return
      }

      var userAttributes = call.arguments as? [String: String]
      userAttributes?.removeValue(forKey: "userId")

      BucketeerSDK.shared.setUser(userID: userId, userAttributes: userAttributes) { res in
        switch res {
        case .success:
          self.success(result: result)
        case .failure:
          self.fail(result: result, message: "Failed setUser(" + userId + ")")
        }
      }
      break
    case "getUser":
        guard let response = BucketeerSDK.shared.getUser() else {
	        fail(result: result, message: "Failed to fetch the user.")
          return
        }
        success(result: result, response: ["id": response.id, "data": response.data])
      break
    case "getEvaluation":
        guard let featureId = arguments?["featureId"] as? String else {
          fail(result: result, message: "Required featureId value.")
          return
        }
        guard let response = BucketeerSDK.shared.getEvaluation(featureID: featureId) else {
	        fail(result: result, message: "Failed to fetch the evaluation.")
          return
        }
        success(
          result: result,
          response: [
            "id": response.id, "featureId": response.featureID,
            "featureVersion": response.featureVersion, "userId": response.userID,
            "variationId": response.variationID, "variationValue": response.variationValue,
            "reason": response.reason,
          ])
      break
    case "getStringVariation":
      guard let featureId = arguments?["featureId"] as? String else {
        fail(result: result, message: "Required featureId value.")
        return
      }
      let defaultValue = arguments?["defaultValue"] as? String ?? ""
      let response = BucketeerSDK.shared.stringVariation(featureID: featureId, defaultValue: defaultValue)
      success(result: result, response: response)
      break
    case "getIntVariation":
      guard let featureId = arguments?["featureId"] as? String else {
        fail(result: result, message: "Required featureId value.")
        return
      }
      let defaultValue = arguments?["defaultValue"] as? Int ?? 0
      let response = BucketeerSDK.shared.intVariation(featureID: featureId, defaultValue: defaultValue)
      success(result: result, response: response)
      break
    case "getDoubleVariation":
      guard let featureId = arguments?["featureId"] as? String else {
        fail(result: result, message: "Required featureId value.")
        return
      }
      let defaultValue = arguments?["defaultValue"] as? Float ?? Float(0.0)
      let response = BucketeerSDK.shared.floatVariation(featureID: featureId, defaultValue: Float(defaultValue))
      success(result: result, response: response)
      break
    case "getBoolVariation":
      guard let featureId = arguments?["featureId"] as? String else {
        fail(result: result, message: "Required featureId value.")
        return
      }
      let defaultValue = arguments?["defaultValue"] as? Bool ?? false
      let response = BucketeerSDK.shared.boolVariation(featureID: featureId, defaultValue: defaultValue)
      success(result: result, response: response)
      break
    case "track":
      guard let goalId = arguments?["goalId"] as? String else {
        fail(result: result, message: "Required goalId value.")
        return
      }
      let value = arguments?["value"] as? Double ?? 0.0
      BucketeerSDK.shared.track(goalID: goalId, value: value)
      success(result: result)
      break
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }

  func success(result: @escaping FlutterResult, response: Any? = nil) {
    let dic = [
      "status": true,
      "response": response
    ] as [String: Any?]
    result(dic)
  }

  func fail(result: @escaping FlutterResult, message: String = "") {
    let dic = [
      "status": false,
      "errorMessage": message
    ] as [String: Any]
    result(dic)
  }
}
