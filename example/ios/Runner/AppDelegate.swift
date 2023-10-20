import UIKit
import Flutter
// 1.Import the SDK
import Bucketeer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 2.Add the code to enable background tasks
    if #available(iOS 13.0, tvOS 13.0, *) {
        BKTBackgroundTask.enable()
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
