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

  final activeRecordings = <RamRec>[];

  @override
  Widget build(BuildContext context) {
    const space = SizedBox.square(dimension: 20);
    return Column(children: [
      Text("Recording", style: Theme.of(context).textTheme.headlineMedium),
      IconButton.filledTonal(
        icon: const Icon(Icons.mic),
        onPressed: () async {
          await widget.recorder.start();

          activeRecordings.add(widget.recorder.recordRam());
          setState(() {});
        },
      ),
      ElevatedButton(
        child: const Text("STOP RECORDING"),
        onPressed: () async {
          if (activeRecordings.isEmpty) return;

          final rec = activeRecordings.removeLast();
          rec.stop();

          sounds.add(
            (DateTime.now(), await widget.engine.loadSound(rec.data!)),
          );
          setState(() {});
        },
      ),
      Column(
          children: sounds.reversed
              .map((t) => OverflowBar(
                      overflowAlignment: OverflowBarAlignment.center,
                      children: [
                        Text(t.$1.toString()),
                        space,
                        Text("${t.$2.duration}s"),
                        space,
                        ElevatedButton(
                          child: const Text("PLAY"),
                          onPressed: () =>
                              widget.engine.start().then((_) => t.$2.play()),
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
