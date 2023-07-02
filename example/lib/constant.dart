abstract class Constants {
  // Configuring apps with compilation environment declarations
  // https://dart.dev/guides/environment-declarations
  static const API_KEY = String.fromEnvironment("API_KEY", defaultValue: "*****************************");
  static const API_ENDPOINT = String.fromEnvironment("API_ENDPOINT", defaultValue:"https://api.example.com");
  static const EXAMPLE_FEATURE_TAG = "ios";
  static const EXAMPLE_USERID = "bucketeer-ios-user-id-1";
  static const EXAMPLE_EVENTS_FLUSH_INTERVAL =  60000;
  static const EXAMPLE_EVENT_MAX_QUEUE_SIZE = 4;
  static const EXAMPLE_POLLING_INTERVAL = 60000;
  static const EXAMPLE_BACKGROUND_POLLING_INTERVAL = 1200000;
}