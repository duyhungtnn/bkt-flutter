setup:
	npm install

deps:
	flutter pub get
	cd example && flutter pub get

analyze:
	dart analyze lib/
	cd example && flutter analyze

format:
	flutter format lib/ example/lib

build-android:
	cd example && flutter build apk && cd ..

build-ios:
	cd example && flutter build ios --no-codesign && cd ..

unit-test:
	flutter test --coverage --coverage-path=./coverage/lcov.info
