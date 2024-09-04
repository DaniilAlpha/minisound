// ignore_for_file: avoid_print

import "dart:async";
import "dart:typed_data";

import "package:example/widgets/playback_example.dart";
import "package:flutter/material.dart";
import "package:minisound/engine.dart";
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
  late final recorder = Recorder();
  late final generator = Generator(mainEngine: engine);

  late final initFuture = engine
      .init()
      .then((_) => recorder.initStream(channels: 1))
      .then((_) => generator.init());

  final List<Float32List> recordingBuffer = [];
  Timer? recorderTimer;
  Timer? generatorTimer;
  int totalRecordedFloats = 0;

  final List<Float32List> generatorBuffer = [];
  GeneratorWaveformType waveformType = GeneratorWaveformType.sine;
  GeneratorNoiseType noiseType = GeneratorNoiseType.white;
  bool enableWaveform = false;
  bool enableNoise = false;
  bool enablePulse = false;
  var pulseDelay = 0.25;
  final List<Sound> sounds = [];

  void accumulateRecorderFloats() {
    if (recorder.isRecording) {
      final floats = recorder.availableFloatCount;
      final buffer = recorder.getBuffer(floats);
      if (buffer.isNotEmpty) {
        recordingBuffer.add(buffer);
        totalRecordedFloats += floats;
      }
    }
  }

  void accumulateGeneratorFloats() {
    if (generator.isGenerating) {
      final floats = generator.availableFloatCount;
      final buffer = generator.getBuffer(floats);
      if (buffer.isNotEmpty) {
        generatorBuffer.add(buffer);
        totalRecordedFloats += floats;
      }
    }
  }

  Future<Sound> createSoundFromRecorder(Recorder recorder) async {
    if (sounds.isNotEmpty) {
      sounds.last.stop();
      sounds.last.unload();
    }

    final totalFloats =
        recordingBuffer.fold(0, (sum, chunk) => sum + chunk.length);

    final combinedBuffer = Float32List(totalFloats);

    var offset = 0;
    for (final chunk in recordingBuffer) {
      combinedBuffer.setAll(offset, chunk);
      offset += chunk.length;
    }

    print("Combined buffer length: ${combinedBuffer.length}");
    print("Total recorded frames: $totalFloats");

    final audioData = AudioData(
      combinedBuffer.buffer.asFloat32List(),
      SoundFormat.f32,
      // TODO! replace placeholder values
      44100,
      1,
    );

    recordingBuffer.clear();
    sounds.add(await engine.loadSound(audioData));
    return sounds.last;
  }

  @override
  void dispose() {
    recorder.dispose();
    generator.dispose();
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
                  // playback
                  PlaybackExample(engine),

                  space,

                  // recorder
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
                          await engine.start();
                          final testSound =
                              await createSoundFromRecorder(recorder);
                          testSound.play();
                        } on Exception catch (e) {
                          print("Error: $e");
                        } finally {
                          setState(() {
                            recorder.stop();
                          });
                          recorderTimer!.cancel();

                          recordingBuffer.clear();
                          totalRecordedFloats = 0;
                        }
                      } else {
                        if (!recorder.isInit) {}
                        setState(() {
                          recorder.start();
                        });
                        recorderTimer = Timer.periodic(
                          const Duration(milliseconds: 50),
                          (_) => accumulateRecorderFloats(),
                        );
                        totalRecordedFloats = 0;
                      }
                    },
                  ),

                  space,

                  // generator
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
                                  child: Text(type.toString().split(".").last),
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
                    child: Text(generator.isGenerating ? "STOP" : "START"),
                    onPressed: () async {
                      if (generator.isGenerating) {
                        setState(() {
                          generator.stop();
                          generatorTimer!.cancel();
                        });
                      } else {
                        generator.setWaveform();
                        setState(() {
                          generator.start();
                          generatorTimer = Timer.periodic(
                            const Duration(milliseconds: 100),
                            (_) => accumulateGeneratorFloats(),
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
