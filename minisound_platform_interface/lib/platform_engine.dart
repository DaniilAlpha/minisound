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
  Future<PlatformSound> generateWaveform({
    required WaveformType type,
    required double frequency,
    required double amplitude,
  });
}
