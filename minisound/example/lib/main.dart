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
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? ElevatedButton(
                        child: const Text("LASER SHOOT"),
                        onPressed: () async {
                          await engine.start();

                          final sound = snapshot.data!;
                          sound.play();
                        },
                      )
                    : const CircularProgressIndicator(),
          ),
        ),
      );
}
