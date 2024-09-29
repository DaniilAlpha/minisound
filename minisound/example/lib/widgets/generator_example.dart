import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/generator.dart";

enum GeneratorType { wave, noise, pulse }

class GeneratorExample extends StatefulWidget {
  const GeneratorExample(this.engine, this.generator, {super.key});

  final Engine engine;
  final Generator generator;

  @override
  State<GeneratorExample> createState() => _GeneratorExampleState();
}

class _GeneratorExampleState extends State<GeneratorExample> {
  static const pulsewaveFrequency = 432.0;

  var generatorType = GeneratorType.wave;
  var waveformType = GeneratorWaveformType.sine;
  var noiseType = GeneratorNoiseType.white;
  var pulseDelay = 0.25;

  final buf = <Float32List>[];
  var totalFloats = 0;

  Timer? timer;

  void accumulateFloats() {
    if (widget.generator.isGenerating) {
      final floats = widget.generator.availableFloatCount;
      final currentBuf = widget.generator.getBuffer(floats);
      if (currentBuf.isNotEmpty) {
        buf.add(currentBuf);
        totalFloats += floats;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium;
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text("Generator: ", style: headline),
        DropdownButton(
          style: headline,
          items: GeneratorType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          value: generatorType,
          onChanged: (type) {
            setState(() {
              generatorType = type!;
            });
            switch (generatorType) {
              case GeneratorType.wave:
                widget.generator.setWaveform(type: waveformType);

              case GeneratorType.noise:
                widget.generator.setNoise(type: noiseType);

              case GeneratorType.pulse:
                widget.generator.setPulsewave(
                  frequency: pulsewaveFrequency,
                  dutyCycle: pulseDelay,
                );
            }
          },
        ),
      ]),
      switch (generatorType) {
        GeneratorType.wave => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Waveform Type: "),
            DropdownButton(
              value: waveformType,
              items: GeneratorWaveformType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  waveformType = value!;
                });
                widget.generator.setWaveform(type: waveformType);
              },
            ),
          ]),
        GeneratorType.noise => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Noise Type: "),
            DropdownButton(
              value: noiseType,
              items: GeneratorNoiseType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  noiseType = value!;
                });
                widget.generator.setNoise(type: noiseType);
              },
            ),
          ]),
        GeneratorType.pulse => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Pulse Delay: "),
            SizedBox(
              width: 200,
              child: Slider(
                value: pulseDelay,
                divisions: 100,
                label: pulseDelay.toStringAsFixed(2),
                onChanged: (value) => setState(() {
                  pulseDelay = value;
                }),
                onChangeEnd: (value) => widget.generator.setPulsewave(
                  frequency: pulsewaveFrequency,
                  dutyCycle: value,
                ),
              ),
            ),
          ]),
      },
      ElevatedButton(
        child: Text(widget.generator.isGenerating ? "STOP" : "START"),
        onPressed: () async => setState(() {
          if (widget.generator.isGenerating) {
            timer?.cancel();
            widget.generator.stop();
          } else {
            widget.generator.start();
            timer ??= Timer.periodic(
              const Duration(milliseconds: 100),
              (_) => accumulateFloats(),
            );
          }
        }),
      ),
    ]);
  }
}
