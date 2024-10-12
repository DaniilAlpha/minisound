part of "minisound_platform_interface.dart";

class AudioData {
  AudioData(this.buffer);

  final TypedData buffer;
}

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformSound> loadSound(AudioData audioData);
  PlatformSound generateWaveform(
      {required WaveformType type, required double freq});
  PlatformSound generateNoise({required NoiseType type, required int seed});
  PlatformSound generatePulse({
    required double freq,
    required double dutyCycle,
  });
}
