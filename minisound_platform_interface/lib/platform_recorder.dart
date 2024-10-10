part of "minisound_platform_interface.dart";

/* abstract interface class PlatformRecorder {
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
    required double bufferLenS,
  });
  void dispose();

  void start();
  void stop();

  int get availableFloatCount;
  Float32List getBuffer(int floatsToRead);
} */
