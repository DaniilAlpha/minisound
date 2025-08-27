import "dart:io";

import "package:example/widgets/generation_example.dart";
import "package:example/widgets/playback_example.dart";
import "package:example/widgets/recording_example.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/recorder.dart";
import "package:permission_handler/permission_handler.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWasm) {
    if (kDebugMode) print("Its the actual WASM build!");
  }
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

  late final initFuture = engine.init().then((_) {
    if (kIsWeb || !Platform.isLinux) return Permission.microphone.request();
    return Future.value();
  }).then((_) => recorder.init());

  @override
  Widget build(BuildContext context) {
    const space = SizedBox.square(dimension: 20);
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
