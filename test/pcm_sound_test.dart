import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ym_flutter_pcm_sound/ym_flutter_pcm_sound.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_pcm_sound/methods');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
  });
  tearDown(() {
    FlutterPcmSound.setFeedCallback(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('feeds only the requested byte slice', () async {
    final data = Uint8List.fromList([9, 9, 1, 2, 3, 4, 9]);
    await FlutterPcmSound.feed(
      PcmArrayInt16(bytes: ByteData.sublistView(data, 2, 6)),
    );
    expect((calls.single.arguments as Map)['buffer'], [1, 2, 3, 4]);
  });

  test('samples use signed little-endian encoding', () {
    final samples = PcmArrayInt16.fromList([-2, 256]);
    expect(samples.bytes.buffer.asUint8List(), [254, 255, 0, 1]);
    expect(samples[0], -2);
    samples[1] = -1;
    expect(samples[1], -1);
  });

  test('validates setup and threshold arguments', () async {
    await expectLater(
      FlutterPcmSound.setup(sampleRate: 0, channelCount: 1),
      throwsArgumentError,
    );
    await expectLater(
      FlutterPcmSound.setup(sampleRate: 48000, channelCount: 3),
      throwsArgumentError,
    );
    await expectLater(
      FlutterPcmSound.setFeedThreshold(-1),
      throwsArgumentError,
    );
  });

  test('release allows playback to start again', () async {
    var starts = 0;
    FlutterPcmSound.setFeedCallback((_) => starts++);
    await FlutterPcmSound.feed(PcmArrayInt16.fromList([1]));
    expect(FlutterPcmSound.start(), false);
    await FlutterPcmSound.release();
    expect(FlutterPcmSound.start(), true);
    expect(starts, 1);
  });
}
