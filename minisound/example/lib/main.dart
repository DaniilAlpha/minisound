// ignore_for_file: avoid_print

import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:minisound/minisound.dart";
import "package:minisound/minisound_flutter.dart";

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
  Timer? recorderTimer;
  Timer? generatorTimer;
  late Generator generator;
  WaveformType waveformType = WaveformType.sine;
  NoiseType noiseType = NoiseType.white;
  bool enableWaveform = false;
  bool enableNoise = false;
  bool enablePulse = false;
  var pulseDelay = 0.25;
  final List<Float32List> recordingBuffer = [];
  final List<Float32List> generatorBuffer = [];

  int totalRecordedFrames = 0;
  final List<Sound> sounds = [];

  late final Future<Sound> soundFuture;

  @override
  void initState() {
    super.initState();
    soundFuture = _initializeSound();
  }

  Future<Sound> _initializeSound() async {
    if (!engine.isInit) {
      await engine.init();
      recorder = Recorder(mainEngine: engine);
      generator = Generator(mainEngine: engine);
    }
    return engine.loadSoundAsset("assets/laser_shoot.wav");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Minisound Example")),
        body: Center(
          child: FutureBuilder(
            future: soundFuture,
            builder: (_, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final sound = snapshot.data!;
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
                          ElevatedButton(
                            child: const Text("PLAY"),
                            onPressed: () async {
                              await engine.start();
                              sound.play();
                            },
                          ),
                          ElevatedButton(
                            child: const Text("PAUSE"),
                            onPressed: () => sound..pause(),
                          ),
                          ElevatedButton(
                            child: const Text("STOP"),
                            onPressed: () => sound..stop(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                  onChangeEnd: (value) =>
                                      generator.volume = value,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            child: const Text("PLAY LOOPED"),
                            onPressed: () async {
                              await engine.start();
                              sound.playLooped(
                                delay: Duration(
                                  milliseconds: (loopDelay * 1000).toInt(),
                                ),
                              );
                            },
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
                                  await recorder.initStream(
                                    sampleRate: 48000,
                                    channels: 1,
                                    format: AudioFormat.float32,
                                  );
                                  recorder.isInit = true;
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
                              DropdownButton<WaveformType>(
                                value: waveformType,
                                items: WaveformType.values
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
                                          waveformType,
                                          432.0,
                                          0.5,
                                        );
                                        if (enablePulse) {
                                          generator.setPulsewave(
                                            432.0,
                                            0.5,
                                            pulseDelay,
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
                              DropdownButton<NoiseType>(
                                value: noiseType,
                                items: NoiseType.values
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                              type.toString().split(".").last),
                                        ))
                                    .toList(),
                                onChanged: enableNoise
                                    ? (value) {
                                        setState(() {
                                          noiseType = value!;
                                        });
                                        generator.setNoise(
                                          noiseType,
                                          0,
                                          0.5,
                                        );
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
                                  generator.setWaveform(
                                    waveformType,
                                    432.0,
                                    0.5,
                                  );
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
                                  generator.setNoise(
                                    noiseType,
                                    0,
                                    0.5,
                                  );
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
                                    432.0,
                                    0.5,
                                    pulseDelay,
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
                                  await generator.init(
                                    AudioFormat.float32,
                                    2,
                                    48000,
                                    5,
                                  );
                                  generator.setWaveform(
                                      WaveformType.sine, 432, 0.5);
                                  setState(() {
                                    generator.isInit = true;
                                  });
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                  onChangeEnd: (value) =>
                                      generator.setPulsewave(
                                    432.0,
                                    0.5,
                                    pulseDelay,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      final frames = generator.getAvailableFrames();
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
      AudioFormat.float32,
      recorder.sampleRate,
      recorder.channels,
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
