import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/recorder.dart";

class RecordingExample extends StatefulWidget {
  const RecordingExample(this.recorder, {required this.engine, super.key});

  final Engine engine;
  final Recorder recorder;

  @override
  State<RecordingExample> createState() => _RecordingExampleState();
}

class _RecordingExampleState extends State<RecordingExample> {
  final sounds = <(DateTime, LoadedSound)>[];

  @override
  Widget build(BuildContext context) {
    const space = SizedBox.square(dimension: 20);
    return Column(children: [
      Text("Recording", style: Theme.of(context).textTheme.headlineMedium),
      !widget.recorder.isRecording
          ? ElevatedButton(
              child: const Text("START RECORDING"),
              onPressed: () {
                widget.recorder.start();
                setState(() {});
              },
            )
          : ElevatedButton(
              child: const Text("STOP RECORDING"),
              onPressed: () async {
                final recording = await widget.recorder.stop();
                sounds.add((
                  DateTime.now(),
                  await widget.engine.loadSound(recording.buffer)
                ));
                setState(() {});
              },
            ),
      Column(
          children: sounds.reversed
              .map((t) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(t.$1.toString()),
                    space,
                    Text("${t.$2.duration}s"),
                    space,
                    ElevatedButton(
                      child: const Text("PLAY"),
                      onPressed: () => widget.engine.start().then((_) async {
                        final sound = t.$2;

                        sound.play();

                        sound.volume = 0;
                        await Future.delayed(const Duration(milliseconds: 30));
                        sound.volume = 1;
                      }),
                    ),
                    ElevatedButton(
                      child: const Text("STOP"),
                      onPressed: () =>
                          widget.engine.start().then((_) => t.$2.stop()),
                    ),
                  ]))
              .toList()),
    ]);
  }
}
