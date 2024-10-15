import "package:example/widgets/generation_example.dart";
import "package:example/widgets/playback_example.dart";
import "package:example/widgets/recording_example.dart";
import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/recorder.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(title: "Minisound Example", home: ExamplePage()));
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final engine = Engine();
  final recorder = Recorder();

  late final initFuture = Future.wait([engine.init(), recorder.init()]);

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 20);
    return Scaffold(
      appBar: AppBar(title: const Text("Minisound Example")),
      body: Center(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: initFuture,
            builder: (_, snapshot) => switch (snapshot) {
              AsyncSnapshot(
                connectionState: ConnectionState.done,
                hasError: false
              ) =>
                Column(children: [
                  PlaybackExample(engine),
                  space,
                  GenerationExample(engine),
                  space,
                  RecordingExample(recorder, engine: engine),
                ]),
              AsyncSnapshot(connectionState: ConnectionState.waiting) =>
                const Center(child: CircularProgressIndicator()),
              AsyncSnapshot(:final error) =>
                Center(child: Text("Error: $error")),
            },
          ),
        ),
      ),
    );
  }
}
