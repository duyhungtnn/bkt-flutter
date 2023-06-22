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
        let callMethod = BKTFlutterCallMethod(rawValue: call.method) ?? .unknown
        switch callMethod {
        case .initialize:
            guard let apiKey = arguments?["apiKey"] as? String else {
                fail(result: result, message: "Required apiKey value.")
                return
            }
            guard let apiEndpoint = arguments?["apiEndpoint"] as? String else {
                fail(result: result, message: "Required endpoint value.")
                return
            }
            guard let featureTag = arguments?["featureTag"] as? String else {
                fail(result: result, message: "Required featureTag value.")
                return
            }
            guard let userId = arguments?["userId"] as? String else {
                fail(result: result, message: "Required userId value.")
                return
            }
            guard let appVersion = arguments?["appVersion"] as? String else {
                fail(result: result, message: "Required appVersion value.")
                return
            }
            
            let debugging = arguments?["debugging"] as? Bool ?? false
            let eventsFlushInterval = arguments?["eventsFlushInterval"] as? Int64 ?? Constant.DEFAULT_FLUSH_INTERVAL_MILLIS
            let eventsMaxQueueSize = arguments?["eventsMaxQueueSize"] as? Int ?? Constant.DEFAULT_MAX_QUEUE_SIZE
            let pollingInterval = arguments?["pollingInterval"] as? Int64 ?? Constant.DEFAULT_POLLING_INTERVAL_MILLIS
            let backgroundPollingInterval = arguments?["backgroundPollingInterval"] as? Int64 ?? Constant.DEFAULT_BACKGROUND_POLLING_INTERVAL_MILLIS
            BKTClient.destroy()
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
                do {
                    let bkConfig = try BKTConfig.init(
                        apiKey: apiKey,
                        apiEndpoint: apiEndpoint,
                        featureTag: featureTag,
                        eventsFlushInterval: eventsFlushInterval,
                        eventsMaxQueueSize: eventsMaxQueueSize,
                        pollingInterval: pollingInterval,
                        backgroundPollingInterval: backgroundPollingInterval,
                        appVersion: appVersion,
                        logger: debugging ? BucketeerPluginLogger() : nil
                    )
                    let user = try BKTUser.init(id: userId, attributes: [:])
                    
                    BKTClient.initialize(config: bkConfig, user: user)
                    self?.success(result: result, response: true)
                } catch BKTError.illegalArgument(let message) {
                    // For Example I care only about .timeout
                    self?.fail(result: result, message: message)
                } catch {
                    debugPrint("BKTClient.initialize failed with error: \(error)")
                    self?.fail(result: result, message: error.localizedDescription)
                    
                }
            }
            break
        case .stringVariation:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            let defaultValue = arguments?["defaultValue"] as? String ?? ""
            let response = BKTClient.shared.stringVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        case .intVariation:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            let defaultValue = arguments?["defaultValue"] as? Int ?? 0
            let response = BKTClient.shared.intVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        case .doubleVariation:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            let defaultValue = arguments?["defaultValue"] as? Double ?? 0.0
            let response = BKTClient.shared.doubleVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        case .boolVariation:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            let defaultValue = arguments?["defaultValue"] as? Bool ?? false
            let response = BKTClient.shared.boolVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        case .track:
            guard let goalId = arguments?["goalId"] as? String else {
                fail(result: result, message: "Required goalId value.")
                return
            }
            let value = arguments?["value"] as? Double ?? 0.0
            BKTClient.shared.track(goalId: goalId, value: value)
            success(result: result)
        case .jsonVariation:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            let defaultValue = arguments?["defaultValue"] as? Dictionary<String, AnyHashable> ?? [:]
            let response = BKTClient.shared.jsonVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        case .currentUser:
            guard BKTClient.shared.currentUser() != nil else {
                fail(result: result, message: "Failed to fetch the user.")
                return
            }
            success(result: result, response: ["id": "id", "data": [:]])
            break
        case .updateUserAttributes:
            guard let userAttributes = call.arguments as? [String: String] else {
                fail(result: result, message: "Required userAttributes value.")
                return
            }
            BKTClient.shared.updateUserAttributes(attributes: userAttributes)
            success(result: result)
            
            break
        case .fetchEvaluations:
            let timeoutMillis = arguments?["timeoutMillis"] as? Int64 ?? 30_0000
            BKTClient.shared.fetchEvaluations(timeoutMillis: timeoutMillis) { [weak self] err in
                if let err {
                    self?.fail(result: result, message: err.message())
                } else {
                    self?.success(result: result, response: true)
                }
            }
        case .flush:
            BKTClient.shared.flush {[weak self] error in
                if let bktError = error {
                    let errorMessage = bktError.message()
                    self?.fail(result: result, message: errorMessage)
                } else {
                    self?.success(result: result, response: true)
                }
            }
        case .evaluationDetails:
            guard let featureId = arguments?["featureId"] as? String else {
                fail(result: result, message: "Required featureId value.")
                return
            }
            guard let response = BKTClient.shared.evaluationDetails(featureId: featureId) else {
                fail(result: result, message: "Failed to fetch the evaluation.")
                return
            }
            success(
                result: result,
                response: [
                    "id": response.id,
                    "featureId": response.featureId,
                    "featureVersion": response.featureVersion,
                    "userId": response.userId,
                    "variationId": response.variationId,
                    "variationValue": response.variationValue,
                    "reason": response.reason,
                ])
            break
        case .addEvaluationUpdateListener:
            result(FlutterMethodNotImplemented)
        case .removeEvaluationUpdateListener:
            result(FlutterMethodNotImplemented)
        case .clearEvaluationUpdateListeners:
            result(FlutterMethodNotImplemented)
        case .destroy:
            BKTClient.destroy()
            success(result: result, response: true)
        default:
            result(FlutterMethodNotImplemented)
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
