import "dart:async";
import "dart:typed_data";

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
  List<Float32List> recordingBuffer = [];
  int totalRecordedFrames = 0;
  int waveType = 0;
  double waveFrequency = 440.0;
  double waveAmplitude = 1.0;
  List<Sound> sounds = [];

  late final Future<Sound> soundFuture;

  @override
  void initState() {
    super.initState();
    recorder = Recorder();
    wave = Wave();
    soundFuture = _initializeSound();
  }

  Future<Sound> _initializeSound() async {
    if (!engine.isInit) {
      await engine.init();
    }
    //await engine.start();
    //await wave.init(0, waveFrequency, waveAmplitude, 44100);
    return engine.loadSoundAsset("assets/laser_shoot.wav");
  }

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
                                  try {
                                    final testSound =
                                        await createSoundFromRecorder(recorder);
                                    await recorder.engine.start();
                                    testSound.play();
                                  } catch (e) {
                                    print(e);
                                  } finally {
                                    recorder.stop();
                                    // Clear the buffer after creating the sound
                                    recordingBuffer.clear();
                                    totalRecordedFrames = 0;
                                  }
                                } else {
                                  if (recorder.isRecording) {
                                    recorder.stop();
                                  }
                                  if (!recorder.isCreated) {
                                    await recorder.initStream(
                                        sampleRate: 48000,
                                        channels: 1,
                                        format: 5);
                                    recorder.isCreated = true;
                                  }

                                  recorder.start();
                                  Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      (_) => accumulateFrames());

                                  totalRecordedFrames = 0;
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
                                  max: 2000,
                                  divisions: 150,
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
                                final waveBuffer = wave.read(1024);
                                final audioData = AudioData(
                                    waveBuffer.buffer.asFloat32List(),
                                    AudioFormat.int32,
                                    48000,
                                    1);
                                await engine.start();
                                final sound = await engine.loadSound(audioData);
                                sound.play();
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

  void accumulateFrames() {
    if (isRecording) {
      final frames = recorder.getAvailableFrames();
      final buffer = recorder.getBuffer(frames);
      if (buffer.isNotEmpty) {
        recordingBuffer.add(buffer);
        totalRecordedFrames += frames;
      }
    }
  }

  Future<Sound> createSoundFromRecorder(Recorder recorder) async {
    Float32List combinedBuffer = Float32List(0);
    if (sounds.isNotEmpty) {
      sounds.last.stop();
      sounds.last.unload();
    }

    // Calculate the total number of frames in the recordingBuffer
    int totalFrames =
        recordingBuffer.fold(0, (sum, chunk) => sum + chunk.length);

    // Resize the combinedBuffer to match the total number of frames
    combinedBuffer = Float32List(totalFrames);

    int offset = 0;
    for (var chunk in recordingBuffer) {
      combinedBuffer.setAll(offset, chunk);
      offset += chunk.length;
    }

    print("Combined buffer length: ${combinedBuffer.length}");
    print("Total recorded frames: $totalFrames");

    // Create AudioData object
    final audioData = AudioData(combinedBuffer.buffer.asFloat32List(),
        AudioFormat.float32, recorder.sampleRate, recorder.channels);

    recordingBuffer.clear();
    sounds.add(await recorder.engine.loadSound(audioData));
    combinedBuffer = Float32List(0);
    return sounds.last;
  }

  @override
  void dispose() {
    recorder.dispose();
    wave.dispose();
    super.dispose();
  }
}

Widget returnError(error) {
  print(error);
  return Text("Error: $error");
}
