import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minisound/minisound.dart';
import 'package:minisound/minisound_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    title: 'Minisound Example',
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
  final recorder = Recorder();
  final generator = Generator();
  WaveformType waveformType = WaveformType.sine;
  NoiseType noiseType = NoiseType.white;
  bool isGenerating = false;
  bool isRecording = false;
  bool enableWaveform = false;
  bool enableNoise = false;
  bool enablePulse = false;
  final List<Float32List> recordingBuffer = [];
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
    }
    return engine.loadSoundAsset('assets/laser_shoot.wav');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Minisound Example')),
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
                            'Sound Playback',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            child: const Text('PLAY'),
                            onPressed: () async {
                              await engine.start();
                              sound.play();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('PAUSE'),
                            onPressed: () => sound.pause(),
                          ),
                          ElevatedButton(
                            child: const Text('STOP'),
                            onPressed: () => sound.stop(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Volume: '),
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
                            ],
                          ),
                          ElevatedButton(
                            child: const Text('PLAY LOOPED'),
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
                              const Text('Loop delay:'),
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
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Recorder',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            child: Text(
                              isRecording
                                  ? 'STOP RECORDING'
                                  : 'START RECORDING',
                            ),
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
                                  recordingBuffer.clear();
                                  totalRecordedFrames = 0;
                                }
                              } else {
                                if (recorder.isRecording) {
                                  recorder.stop();
                                }
                                if (!recorder.isInit) {
                                  print('Creating recorder');
                                  await recorder.initStream(
                                    sampleRate: 48000,
                                    channels: 1,
                                    format: AudioFormat.float32,
                                  );
                                  recorder.isInit = true;
                                }

                                recorder.start();
                                Timer.periodic(
                                  const Duration(milliseconds: 50),
                                  (_) => accumulateFrames(),
                                );

                                totalRecordedFrames = 0;
                              }

                              setState(() {
                                isRecording = !isRecording;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Generator',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Waveform Type: '),
                              DropdownButton<WaveformType>(
                                value: waveformType,
                                items: WaveformType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child:
                                        Text(type.toString().split('.').last),
                                  );
                                }).toList(),
                                onChanged: enableWaveform
                                    ? (value) {
                                        setState(() {
                                          waveformType = value!;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Noise Type: '),
                              DropdownButton<NoiseType>(
                                value: noiseType,
                                items: NoiseType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child:
                                        Text(type.toString().split('.').last),
                                  );
                                }).toList(),
                                onChanged: enableNoise
                                    ? (value) {
                                        setState(() {
                                          noiseType = value!;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Loop delay (Duty Cycle):'),
                              SizedBox(
                                width: 200,
                                child: Slider(
                                  value: loopDelay,
                                  min: 0,
                                  max: 3,
                                  divisions: 100,
                                  label: loopDelay.toStringAsFixed(2),
                                  onChanged: enablePulse
                                      ? (value) => setState(() {
                                            loopDelay = value;
                                          })
                                      : null,
                                ),
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
                                },
                              ),
                              const Text('Waveform'),
                              const Text('BEWARE VOLUME'),
                              const Text(
                                'FIXED SOON',
                              ),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: enableNoise,
                                onChanged: (value) {
                                  setState(() {
                                    enableNoise = value!;
                                  });
                                },
                              ),
                              const Text('Noise'),
                              const SizedBox(width: 20),
                              Checkbox(
                                value: enablePulse,
                                onChanged: (value) {
                                  setState(() {
                                    enablePulse = value!;
                                  });
                                },
                              ),
                              const Text('Pulse'),
                            ],
                          ),
                          ElevatedButton(
                            child: Text(isGenerating ? 'STOP' : 'START'),
                            onPressed: () async {
                              if (isGenerating) {
                                setState(() {
                                  isGenerating = false;
                                  generator.stop();
                                });
                              } else {
                                if (!generator.isInit) {
                                  await generator.init(
                                    AudioFormat.float32,
                                    2,
                                    48000,
                                    5,
                                  );
                                  generator.isInit = true;
                                }

                                if (enableWaveform) {
                                  generator.setWaveform(
                                    waveformType,
                                    440.0,
                                    0.5,
                                  );
                                }

                                if (enableNoise) {
                                  generator.setNoise(noiseType, 0, 0.5);
                                }

                                if (enablePulse) {
                                  generator.setPulsewave(440.0, 0.5, loopDelay);
                                }

                                setState(() {
                                  isGenerating = true;
                                  generator.start();
                                });

                                while (isGenerating) {
                                  final available =
                                      generator.getAvailableFrames();
                                  // print('Available frames: $available');
                                  // final frames = generator.getBuffer(available);
                                  //print('Generated ${frames.length} frames');
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('Error: ${snapshot.error}');
                  }
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
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

    int totalFrames =
        recordingBuffer.fold(0, (sum, chunk) => sum + chunk.length);

    combinedBuffer = Float32List(totalFrames);

    int offset = 0;
    for (var chunk in recordingBuffer) {
      combinedBuffer.setAll(offset, chunk);
      offset += chunk.length;
    }

    print('Combined buffer length: ${combinedBuffer.length}');
    print('Total recorded frames: $totalFrames');

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
