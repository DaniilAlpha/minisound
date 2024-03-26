import "package:flutter/material.dart";
import "package:minisound/minisound.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    title: "Minisound Example",
    home: ExamplePage(),
  ));
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final engine = Engine();

  late final Future<Sound> soundFuture = () async {
    await engine.init();
    return engine.loadSoundAsset("assets/laser_shoot.wav");
  }();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: FutureBuilder(
              future: soundFuture,
              builder: (_, snapshot) => switch (snapshot) {
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      hasData: true,
                      data: final sound!
                    ) =>
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text("PLAY"),
                            onPressed: () async {
                              await engine.start();

                              sound.play();
                            },
                          ),
                          SizedBox(
                            width: 200,
                            child: Slider(
                              value: sound.volume,
                              min: 0,
                              max: 10,
                              divisions: 20,
                              label: sound.volume.toString(),
                              onChanged: (value) => setState(() {
                                sound.volume = value;
                              }),
                            ),
                          ),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Checkbox(
                              value: sound.isLooped,
                              onChanged: (value) => setState(() {
                                sound.isLooped = value!;
                              }),
                            ),
                            const Text("Is looped?"),
                          ]),
                        ],
                      ),
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      hasData: false,
                      :final error
                    ) =>
                      Text("error: $error"),
                    _ => const CircularProgressIndicator(),
                  }),
        ),
      );
}
