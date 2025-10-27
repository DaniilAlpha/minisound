part of "minisound_platform_interface.dart";

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformEncodedSound> loadSound(TypedData data);
  PlatformWaveformSound generateWaveform();
  PlatformNoiseSound generateNoise(NoiseType type);
  PlatformPulseSound generatePulse();
}

enum WaveformType { sine, square, triangle, sawtooth }

enum NoiseType { white, pink, brownian }
