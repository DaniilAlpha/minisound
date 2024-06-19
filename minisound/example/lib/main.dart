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

  var loopDelay = 0.0;

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
                          ElevatedButton(
                            child: const Text("PAUSE"),
                            onPressed: () async {
                              sound.pause();
                            },
                          ),
                          ElevatedButton(
                            child: const Text("STOP"),
                            onPressed: () async {
                              sound.stop();
                            },
                          ),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text("Volume: "),
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
                          ]),
                          ElevatedButton(
                            child: const Text("PLAY LOOPED"),
                            onPressed: () async {
                              await engine.start();

                              sound.playLooped(
                                  delay: Duration(
                                      milliseconds:
                                          (loopDelay * 1000).toInt()));
                            },
                          ),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text(
                                "Loop duration (changes occure when stopped and played again)"),
                            SizedBox(
                              width: 200,
                              child: Slider(
                                value: loopDelay,
                                min: 0,
                                max: 3,
                                divisions: 300,
                                label: loopDelay.toString(),
                                onChanged: (value) => setState(() {
                                  loopDelay = value;
                                }),
                              ),
                            ),
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
