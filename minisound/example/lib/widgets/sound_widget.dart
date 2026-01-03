import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minisound/engine_flutter.dart';

class SoundWidget extends StatefulWidget {
  const SoundWidget({required this.engine, required this.sound, super.key});

  final Engine engine;
  final Sound sound;

  @override
  State<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    Sound sound = widget.sound;
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Volume: "),
              Slider(
                value: sound.volume,
                min: 0,
                max: 2,
                divisions: 8,
                label: sound.volume.toStringAsFixed(2),
                onChanged: (value) => setState(() {
                  sound.volume = value;
                }),
              ),
            ],
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Pitch: "),
            Slider(
              value: sound.pitch,
              min: 0,
              max: 4,
              divisions: 20,
              label: sound.pitch.toStringAsFixed(2),
              onChanged: (value) => setState(() {
                sound.pitch = value;
              }),
            ),
          ]),
          if (sound is LoadedSound)
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Cursor: "),
              Slider(
                value: sound.cursor.inMilliseconds.toDouble(),
                min: 0,
                max: sound.duration.inMilliseconds.toDouble(),
                onChanged: (value) => setState(() {
                  sound.cursor = Duration(milliseconds: value.floor());
                }),
              ),
              Text(
                  "${(sound.cursor.inMilliseconds / 1000).toStringAsFixed(2)}s"),
            ]),
          if (sound is LoadedSound)
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Loop delay:"),
              Slider(
                value: sound.loopDelay.inMilliseconds.toDouble(),
                min: 0,
                max: 7000,
                divisions: 100,
                label:
                    (sound.loopDelay.inMilliseconds / 1000).toStringAsFixed(2),
                onChanged: (value) => setState(() {
                  sound.loopDelay = Duration(milliseconds: value.toInt());
                }),
              ),
              Switch(
                value: sound.isLooped,
                onChanged: (value) => setState(() {
                  sound.isLooped = value;
                }),
              ),
            ]),
          SizedBox.square(dimension: 16),
          OverflowBar(children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.restart_alt),
              onPressed: () async {
                await widget.engine.start();

                sound.play();
                _startUpdateTimer();
              },
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.pause),
              onPressed: () {
                sound.pause();
                _stopUpdateTimer();
              },
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.play_arrow),
              onPressed: () async {
                await widget.engine.start();

                sound.resume();
                _startUpdateTimer();
              },
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.stop),
              onPressed: () {
                sound.stop();
                _stopUpdateTimer();
              },
            ),
          ]),
        ]),
      ),
    );
  }

  void _startUpdateTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 33), (_) => setState(() {}));
  }

  void _stopUpdateTimer() {
    timer?.cancel();
    timer = null;
    setState(() {});
  }
}
