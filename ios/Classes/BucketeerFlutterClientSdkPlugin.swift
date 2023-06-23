import Flutter
import UIKit
import Bucketeer

public class BucketeerFlutterClientSdkPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.bucketeer.sdk.plugin.flutter", binaryMessenger: registrar.messenger())
        let instance = BucketeerFlutterClientSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func initialize(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
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
            success(result: result, response: true)
        } catch {
            debugPrint("BKTClient.initialize failed with error: \(error)")
            fail(result: result, message: error.localizedDescription)
        }
    }
    
    private func stringVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "Required featureId value.")
            return
        }
        let defaultValue = arguments?["defaultValue"] as? String ?? ""
        let response = BKTClient.shared.stringVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func intVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "Required featureId value.")
            return
        }
        let defaultValue = arguments?["defaultValue"] as? Int ?? 0
        let response = BKTClient.shared.intVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func doubleVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "Required featureId value.")
            return
        }
        let defaultValue = arguments?["defaultValue"] as? Double ?? 0.0
        let response = BKTClient.shared.doubleVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func boolVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "Required featureId value.")
            return
        }
        let defaultValue = arguments?["defaultValue"] as? Bool ?? false
        let response = BKTClient.shared.boolVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func track(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let goalId = arguments?["goalId"] as? String else {
            fail(result: result, message: "Required goalId value.")
            return
        }
        let value = arguments?["value"] as? Double ?? 0.0
        BKTClient.shared.track(goalId: goalId, value: value)
        success(result: result, response: true)
    }
    
    private func jsonVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "Required featureId value.")
            return
        }
        let defaultValue = arguments?["defaultValue"] as? Dictionary<String, AnyHashable> ?? [:]
        let response = BKTClient.shared.jsonVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func currentUser(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let user = BKTClient.shared.currentUser() else {
            fail(result: result, message: "Failed to fetch the user.")
            return
        }
        success(result: result, response: ["id": user.id, "data": user.attr])
    }
    
    private func updateUserAttributes(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let userAttributes = arguments as? [String: String] else {
            fail(result: result, message: "Required userAttributes value.")
            return
        }
        BKTClient.shared.updateUserAttributes(attributes: userAttributes)
        success(result: result, response: true)
    }
    
    private func fetchEvaluations(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        let timeoutMillis = arguments?["timeoutMillis"] as? Int64 ?? 30_0000
        BKTClient.shared.fetchEvaluations(timeoutMillis: timeoutMillis) { [weak self] err in
            if let err {
                self?.fail(result: result, message: err.localizedDescription)
            } else {
                self?.success(result: result, response: true)
            }
        }
    }
    
    private func flush(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        BKTClient.shared.flush {[weak self] error in
            if let bktError = error {
                let errorMessage = bktError.localizedDescription
                self?.fail(result: result, message: errorMessage)
            } else {
                self?.success(result: result, response: true)
            }
        }
    }
    
    private func evaluationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
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
                "reason": response.reason.rawValue,
            ])
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let arguments = call.arguments as? [String: Any]
        let callMethod = BKTFlutterCallMethod(rawValue: call.method) ?? .unknown
        switch callMethod {
        case .initialize:
            initialize(arguments, result)
            
        case .stringVariation:
            stringVariation(arguments, result)
            
        case .intVariation:
            intVariation(arguments, result)
            
        case .doubleVariation:
            doubleVariation(arguments, result)
            
        case .boolVariation:
            boolVariation(arguments, result)
            
        case .track:
            track(arguments, result)
            
        case .jsonVariation:
            jsonVariation(arguments, result)
            
        case .currentUser:
            currentUser(arguments, result)
            
            
        case .updateUserAttributes:
            updateUserAttributes(arguments, result)
            
        case .fetchEvaluations:
            fetchEvaluations(arguments, result)
            
        case .flush:
            flush(arguments, result)
            
        case .evaluationDetails:
            evaluationDetails(arguments, result)
            
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
