part of "minisound_platform_interface.dart";

enum RecEncoding { /*raw,*/ wav }

enum RecFormat { u8, s16, s24, s32, f32 }

abstract interface class PlatformRec {
  void dispose();

  Uint8List read();
}

abstract interface class PlatformRecorder {
  factory PlatformRecorder(int maxRecCount) =>
      MinisoundPlatform.instance.createRecorder(maxRecCount);

  Future<void> init(int periodMs);
  void dispose();

  bool isRecording(PlatformRec rec);

  void start();

  PlatformRec record({
    required RecEncoding encoding,
    required RecFormat format,
    required int channelCount,
    required int sampleRate,
    required int dataAvailabilityThresholdMs,
    void Function() onDataAvailableFn,
    void Function() seekDataFn,
  });
  void pauseRec(PlatformRec rec);
  void resumeRec(PlatformRec rec);
  void stopRec(PlatformRec rec);
}
