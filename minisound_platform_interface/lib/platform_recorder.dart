part of "minisound_platform_interface.dart";

abstract interface class PlatformRec {
  Uint8List get data;

  Future<void> end();

  void dispose();
}

abstract interface class PlatformRecorder {
  factory PlatformRecorder(int maxRecCount) =>
      MinisoundPlatform.instance.createRecorder(maxRecCount);

  Future<void> init(int periodMs);
  void dispose();

  bool isRecording(PlatformRec rec);

  void start();

  Future<PlatformRec> saveRec({
    required AudioEncoding encoding,
    required SampleFormat sampleFormat,
    required int channelCount,
    required int sampleRate,
  });
  void resumeRec(PlatformRec rec);
  void pauseRec(PlatformRec rec);
}
