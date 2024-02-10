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

abstract interface class PlatformSound {
  double get volume;
  set volume(double value);

  double get duration;

  bool get isLooped;
  set isLooped(bool value);

  void unload();

  void play();
  void pause();
  void stop();
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
