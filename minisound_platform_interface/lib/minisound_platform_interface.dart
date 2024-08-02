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
}

abstract interface class PlatformEngine {
  factory PlatformEngine() => MinisoundPlatform.instance.createEngine();

  Future<void> init(int periodMs);
  void dispose();

  void start();

  Future<PlatformSound> loadSound(Uint8List data);
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

  Future<void> initFile(String filename);
  Future<void> initStream();
  void start();
  void stop();
  bool get isRecording;
  Float32List getBuffer(int framesToRead);
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
