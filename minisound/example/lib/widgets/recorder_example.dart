import "package:flutter/material.dart";
import "package:minisound/engine.dart";

class RecorderExample extends StatefulWidget {
  const RecorderExample(this.engine, {super.key});

  final Engine engine;

  @override
  State<RecorderExample> createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample> {
  @override
  Widget build(BuildContext context) => const Placeholder();
  // final List<Sound> sounds = [];
  //
  // final List<Float32List> buf = [];
  // Timer? recorderTimer;
  // int totalFloats = 0;
  //
  // Future<Sound> createSoundFromRecorder(Recorder recorder) async {
  //   if (sounds.isNotEmpty) {
  //     sounds.last.stop();
  //     sounds.last.unload();
  //   }
  //
  //   final totalFloats = buf.fold(0, (sum, chunk) => sum + chunk.length);
  //
  //   final combinedBuffer = Float32List(totalFloats);
  //
  //   var offset = 0;
  //   for (final chunk in buf) {
  //     combinedBuffer.setAll(offset, chunk);
  //     offset += chunk.length;
  //   }
  //
  //   print("Combined buffer length: ${combinedBuffer.length}");
  //   print("Total recorded frames: $totalFloats");
  //
  //   final audioData = AudioData(
  //     combinedBuffer.buffer.asFloat32List(),
  //     SoundFormat.f32,
  //     // TODO! replace placeholder values
  //     44100,
  //     1,
  //   );
  //
  //   buf.clear();
  //   sounds.add(await widget.engine.loadSound(audioData));
  //   return sounds.last;
  // }
  //
  // void accumulateFloats() {
  //   if (widget.recorder.isRecording) {
  //     final floats = widget.recorder.availableFloatCount;
  //     final currentBuffer = widget.recorder.getBuffer(floats);
  //     if (currentBuffer.isNotEmpty) {
  //       buf.add(currentBuffer);
  //       totalFloats += floats;
  //     }
  //   }
  // }
  //
  // @override
  // Widget build(BuildContext context) => Column(children: [
  //       Text("Recorder", style: Theme.of(context).textTheme.headlineMedium),
  //       ElevatedButton(
  //         child: Text(
  //           widget.recorder.isRecording ? "STOP RECORDING" : "START RECORDING",
  //         ),
  //         onPressed: () async {
  //           if (widget.recorder.isRecording) {
  //             try {
  //               await widget.engine.start();
  //               final testSound =
  //                   await createSoundFromRecorder(widget.recorder);
  //               testSound.play();
  //             } on Exception catch (e) {
  //               print("Error: $e");
  //             } finally {
  //               setState(() {
  //                 widget.recorder.stop();
  //               });
  //               recorderTimer!.cancel();
  //
  //               buf.clear();
  //               totalFloats = 0;
  //             }
  //           } else {
  //             if (!widget.recorder.isInit) {}
  //             setState(() {
  //               widget.recorder.start();
  //             });
  //             recorderTimer = Timer.periodic(
  //               const Duration(milliseconds: 50),
  //               (_) => accumulateFloats(),
  //             );
  //             totalFloats = 0;
  //           }
  //         },
  //       ),
  //     ]);
}
