part of "minisound_platform_interface.dart";

abstract interface class PlatformRecorder {
  factory PlatformRecorder() => MinisoundPlatform.instance.createRecorder();

  bool get isRecording;

  Future<void> initFile(
    String filename, {
    required int sampleRate,
    required int channels,
    required SoundFormat format,
  });
  Future<void> initStream({
    required int sampleRate,
    required int channels,
    required SoundFormat format,
    required int bufferDurationSeconds,
  });
  void dispose();

  void start();
  void stop();

  int getAvailableFrames();
  Float32List getBuffer(int framesToRead);
}
