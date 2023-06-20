import "package:flutter/material.dart";
import "package:minisound/minisound.dart";

final engine = Engine();
late final Sound sound;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await engine.init();

  sound = await engine.loadSoundAsset("assets/laser_shoot.wav");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Minisound Example",
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          appBar: AppBar(title: const Text("Minisound Example")),
          body: Center(
            child: ElevatedButton(
              child: const Text("LASER SHOOT"),
              onPressed: () async {
                await engine.start();
                sound.play();
              },
            ),
          ),
        ),
      );
}
