# YM Flutter PCM Sound

[![pub package](https://img.shields.io/pub/v/ym_flutter_pcm_sound.svg)](https://pub.dev/packages/ym_flutter_pcm_sound)

Stream generated 16-bit PCM audio to Android and iOS speakers. The plugin accepts samples directly and requests more when its buffer runs low; it does not decode audio files.

## Requirements

- Flutter 3.50.1 or newer and Dart 3.14 or newer.
- Android API 24 or newer, or iOS 15.0 or newer.
- Mono or interleaved stereo, signed 16-bit little-endian PCM.

macOS is no longer supported as of 2.0.0. Version 2.0.0 also raises the minimum Flutter, Dart, and iOS versions.

## Installation

```yaml
dependencies:
  ym_flutter_pcm_sound: ^2.0.0
```

Run `flutter pub get` and import:

```dart
import 'package:ym_flutter_pcm_sound/ym_flutter_pcm_sound.dart';
```

## Usage

```dart
final scale = MajorScale(sampleRate: 48000, noteDuration: 0.2);
var playing = true;

await FlutterPcmSound.setup(sampleRate: 48000, channelCount: 1);
await FlutterPcmSound.setFeedThreshold(4800);
FlutterPcmSound.setFeedCallback((remainingFrames) async {
  if (!playing) return;
  final samples = scale.generate(periods: 20);
  await FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
});
FlutterPcmSound.start();

// To stop, stop feeding. Existing buffered audio plays out.
playing = false;
// When finished with the plugin:
FlutterPcmSound.setFeedCallback(null);
await FlutterPcmSound.release();
```

`MajorScale` is a small built-in demo generator. In a real application, generate or receive your own PCM samples. For stereo, supply interleaved left and right samples; one frame contains one sample per channel. `PcmArrayInt16` also accepts a `ByteData` view containing little-endian samples.

## Buffering and lifecycle

The callback receives the number of frames still queued by the plugin. It fires when the queue reaches the configured threshold or becomes empty, at most once per feed for each event. Native output buffering means a zero queue does not necessarily mean the speaker has finished playing. Choose a threshold and feed size that balance latency against underruns. Generate audio away from the UI isolate if it blocks the interface.

Call `setup` before feeding. Call `release` when done, and await it before setting up again. To restart after stopping, call `start()` once the queue has drained. On iOS, `setup` accepts `iosAudioCategory` and `iosAllowBackgroundAudio`; background playback also requires the host app's audio background mode and an appropriate audio session category. Handle app lifecycle changes in the host app.

## Example

The example includes Android and iOS host projects:

```sh
cd example
flutter pub get
flutter run
```

Select an Android or iOS device when prompted. iOS device builds require an appropriate signing team in Xcode.

## Development

```sh
flutter pub get
flutter analyze
flutter test
cd example
flutter analyze
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

## License

See [LICENSE](LICENSE).
