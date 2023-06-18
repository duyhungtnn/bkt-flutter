# Bucketeer Client-side SDK for Flutter

<p align="left">
  <a href="https://app.bitrise.io/app/b8b8516d5a295ff8">
    <img src="https://app.bitrise.io/app/b8b8516d5a295ff8/status.svg?token=pE9S8CDlmfFRPD9EbBBsKw&branch=main"/>
  </a>
  <a href="https://pub.dartlang.org/packages/flutter_bucketeer">
    <img src="https://img.shields.io/pub/v/flutter_bucketeer.svg">
  </a>
</p>


## Setup

Install prerequisite tools.

- [asdf](https://github.com/asdf-vm/asdf)
  - [Flutter](https://flutter.dev/docs)
- [Dart](https://dart.dev/)

## Install

```yaml
dependencies:
  flutter_bucketeer: ^1.x.x
```

```shell
$ flutter pub get
```

## SDK Development

#### Example

Build Example.

```
make build-android
make build-ios
```

#### Publishing 

**1. Update versions**

- [ios/flutter_bucketeer.podspech](https://github.com/ca-dp/bucketeer-flutter-sdk/blob/main/ios/flutter_bucketeer.podspec#L7)  
- [android/build.gradle](https://github.com/ca-dp/bucketeer-flutter-sdk/blob/main/android/build.gradle#L2)  
- [pubspec.yaml](https://github.com/ca-dp/bucketeer-flutter-sdk/blob/main/pubspec.yaml#L3)  

**1-2. Update dependencies**

- [Update Bucketeer iOS SDK](https://github.com/ca-dp/bucketeer-flutter-sdk/blob/main/ios/flutter_bucketeer.podspec#L16)
- [Update Bucketeer Android SDK](https://github.com/ca-dp/bucketeer-flutter-sdk/blob/main/android/build.gradle#L38)

**2. Publish to [`pub.dev`](https://pub.dev/packages/flutter_bucketeer)**

```
dart pub publish
```

## SDK User Docs

**Now working the Flutter documents.**

- [Tutorial](https://bucketeer.io/docs/#/./client-side-sdk-tutorial-flutter)
- [Integration](https://bucketeer.io/docs/#/./client-side-sdk-reference-guides-flutter)

## Samples 

[Bucketeer Samples](https://github.com/ca-dp/bucketeer-samples)
