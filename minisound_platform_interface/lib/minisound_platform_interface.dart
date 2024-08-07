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
  PlatformGenerator createGenerator();
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
      int bufferDurationSeconds = 5});
  void start();
  void stop();
  int getAvailableFrames();
  bool get isRecording;
  Float32List getBuffer(int framesToRead);
  void dispose();
}

enum WaveformType {
  sine,
  square,
  triangle,
  sawtooth,
}

enum NoiseType {
  white,
  pink,
  brownian,
}

abstract interface class PlatformGenerator {
  factory PlatformGenerator() => MinisoundPlatform.instance.createGenerator();
  Future<void> init(
      int format, int channels, int sampleRate, int bufferDurationSeconds);
  void setWaveform(WaveformType type, double frequency, double amplitude);
  void setPulsewave(double frequency, double amplitude, double dutyCycle);
  void setNoise(NoiseType type, int seed, double amplitude);
  void start();
  void stop();
  Float32List getBuffer(int framesToRead);
  int getAvailableFrames();
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

  final Float32List buffer;
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

abstract class Result {
  static const int Ok = 0;
  static const int UnknownErr = 1;
  static const int OutOfMemErr = 2;
  static const int RangeErr = 3;
  static const int HashCollisionErr = 4;
  static const int FileUnavailableErr = 5;
  static const int FileReadingErr = 6;
  static const int FileWritingErr = 7;
  static const int FormatErr = 8;
  static const int ArgErr = 9;
  static const int StateErr = 10;
  static const int RESULT_COUNT = 11;
}

abstract class RecorderResult {
  static const int RECORDER_OK = 0;
  static const int RECORDER_ERROR_UNKNOWN = 1;
  static const int RECORDER_ERROR_OUT_OF_MEMORY = 2;
  static const int RECORDER_ERROR_INVALID_ARGUMENT = 3;
  static const int RECORDER_ERROR_ALREADY_RECORDING = 4;
  static const int RECORDER_ERROR_NOT_RECORDING = 5;
}

abstract class WaveResult {
  static const int WAVE_OK = 0;
  static const int WAVE_ERROR = 1;
}

abstract class GeneratorResult {
  static const int GENERATOR_OK = 0;
  static const int GENERATOR_ERROR = 1;
}
