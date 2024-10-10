import "package:example/widgets/generator_example.dart";
import "package:example/widgets/playback_example.dart";
import "package:flutter/material.dart";
import "package:minisound/engine.dart";

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
  // late final recorder = Recorder();
  // late final generator = Generator(mainEngine: engine);

  late final initFuture = engine.init().then((_) => print("engine init!"))
      // .then((_) => recorder.initStream(channels: 1))
      // .then((_) => generator.init())
      ;

  @override
  void dispose() {
    // recorder.dispose();
    // generator.dispose();
    super.dispose();
  }

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
                  // RecorderExample(engine, recorder),
                  // space,
                  GeneratorExample(engine),
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
