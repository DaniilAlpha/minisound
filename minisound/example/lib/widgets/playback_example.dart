import "dart:async";

import "package:flutter/material.dart";
import "package:minisound/engine_flutter.dart";

class PlaybackExample extends StatefulWidget {
  const PlaybackExample(this.engine, {super.key});

  final Engine engine;

  @override
  State<PlaybackExample> createState() => _PlaybackExampleState();
}

class _PlaybackExampleState extends State<PlaybackExample> {
  static const soundNames = [
    "assets/laser_shoot.wav",
    "assets/laser_shoot_16bit.wav",
    "assets/laser_shoot.mp3",
    "assets/00_plus.mp3",
    "assets/kevin_macleod_call_to_adventure.mp3",
  ];

  final sounds = <String, LoadedSound>{};
  String? currentSoundName;

  @override
  void initState() {
    super.initState();

    () async {
      final newSounds = <String, LoadedSound>{};
      await Future.wait(soundNames.map((soundName) async {
        newSounds[soundName] = await widget.engine.loadSoundAsset(soundName);
      }));

      setState(() {
        currentSoundName = newSounds.keys.first;
        sounds.addAll(newSounds);
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    final currentSound = sounds[currentSoundName];
    return Column(children: [
      Text("Playback", style: Theme.of(context).textTheme.headlineMedium),
      DropdownButton(
        items: sounds.entries
            .map((entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.key)))
            .toList(),
        value: currentSoundName,
        onChanged: (soundName) => setState(() {
          currentSoundName = soundName;
        }),
      ),
      ElevatedButton(
        child: const Text("REMOVE"),
        onPressed: () => setState(() {
          sounds.remove(currentSoundName);
          currentSoundName = null;
        }),
      ),
      Row(mainAxisSize: MainAxisSize.min, children: [
        const Text("Volume: "),
        SizedBox(
          width: 200,
          child: Slider(
            value: currentSound?.volume ?? 0,
            min: 0,
            max: 5,
            divisions: 10,
            label: currentSound?.volume.toStringAsFixed(2),
            onChanged: currentSound == null
                ? null
                : (value) => setState(() {
                      currentSound.volume = value;
                    }),
          ),
        ),
      ]),
      OverflowBar(children: [
        ElevatedButton(
          onPressed: currentSound == null
              ? null
              : () => widget.engine.start().then((_) => currentSound.play()),
          child: const Text("PLAY"),
        ),
        ElevatedButton(
            onPressed: currentSound?.pause, child: const Text("PAUSE")),
        ElevatedButton(
            onPressed: currentSound?.resume, child: const Text("RESUME")),
        ElevatedButton(
            onPressed: currentSound?.stop, child: const Text("STOP")),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        const Text("Loop delay\n(changes immediately): "),
        SizedBox(
          width: 200,
          child: Slider(
            value: currentSound == null
                ? 0.0
                : currentSound.loopDelay.inMilliseconds.toDouble(),
            min: 0,
            max: 7000,
            // divisions: 100,
            label: currentSound == null
                ? null
                : (currentSound.loopDelay.inMilliseconds / 1000)
                    .toStringAsFixed(2),
            onChanged: currentSound == null
                ? null
                : (value) => setState(() {
                      currentSound.loopDelay =
                          Duration(milliseconds: value.toInt());
                    }),
          ),
        ),
      ]),
      Switch(
        value: currentSound == null ? false : currentSound.isLooped,
        onChanged: currentSound == null
            ? null
            : (val) => setState(() {
                  currentSound.isLooped = val;
                }),
      ),
    ]);
  }
}
