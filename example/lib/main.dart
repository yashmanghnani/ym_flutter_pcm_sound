import 'dart:async';

// Flutter's Material library remains bundled with the SDK.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ym_flutter_pcm_sound/ym_flutter_pcm_sound.dart';

void main() => runApp(const PcmExample());

class PcmExample extends StatelessWidget {
  const PcmExample({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PCM Sound',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const PlayerPage(),
  );
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  static const sampleRate = 48000;
  final _scale = MajorScale(sampleRate: sampleRate, noteDuration: 0.2);
  bool _ready = false;
  bool _playing = false;
  bool _active = true;
  int _remainingFrames = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await FlutterPcmSound.setup(sampleRate: sampleRate, channelCount: 1);
      await FlutterPcmSound.setFeedThreshold(sampleRate ~/ 10);
      if (!mounted) return;
      FlutterPcmSound.setFeedCallback(_onFeed);
      setState(() => _ready = true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _onFeed(int remainingFrames) {
    if (!mounted) return;
    setState(() => _remainingFrames = remainingFrames);
    if (_playing && _active) unawaited(_feed());
  }

  Future<void> _feed() async {
    try {
      await FlutterPcmSound.feed(
        PcmArrayInt16.fromList(_scale.generate(periods: 20)),
      );
    } catch (error) {
      if (mounted)
        setState(() {
          _playing = false;
          _error = error.toString();
        });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active && _playing && _ready) FlutterPcmSound.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterPcmSound.setFeedCallback(null);
    unawaited(FlutterPcmSound.release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PCM Sound')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Buffered frames: $_remainingFrames'),
          if (_error != null) Text(_error!),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: !_ready
                ? null
                : () {
                    setState(() => _playing = !_playing);
                    if (_playing) FlutterPcmSound.start();
                  },
            child: Text(_playing ? 'Stop' : 'Play'),
          ),
        ],
      ),
    ),
  );
}
