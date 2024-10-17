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
  // static const pulsewaveFrequency = 432.0;

  var generatorType = GeneratorType.wave;

  var waveformType = WaveformType.sine;
  var noiseType = NoiseType.white;
  var dutyCycle = 0.25;

  Sound? sound;

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
          }),
        ),
      ]),
      switch (generatorType) {
        GeneratorType.wave => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Waveform Type: "),
            DropdownButton(
              value: waveformType,
              items: WaveformType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() {
                waveformType = value!;
              }),
            ),
          ]),
        GeneratorType.noise => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Noise Type: "),
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
        GeneratorType.pulse => Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("Pulse Delay: "),
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
                }),
              ),
            ),
          ]),
      },
      ElevatedButton(
        child: const Text("PLAY"),
        onPressed: () {
          sound?.stop();
          sound = switch (generatorType) {
            GeneratorType.wave =>
              widget.engine.generateWaveform(type: waveformType),
            GeneratorType.noise => widget.engine.generateNoise(type: noiseType),
            GeneratorType.pulse =>
              widget.engine.generatePulse(dutyCycle: dutyCycle),
          }
            ..volume = 0.3;
          widget.engine.start().then((_) => sound!.play());
        },
      ),
      ElevatedButton(
          child: const Text("STOP"),
          onPressed: () {
            sound?.stop();
            sound = null;
          }),
    ]);
  }
}
