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
  Sound? currentSound;
  var loopDelay = 0.0;

  late Future<Map<String, Sound>> soundsFuture = _initSounds();

  Future<Map<String, Sound>> _initSounds() async {
    const soundNames = [
      "assets/laser_shoot.wav",
      "assets/laser_shoot_16bit.wav",
      "assets/laser_shoot.mp3",
    ];
    return Future.wait(soundNames.map(widget.engine.loadSoundAsset))
        .then((sounds) {
      currentSound = sounds.first;
      return Map.fromIterables(soundNames, sounds);
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: soundsFuture,
        builder: (_, snapshot) => switch (snapshot) {
          AsyncSnapshot(hasData: true, data: final sounds!) =>
            Column(children: [
              Text("Playback",
                  style: Theme.of(context).textTheme.headlineMedium),
              DropdownButton(
                items: sounds.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.value,
                          child: Text(entry.key),
                        ))
                    .toList(),
                value: currentSound,
                onChanged: (sound) => setState(() {
                  currentSound = sound;
                }),
              ),
              ElevatedButton(
                onPressed: currentSound == null
                    ? null
                    : () =>
                        widget.engine.start().then((_) => currentSound!.play()),
                child: const Text("PLAY"),
              ),
              ElevatedButton(
                  onPressed: currentSound?.pause, child: const Text("PAUSE")),
              ElevatedButton(
                  onPressed: currentSound?.stop, child: const Text("STOP")),
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
                              currentSound?.volume = value;
                            }),
                  ),
                ),
              ]),
              ElevatedButton(
                onPressed: currentSound == null
                    ? null
                    : () => widget.engine
                        .start()
                        .then((_) => currentSound!.playLooped(
                              delay: Duration(
                                milliseconds: (loopDelay * 1000).toInt(),
                              ),
                            )),
                child: const Text("PLAY LOOPED"),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                    "Loop delay (change applied after sound restarted): "),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: loopDelay,
                    min: 0,
                    max: 7,
                    divisions: 200,
                    label: loopDelay.toStringAsFixed(2),
                    onChanged: (value) => setState(() {
                      loopDelay = value;
                    }),
                  ),
                ),
              ]),
            ]),
          AsyncSnapshot(connectionState: ConnectionState.waiting) =>
            const Center(child: CircularProgressIndicator()),
          AsyncSnapshot(:final error) => Center(child: Text("Error: $error")),
        },
      );
}
