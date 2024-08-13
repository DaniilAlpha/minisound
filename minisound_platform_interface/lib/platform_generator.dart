part of "minisound_platform_interface.dart";

enum GeneratorWaveformType { sine, square, triangle, sawtooth }

enum GeneratorNoiseType { white, pink, brownian }

abstract interface class PlatformGenerator {
  factory PlatformGenerator() => MinisoundPlatform.instance.createGenerator();

  double get volume;
  set volume(double value);

  Future<void> init({
    required SoundFormat format,
    required int channels,
    required int sampleRate,
    required double bufferDurationSeconds,
  });
  void dispose();

  void setWaveform({
    required GeneratorWaveformType type,
    required double frequency,
    required double amplitude,
  });
  void setPulsewave({
    required double frequency,
    required double amplitude,
    required double dutyCycle,
  });
  void setNoise({
    required GeneratorNoiseType type,
    required double amplitude,
    required int seed,
  });

  void start();
  void stop();

  int get availableFloatCount;
  Float32List getBuffer(int floatsToRead);
}
