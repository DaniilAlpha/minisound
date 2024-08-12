// ignore_for_file: avoid_print

import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/engine_flutter.dart";
import "package:minisound/generator.dart";
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
  var loopDelay = 0.0;

  final List<Float32List> recordingBuffer = [];
  late Recorder recorder;
  Timer? recorderTimer;
  Timer? generatorTimer;
  int totalRecordedFrames = 0;

  final List<Float32List> generatorBuffer = [];
  late Generator generator;
  GeneratorWaveformType waveformType = GeneratorWaveformType.sine;
  GeneratorNoiseType noiseType = GeneratorNoiseType.white;
  bool enableWaveform = false;
  bool enableNoise = false;
  bool enablePulse = false;
  var pulseDelay = 0.25;
  final List<Sound> sounds = [];

  Sound? currentSound;
  late final Future<Map<String, Sound>> soundsFuture;

  @override
  void initState() {
    super.initState();
    soundsFuture = _initializeSounds();
  }

  Future<Map<String, Sound>> _initializeSounds() async {
    if (!engine.isInit) {
      await engine.init();
      recorder = Recorder(mainEngine: engine);
      generator = Generator(mainEngine: engine);
    }
    final soundNames = [
      "assets/laser_shoot.wav",
      "assets/laser_shoot.mp3",
    ];
    return Future.wait(soundNames.map(
      engine.loadSoundAsset,
    )).then((sounds) => Map.fromIterables(soundNames, sounds));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Minisound Example")),
        body: Center(
          child: FutureBuilder(
            future: soundsFuture,
            builder: (_, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final sounds = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sound Playback",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton(
                            items: sounds.entries
                                .map((entry) => DropdownMenuItem(
                                      value: entry.value,
                                      child: Text(entry.key),
                                    ))
                                .toList(),
                            value: currentSound,
                            onChanged: (sound) => setState(() {
                              currentSound = sound;
                            }),
                          ),
                          ElevatedButton(
                            onPressed: currentSound == null
                                ? null
                                : () async {
                                    await engine.start();
                                    currentSound!.play();
                                  },
                            child: const Text("PLAY"),
                          ),
                          ElevatedButton(
                            onPressed: currentSound?.pause,
                            child: const Text("PAUSE"),
                          ),
                          ElevatedButton(
                            onPressed: currentSound?.stop,
                            child: const Text("STOP"),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Volume: "),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: currentSound?.volume ?? 0,
                                  min: 0,
                                  max: 10,
                                  divisions: 20,
                                  label:
                                      currentSound?.volume.toStringAsFixed(2),
                                  onChanged: (value) => setState(() {
                                    currentSound?.volume = value;
                                  }),
                                  onChangeEnd: (value) =>
                                      generator.volume = value,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: currentSound == null
                                ? null
                                : () async {
                                    await engine.start();
                                    currentSound!.playLooped(
                                      delay: Duration(
                                        milliseconds:
                                            (loopDelay * 1000).toInt(),
                                      ),
                                    );
                                  },
                            child: const Text("PLAY LOOPED"),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Loop delay:"),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: loopDelay,
                                  min: 0,
                                  max: 7,
                                  divisions: 300,
                                  label: loopDelay.toStringAsFixed(2),
                                  onChanged: (value) => setState(() {
                                    loopDelay = value;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Recorder",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            child: Text(
                              recorder.isRecording
                                  ? "STOP RECORDING"
                                  : "START RECORDING",
                            ),
                            onPressed: () async {
                              if (recorder.isRecording) {
                                try {
                                  final testSound =
                                      await createSoundFromRecorder(recorder);
                                  await recorder.engine.start();
                                  testSound.play();
                                } on Exception catch (e) {
                                  print("Error: $e");
                                } finally {
                                  setState(() {
                                    recorder.stop();
                                  });
                                  recorderTimer!.cancel();

                                  recordingBuffer.clear();
                                  totalRecordedFrames = 0;
                                }
                              } else {
                                if (!recorder.isInit) {
                                  await recorder.initStream();
                                }
                                setState(() {
                                  recorder.start();
                                });
                                recorderTimer = Timer.periodic(
                                  const Duration(milliseconds: 50),
                                  (_) => accumulateRecorderFrames(),
                                );
                                totalRecordedFrames = 0;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Generator",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Waveform Type: "),
                              DropdownButton<GeneratorWaveformType>(
                                value: waveformType,
                                items: GeneratorWaveformType.values
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                              type.toString().split(".").last),
                                        ))
                                    .toList(),
                                onChanged: enableWaveform
                                    ? (value) {
                                        setState(() {
                                          waveformType = value!;
                                        });
                                        generator.setWaveform(
                                          type: waveformType,
                                          frequency: 432.0,
                                        );
                                        if (enablePulse) {
                                          generator.setPulsewave(
                                            frequency: 432.0,
                                            dutyCycle: pulseDelay,
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Noise Type: "),
                              DropdownButton<GeneratorNoiseType>(
                                value: noiseType,
                                items: GeneratorNoiseType.values
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type.name),
                                        ))
                                    .toList(),
                                onChanged: enableNoise
                                    ? (value) {
                                        setState(() {
                                          noiseType = value!;
                                        });
                                        generator.setNoise(type: noiseType);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: enableWaveform,
                                onChanged: (value) {
                                  setState(() {
                                    enableWaveform = value!;
                                  });
                                  generator.setWaveform(type: waveformType);
                                },
                              ),
                              const Text("Waveform"),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: enableNoise,
                                onChanged: (value) {
                                  setState(() {
                                    enableNoise = value!;
                                  });
                                  generator.setNoise(type: noiseType);
                                },
                              ),
                              const Text("Noise"),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: enablePulse,
                                onChanged: (value) {
                                  setState(() {
                                    enablePulse = value!;
                                  });
                                  generator.setPulsewave(
                                    frequency: 432.0,
                                    dutyCycle: pulseDelay,
                                  );
                                },
                              ),
                              const Text("Pulse"),
                            ],
                          ),
                          ElevatedButton(
                            child:
                                Text(generator.isGenerating ? "STOP" : "START"),
                            onPressed: () async {
                              if (generator.isGenerating) {
                                setState(() {
                                  generator.stop();
                                  generatorTimer!.cancel();
                                });
                              } else {
                                if (!generator.isInit) {
                                  await generator.init();
                                  generator.setWaveform();
                                }

                                setState(() {
                                  generator.start();
                                  generatorTimer = Timer.periodic(
                                    const Duration(milliseconds: 100),
                                    (_) => accumulateGeneratorFrames(),
                                  );
                                });
                              }
                            },
                          ),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text("Pulse delay:"),
                            SizedBox(
                              width: 200,
                              child: Slider(
                                value: pulseDelay,
                                min: 0,
                                max: 1,
                                divisions: 300,
                                label: pulseDelay.toStringAsFixed(2),
                                onChanged: (value) => setState(() {
                                  pulseDelay = value;
                                }),
                                onChangeEnd: (value) => generator.setPulsewave(
                                  frequency: 432.0,
                                  dutyCycle: value,
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    );
                  } else {
                    return Text("Error: ${snapshot.error}");
                  }
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ),
      );

  void accumulateRecorderFrames() {
    if (recorder.isRecording) {
      final frames = recorder.getAvailableFrames();
      final buffer = recorder.getBuffer(frames);
      if (buffer.isNotEmpty) {
        recordingBuffer.add(buffer);
        totalRecordedFrames += frames;
      }
    }
  }

  void accumulateGeneratorFrames() {
    if (generator.isGenerating) {
      final frames = generator.availableFrameCount;
      final buffer = generator.getBuffer(frames);
      if (buffer.isNotEmpty) {
        generatorBuffer.add(buffer);
        totalRecordedFrames += frames;
      }
    }
  }

  Future<Sound> createSoundFromRecorder(Recorder recorder) async {
    var combinedBuffer = Float32List(0);
    if (sounds.isNotEmpty) {
      sounds.last.stop();
      sounds.last.unload();
    }

    final totalFrames =
        recordingBuffer.fold(0, (sum, chunk) => sum + chunk.length);

    combinedBuffer = Float32List(totalFrames);

    var offset = 0;
    for (final chunk in recordingBuffer) {
      combinedBuffer.setAll(offset, chunk);
      offset += chunk.length;
    }

    print("Combined buffer length: ${combinedBuffer.length}");
    print("Total recorded frames: $totalFrames");

    final audioData = AudioData(
      combinedBuffer.buffer.asFloat32List(),
      SoundFormat.f32,
      // TODO! replace placeholder values
      44100,
      1,
    );

    recordingBuffer.clear();
    sounds.add(await recorder.engine.loadSound(audioData));
    combinedBuffer = Float32List(0);
    return sounds.last;
  }

  @override
  void dispose() {
    recorder.dispose();
    generator.dispose();
    super.dispose();
  }
}
