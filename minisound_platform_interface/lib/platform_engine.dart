part of "minisound_platform_interface.dart";

class AudioData {
  AudioData(this.buffer, this.format, this.sampleRate, this.channels);
  AudioData.detectFromBuffer(this.buffer)
      : format = SoundFormat.f32,
        sampleRate = 0,
        channels = 0;

  final Float32List buffer;
  final SoundFormat format;
  final int sampleRate;
  final int channels;
}

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformSound> loadSound(AudioData audioData);
}
