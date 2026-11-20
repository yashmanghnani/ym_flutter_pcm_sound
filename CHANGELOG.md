# Changelog

## 2.0.0

- Require Flutter 3.50.1, Dart 3.14, Android API 24, and iOS 15 or later.
- Remove macOS support and its platform implementation.
- Add current Flutter-generated Android and iOS example projects and refresh the example app.
- Fix PCM byte views so only the requested slice is sent to native code, and encode samples as little-endian.
- Validate sample rate, channel count, and feed threshold; reset playback startup state after setup and release.
- Fix the example tone generator’s DC offset and initialize the iOS audio format safely.
- Correct the iOS podspec name and update platform metadata.
- Add tests and refresh setup, usage, and development documentation.

## 1.0.0

- Initial release.
