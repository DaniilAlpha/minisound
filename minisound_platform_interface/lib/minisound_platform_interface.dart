import "dart:typed_data";

import "package:plugin_platform_interface/plugin_platform_interface.dart";

abstract class MinisoundPlatform extends PlatformInterface {
  MinisoundPlatform() : super(token: _token);

  static final _token = Object();

  static late MinisoundPlatform _instance;
  static MinisoundPlatform get instance => _instance;
  static set instance(MinisoundPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  PlatformEngine createEngine();
  PlatformRecorder createRecorder();
  PlatformWave createWave();
}

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformSound> loadSound(AudioData audioData);
}

typedef PlatformSoundLooping = (bool isLooped, int delayMs);

abstract interface class PlatformSound {
  double get volume;
  set volume(double value);

  double get duration;

  PlatformSoundLooping get looping;
  set looping(PlatformSoundLooping value);

  void unload();

  void play();
  void replay();
  void pause();
  void stop();
}

abstract interface class PlatformRecorder {
  factory PlatformRecorder() => MinisoundPlatform.instance.createRecorder();

  Future<void> initFile(String filename,
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32});
  Future<void> initStream(
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32,
      double bufferDurationSeconds = 5});
  void start();
  void stop();
  bool get isRecording;
  Uint8List getBuffer(int framesToRead);
  void dispose();
}

abstract interface class PlatformWave {
  factory PlatformWave() => MinisoundPlatform.instance.createWave();

  Future<void> init(
      int type, double frequency, double amplitude, int sampleRate);
  void setType(int type);
  void setFrequency(double frequency);
  void setAmplitude(double amplitude);
  void setSampleRate(int sampleRate);
  Float32List read(int framesToRead);
  void dispose();
}

base class MinisoundPlatformException implements Exception {
  MinisoundPlatformException([this.message]);

  final String? message;

  @override
  String toString() => message == null
      ? "Minisound platform exception"
      : "Minisound platform exception: $message";
}

final class MinisoundPlatformOutOfMemoryException
    extends MinisoundPlatformException {
  MinisoundPlatformOutOfMemoryException([String? message])
      : super(message == null ? "out of memory" : "out of memory: $message");
}

class AudioData {
  AudioData(this.buffer, this.format, this.sampleRate, this.channels);

  final ByteBuffer buffer;
  final AudioFormat format;
  final int sampleRate;
  final int channels;
}

enum AudioFormat {
  uint8,
  int16,
  int32,
  float32,
  float64,
}

class MaFormat {
  static const int ma_format_unknown = 0;
  static const int ma_format_u8 = 1;
  static const int ma_format_s16 = 2;
  static const int ma_format_s24 = 3;
  static const int ma_format_s32 = 4;
  static const int ma_format_f32 = 5;
  static const int ma_format_f64 = 6;
}

int convertToMaFormat(AudioFormat format) {
  switch (format) {
    case AudioFormat.uint8:
      return MaFormat.ma_format_u8;
    case AudioFormat.int16:
      return MaFormat.ma_format_s16;
    case AudioFormat.int32:
      return MaFormat.ma_format_s32;
    case AudioFormat.float32:
      return MaFormat.ma_format_f32;
    case AudioFormat.float64:
      return MaFormat.ma_format_f64;
    default:
      return MaFormat.ma_format_unknown;
  }
}
