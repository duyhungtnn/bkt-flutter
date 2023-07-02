import Flutter
import UIKit
import Bucketeer

public class BucketeerFlutterClientSdkPlugin: NSObject, FlutterPlugin {
    
    private static let METHOD_CHANNEL_NAME = "io.bucketeer.sdk.plugin.flutter"
    private static let EVALUATION_UPDATE_EVENT_CHANNEL_NAME = "\(METHOD_CHANNEL_NAME)::evaluation.update.listener"
    
    let evaluationListener = BucketeerPluginEvaluationUpdateListener()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = BucketeerFlutterClientSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: EVALUATION_UPDATE_EVENT_CHANNEL_NAME,
                                                      binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance.evaluationListener)
    }
    
    private func initialize(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let apiKey = arguments?["apiKey"] as? String else {
            fail(result: result, message: "apiKey is required")
            return
        }
        guard let apiEndpoint = arguments?["apiEndpoint"] as? String else {
            fail(result: result, message: "apiEndpoint is required")
            return
        }
        guard let featureTag = arguments?["featureTag"] as? String else {
            fail(result: result, message: "featureTag is required")
            return
        }
        guard let userId = arguments?["userId"] as? String else {
            fail(result: result, message: "userId is required")
            return
        }
        guard let appVersion = arguments?["appVersion"] as? String else {
            fail(result: result, message: "appVersion is required")
            return
        }
        
        do {
            var builder = BKTConfig.Builder(apiKey: apiKey)
                .with(apiEndpoint: apiEndpoint)
                .with(featureTag: featureTag)
                .with(appVersion: appVersion)
                
            if let eventsFlushInterval = arguments?["eventsFlushInterval"] as? Int64 {
                builder = builder.with(eventsFlushInterval: eventsFlushInterval)
            }
            
            if let eventsMaxQueueSize = arguments?["eventsMaxQueueSize"] as? Int {
                builder = builder.with(eventsMaxQueueSize: eventsMaxQueueSize)
            }
            
            if let pollingInterval = arguments?["pollingInterval"] as? Int64 {
                builder = builder.with(pollingInterval: pollingInterval)
            }
            
            if let backgroundPollingInterval = arguments?["backgroundPollingInterval"] as? Int64 {
                builder = builder.with(backgroundPollingInterval: backgroundPollingInterval)
            }
            
            if let debugging = arguments?["debugging"] as? Bool, debugging {
                builder = builder.with(logger: BucketeerPluginLogger())
            }
            
            let bkConfig = try builder.build()
            let userAttributes = arguments?["userAttributes"] as? [String: String] ?? [:]
            let user = try BKTUser.init(id: userId, attributes: userAttributes)
            
            if let timeoutMillis = arguments?["timeoutMillis"] as? Int64 {
                BKTClient.initialize(config: bkConfig, user: user, timeoutMillis: timeoutMillis)
            } else {
                BKTClient.initialize(config: bkConfig, user: user)
            }
            // Set default EvaluationUpdateListener. It will forward event to the Flutter side for handle
            BKTClient.shared.addEvaluationUpdateListener(listener: evaluationListener)
            success(result: result, response: true)
        } catch {
            debugPrint("BKTClient.initialize failed with error: \(error)")
            fail(result: result, message: error.localizedDescription)
        }
    }
    
    private func stringVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? String else {
            fail(result: result, message: "defaultValue is required")
            return
        }
        let response = BKTClient.shared.stringVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func intVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Int else {
            fail(result: result, message: "defaultValue is required")
            return
        }
        let response = BKTClient.shared.intVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func doubleVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Double else {
            fail(result: result, message: "defaultValue is required")
            return
        }
        let response = BKTClient.shared.doubleVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func boolVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Bool else {
            fail(result: result, message: "defaultValue is required")
            return
        }
        let response = BKTClient.shared.boolVariation(featureId: featureId, defaultValue: defaultValue)
        success(result: result, response: response)
    }
    
    private func track(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let goalId = arguments?["goalId"] as? String else {
            fail(result: result, message: "goalId is required")
            return
        }
        if let value = arguments?["value"] as? Double {
            BKTClient.shared.track(goalId: goalId, value: value)
        } else {
            BKTClient.shared.track(goalId: goalId)
        }
        success(result: result, response: true)
    }
    
    private func jsonVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            fail(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Dictionary<String, AnyHashable> else {
            fail(result: result, message: "defaultValue is required")
            return
        }
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
            fail(result: result, message: "userAttributes is required")
            return
        }
        BKTClient.shared.updateUserAttributes(attributes: userAttributes)
        success(result: result, response: true)
    }
    
    private func fetchEvaluations(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        let timeoutMillis = arguments?["timeoutMillis"] as? Int64
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
            fail(result: result, message: "featureId is required")
            return
        }
        guard let response = BKTClient.shared.evaluationDetails(featureId: featureId) else {
            fail(result: result, message: "Feature flag not found.")
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
            
        case .addEvaluationUpdateListener, .removeEvaluationUpdateListener, .clearEvaluationUpdateListeners:
            // note: will handle in Flutter only. We don't implement native code for these methods
            // see: BucketeerPluginEvaluationUpdateListener.swift
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
