## README

Run e2e tests

```
export BKT_API_KEY=your_api_key
expert BKT_API_ENDPOINT=your_api_endpoint
flutter test --dart-define=API_KEY=$BKT_API_KEY --dart-define=API_ENDPOINT=$BKT_API_ENDPOINT integration_test
```
