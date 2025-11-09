part of "minisound_platform_interface.dart";

enum RecordingFormat { u8, s16, s24, s32, f32 }

abstract interface class PlatformRecorder {
  factory PlatformRecorder() => MinisoundPlatform.instance.createRecorder();

  bool get isRecording;

  Future<void> init();
  void dispose();

  void start({
    required RecordingFormat format,
    required int channelCount,
    required int sampleRate,
  });
  PlatformRecording stop();
}

abstract interface class PlatformRecording {
  Uint8List get buffer;

  void dispose();
}
