import "dart:async";

import "package:example/widgets/sound_widget.dart";
import "package:flutter/material.dart";
import "package:minisound/player_flutter.dart";

class PlaybackExample extends StatefulWidget {
  const PlaybackExample(this.player, {super.key});

  final Player player;

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
        newSounds[soundName] = await widget.player.loadSoundAsset(soundName);
      }));

      setState(() {
        currentSoundName = newSounds.keys.first;
        sounds.addAll(newSounds);
      });
    }();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
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
        if (sounds[currentSoundName] case final Sound currentSound) ...[
          SoundWidget(player: widget.player, sound: currentSound),
          ElevatedButton(
            child: const Text("REMOVE"),
            onPressed: () => setState(() {
              sounds.remove(currentSoundName);
              currentSoundName = null;
            }),
          ),
        ] else
          Text("No sound selected!")
      ]);
}
