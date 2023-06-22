abstract class Constants {
  // Configuring apps with compilation environment declarations
  // https://dart.dev/guides/environment-declarations
  static const API_KEY = String.fromEnvironment("API_KEY", defaultValue: "*********");
  static const API_ENDPOINT = String.fromEnvironment("API_ENDPOINT", defaultValue:"*********.bucketeer.jp");

  static const DEFAULT_EVENTS_FLUSH_INTERVAL =  60000;
  static const DEFAULT_EVENT_MAX_QUEUE_SIZE = 4;
  static const DEFAULT_POLLING_INTERVAL = 60000;
  static const DEFAULT_BACKGROUND_POLLING_INTERVAL = 1200000;
}