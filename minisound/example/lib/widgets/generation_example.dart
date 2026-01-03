import "dart:math";

import "package:example/widgets/sound_widget.dart";
import "package:flutter/material.dart";
import "package:minisound/engine.dart";
import "package:minisound/engine_flutter.dart";

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
  Widget build(BuildContext context) => Column(children: [
        Text("Generation", style: Theme.of(context).textTheme.headlineMedium),
        DropdownButton(
          items: GeneratorType.values
              .where((e) => e != GeneratorType.pulse)
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          value: generatorType,
          onChanged: (type) => setState(() {
            generatorType = type!;

            sound?.stop();
            sound = null;
          }),
        ),
        Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(children: [
              switch (generatorType) {
                GeneratorType.wave => Column(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text("Waveform Type: "),
                      DropdownButton(
                        value: waveformType,
                        items: WaveformType.values
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t.name)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          value!;

                          waveformType = value;
                          (sound as WaveformSound?)?.type = value;
                        }),
                      ),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text("Frequency: "),
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
                            (sound as WaveformSound?)?.freq =
                                pow(2, value).toDouble();
                          }),
                        ),
                      ),
                    ]),
                  ]),
                GeneratorType.noise => Column(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text("Noise Type: \n(changes after regen) "),
                      DropdownButton(
                        value: noiseType,
                        items: NoiseType.values
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t.name)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          noiseType = value!;
                        }),
                      ),
                    ]),
                  ]),
                GeneratorType.pulse => Column(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text("Frequency: "),
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
                            (sound as PulseSound?)?.freq =
                                pow(2, value).toDouble();
                          }),
                        ),
                      ),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text("Duty Cycle: "),
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
                            (sound as PulseSound?)?.dutyCycle =
                                value.clamp(0.01, 0.99);
                          }),
                        ),
                      ),
                    ]),
                  ]),
              },
              SizedBox.square(dimension: 16),
              OverflowBar(children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    await widget.engine.start();

                    sound?.stop();
                    sound = switch (generatorType) {
                      GeneratorType.wave => widget.engine.genWaveform(
                          waveformType,
                          freq: pow(2, freq).toDouble(),
                        ),
                      GeneratorType.noise => widget.engine.genNoise(noiseType),
                      GeneratorType.pulse => null,
                    }
                      ?..volume = 0.3;
                    sound?.play();
                  },
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.stop),
                  onPressed: () => sound?.stop(),
                ),
              ]),
            ]),
          ),
        ),
      ]);
}
