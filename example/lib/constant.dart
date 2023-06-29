abstract class Constants {
  // Configuring apps with compilation environment declarations
  // https://dart.dev/guides/environment-declarations
  // static const API_KEY = String.fromEnvironment("API_KEY", defaultValue: "*****************************");
  // static const API_ENDPOINT = String.fromEnvironment("API_ENDPOINT", defaultValue:"https://api.example.com");
  static const DEFAULT_FEATURE_TAG = "ios";
  static const DEFAULT_USERID = "bucketeer-ios-user-id-1";
  static const DEFAULT_EVENTS_FLUSH_INTERVAL =  60000;
  static const DEFAULT_EVENT_MAX_QUEUE_SIZE = 4;
  static const DEFAULT_POLLING_INTERVAL = 60000;
  static const DEFAULT_BACKGROUND_POLLING_INTERVAL = 1200000;
  static const API_KEY = String.fromEnvironment("API_KEY", defaultValue: "68f36f74aed68a63c6a0de5cf2de2f343c3714c0d1be4083f8fa679a39644a7c");
  static const API_ENDPOINT = String.fromEnvironment("API_ENDPOINT", defaultValue:"https://api-dev.bucketeer.jp");
}

//--dart-define=API_KEY=68f36f74aed68a63c6a0de5cf2de2f343c3714c0d1be4083f8fa679a39644a7c --dart-define=API_ENDPOINT=https://api-dev.bucketeer.jp