part of "minisound_platform_interface.dart";

enum WaveformType { sine, square, triangle, sawtooth }

enum NoiseType { white, pink, brownian }

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  @deprecated
  Future<void> test(TypedData data);
  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformEncodedSound> loadSound(TypedData data);
  PlatformWaveformSound generateWaveform({
    required WaveformType type,
    required double freq,
  });
  PlatformNoiseSound generateNoise({
    required NoiseType type,
    required int seed,
  });
  PlatformPulseSound generatePulse({
    required double freq,
    required double dutyCycle,
  });
}
