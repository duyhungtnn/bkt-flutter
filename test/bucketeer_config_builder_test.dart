import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BKTConfigBuilder Tests', () async {
    final builderMissingAPIKey = BKTConfigBuilder();
    expect(() => builderMissingAPIKey.build(), throwsA(isA<ArgumentError>()));

    final builderMissingAPIEndpoint = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000)
        .appVersion("1.0.0");
    expect(() => builderMissingAPIEndpoint.build(), throwsA(isA<ArgumentError>()));

    final builderWithEmptyFeatureTag = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.jp")
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000)
        .appVersion("1.0.0");
    expect(builderWithEmptyFeatureTag.build().featureTag, "");

    final builderMissingAppVersion = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.jp")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000);
    expect(() => builderMissingAppVersion.build(), throwsA(isA<ArgumentError>()));

    final config = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.jp")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000)
        .appVersion("1.0.0")
        .build();
    expect(config.apiKey, "apikeyapikeyapikeyapikeyapikeyapikeyapikey");
    expect(config.apiEndpoint, "demo.bucketeer.jp");
    expect(config.featureTag, 'Flutter');
    expect(config.debugging, true);
    expect(config.eventsMaxQueueSize, 10000);
    expect(config.eventsFlushInterval, 10000);
    expect(config.pollingInterval, 10000);
    expect(config.backgroundPollingInterval, 10000);
    expect(config.appVersion, "1.0.0");
  });
}