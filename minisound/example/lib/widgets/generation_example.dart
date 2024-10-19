import "dart:math";

import "package:flutter/material.dart";
import "package:minisound/engine.dart";

enum GeneratorType { wave, noise, pulse }

class GenerationExample extends StatefulWidget {
  const GenerationExample(this.engine, {super.key});

  final Engine engine;

  @override
  State<GenerationExample> createState() => _GenerationExampleState();
}

class _GenerationExampleState extends State<GenerationExample> {
  var generatorType = GeneratorType.wave;

  var waveformType = WaveformType.sine;
  var freq = 8.78, dutyCycle = 0.5;
  var noiseType = NoiseType.white;

  GeneratedSound? sound;

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium;
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text("Generation: ", style: headline),
        DropdownButton(
          style: headline,
          items: GeneratorType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          value: generatorType,
          onChanged: (type) => setState(() {
            generatorType = type!;

            sound?.unload();
            sound = null;
          }),
        ),
      ]),
      switch (generatorType) {
        GeneratorType.wave => Column(children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Waveform Type: "),
              DropdownButton(
                value: waveformType,
                items: WaveformType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (value) => setState(() {
                  value!;

                  waveformType = value;
                  (sound as WaveformSound?)?.type = value;
                }),
              ),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Frequency\n(changes immediately): "),
              SizedBox(
                width: 200,
                child: Slider(
                  value: freq,
                  min: 4,
                  max: 14,
                  divisions: (14 - 4) * 12,
                  label: pow(2, freq).toStringAsFixed(2),
                  onChanged: (value) => setState(() {
                    freq = value;
                    (sound as WaveformSound?)?.freq = pow(2, value).toDouble();
                  }),
                ),
              ),
            ]),
          ]),
        GeneratorType.noise => Column(children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Noise Type\n(changes after regen): "),
              DropdownButton(
                value: noiseType,
                items: NoiseType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (value) => setState(() {
                  noiseType = value!;
                }),
              ),
            ]),
          ]),
        GeneratorType.pulse => Column(children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Frequency\n(changes immediately): "),
              SizedBox(
                width: 200,
                child: Slider(
                  value: freq,
                  min: 4,
                  max: 14,
                  divisions: (14 - 4) * 12,
                  label: pow(2, freq).toStringAsFixed(2),
                  onChanged: (value) => setState(() {
                    freq = value;
                    (sound as PulseSound?)?.freq = pow(2, value).toDouble();
                  }),
                ),
              ),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text("Duty Cycle\n(changes immediately): "),
              SizedBox(
                width: 200,
                child: Slider(
                  min: 0,
                  max: 1,
                  value: dutyCycle,
                  divisions: 100,
                  label: dutyCycle.toStringAsFixed(2),
                  onChanged: (value) => setState(() {
                    dutyCycle = value;
                    (sound as PulseSound?)?.dutyCycle = value.clamp(0.01, 0.99);
                  }),
                ),
              ),
            ]),
          ]),
      },
      ElevatedButton(
        child: const Text("PLAY"),
        onPressed: () {
          sound?.stop();
          sound = switch (generatorType) {
            GeneratorType.wave => widget.engine.generateWaveform(
                type: waveformType,
                freq: pow(2, freq).toDouble(),
              ),
            GeneratorType.noise => widget.engine.generateNoise(type: noiseType),
            GeneratorType.pulse => widget.engine.generatePulse(
                dutyCycle: dutyCycle,
                freq: pow(2, freq).toDouble(),
              ),
          }
            ..volume = 0.3;
          widget.engine.start().then((_) => sound!.play());
        },
      ),
      ElevatedButton(
          child: const Text("STOP"),
          onPressed: () {
            sound?.unload();
            sound = null;
          }),
    ]);
  }
}
