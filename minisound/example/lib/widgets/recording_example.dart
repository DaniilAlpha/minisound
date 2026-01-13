import "package:example/widgets/sound_widget.dart";
import "package:flutter/material.dart";
import "package:minisound/player.dart";
import "package:minisound/recorder.dart";

class RecordingExample extends StatefulWidget {
  const RecordingExample(this.recorder, {required this.player, super.key});

  final Player player;
  final Recorder recorder;

  @override
  State<RecordingExample> createState() => _RecordingExampleState();
}

class _RecordingExampleState extends State<RecordingExample> {
  final sounds = <(DateTime, LoadedSound)>[];

  final recQueue = <BufRec>[];

  var sampleFormat = SampleFormat.s16;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text("Recording", style: Theme.of(context).textTheme.headlineMedium),
        Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Text("Sample Format: "),
                DropdownButton(
                  value: sampleFormat,
                  items: SampleFormat.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (value) => setState(() {
                    value!;

                    sampleFormat = value;
                  }),
                ),
              ]),
              OverflowBar(children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.mic),
                  onPressed: () async {
                    await widget.recorder.start();

                    recQueue.add(await widget.recorder.saveRecBuf(
                      sampleFormat: sampleFormat,
                    ));
                    setState(() {});
                  },
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.stop),
                  onPressed: () async {
                    if (recQueue.isEmpty) return;

                    final rec = recQueue.removeAt(0);

                    sounds.add(
                      (
                        DateTime.now(),
                        await widget.player.loadSound(await rec.end())
                      ),
                    );
                    setState(() {});
                  },
                ),
              ]),
              const SizedBox.square(dimension: 10),
              Text("Currently Recording: ${recQueue.length}"),
            ]),
          ),
        ),
        Column(
            children: sounds.reversed
                .map((t) => Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(t.$1
                          .toString()
                          .substring(0, 19)
                          .replaceFirst(" ", "\n")),
                      SoundWidget(
                        player: widget.player,
                        sound: t.$2,
                      ),
                    ]))
                .toList()),
      ]);
}
