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
  late Recorder recorder;
  late Wave wave;
  bool isRecording = false;
  int waveType = 0;
  double waveFrequency = 440.0;
  double waveAmplitude = 1.0;

  late final Future<Sound> soundFuture = () async {
    await engine.init();
    recorder = engine.createRecorder();
    wave = engine.createWave();
    //await wave.init(0, waveFrequency, waveAmplitude, 44100);
    return engine.loadSoundAsset("assets/laser_shoot.wav");
  }();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Minisound Example")),
        body: Center(
          child: FutureBuilder(
              future: soundFuture,
              builder: (_, snapshot) => switch (snapshot) {
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      hasData: true,
                      data: final sound!
                    ) =>
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sound Playback",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              child: const Text("PLAY"),
                              onPressed: () async {
                                await engine.start();
                                sound.play();
                              },
                            ),
                            ElevatedButton(
                              child: const Text("PAUSE"),
                              onPressed: () => sound.pause(),
                            ),
                            ElevatedButton(
                              child: const Text("STOP"),
                              onPressed: () => sound.stop(),
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
                                  label: sound.volume.toStringAsFixed(2),
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
                              const Text("Loop delay:"),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: loopDelay,
                                  min: 0,
                                  max: 3,
                                  divisions: 300,
                                  label: loopDelay.toStringAsFixed(2),
                                  onChanged: (value) => setState(() {
                                    loopDelay = value;
                                  }),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 20),
                            const Text("Recorder",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              child: Text(isRecording
                                  ? "STOP RECORDING"
                                  : "START RECORDING"),
                              onPressed: () async {
                                if (isRecording) {
                                  final buff = recorder.getBuffer(44100);
                                  try {
                                    await engine
                                        .loadSound(buff.buffer.asUint8List());
                                  } catch (e) {
                                    print(e);
                                  }

                                  recorder.stop();
                                } else {
                                  await recorder.initStream();
                                  recorder.start();
                                }

                                setState(() {
                                  isRecording = !isRecording;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text("Wave Generator",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            DropdownButton<int>(
                              value: waveType,
                              items: const [
                                DropdownMenuItem(value: 0, child: Text("Sine")),
                                DropdownMenuItem(
                                    value: 1, child: Text("Square")),
                                DropdownMenuItem(
                                    value: 2, child: Text("Triangle")),
                                DropdownMenuItem(
                                    value: 3, child: Text("Sawtooth")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  waveType = value!;
                                  wave.setType(waveType);
                                });
                              },
                            ),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Text("Frequency: "),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: waveFrequency,
                                  min: 20,
                                  max: 20000,
                                  divisions: 1000,
                                  label: waveFrequency.toStringAsFixed(2),
                                  onChanged: (value) => setState(() {
                                    waveFrequency = value;
                                    wave.setFrequency(waveFrequency);
                                  }),
                                ),
                              ),
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Text("Amplitude: "),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: waveAmplitude,
                                  min: 0,
                                  max: 1,
                                  divisions: 100,
                                  label: waveAmplitude.toStringAsFixed(2),
                                  onChanged: (value) => setState(() {
                                    waveAmplitude = value;
                                    wave.setAmplitude(waveAmplitude);
                                  }),
                                ),
                              ),
                            ]),
                            ElevatedButton(
                              child: const Text("PLAY WAVE"),
                              onPressed: () async {
                                final waveBuffer = wave.read(44100);
                                print(waveBuffer); // 1 second of audio
                              },
                            ),
                          ],
                        ),
                      ),
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      hasData: false,
                      :final error
                    ) =>
                      returnError(error),
                    _ => const CircularProgressIndicator(),
                  }),
        ),
      );
}

Widget returnError(error) {
  print(error);
  return Text("Error: $error");
}
