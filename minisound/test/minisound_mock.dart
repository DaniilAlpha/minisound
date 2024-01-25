import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

// minisound mock

class MinisoundMock extends MinisoundPlatform {
  @override
  PlatformEngine createEngine() => EngineMock();
}

// engine mock

enum EngineState { uninit, init, started }

class EngineMock implements PlatformEngine {
  var state = EngineState.uninit;

  @override
  void dispose() => state = EngineState.uninit;

  @override
  Future<void> init(int periodMs) async {
    if (state != EngineState.uninit) {
      throw MinisoundPlatformException("cannot init engine");
    }
    state = EngineState.init;
  }

  @override
  Future<PlatformSound> loadSound(Uint8List data) async {
    if (state == EngineState.uninit) {
      throw MinisoundPlatformException("cannot load sound");
    }
    return SoundMock(data);
  }

  @override
  void start() {
    if (state != EngineState.init && state != EngineState.started) {
      throw MinisoundPlatformException("cannot start engine");
    }
    state = EngineState.started;
  }
}

// sound mock

enum SoundState { playing, paused, stopped }

class SoundMock implements PlatformSound {
  SoundMock(this.data);

  final Uint8List data;

  var state = SoundState.stopped;

  @override
  var volume = 1;

  @override
  double get duration => double.infinity;

  @override
  bool get isLooped => false;
  @override
  set isLooped(bool value) {}

  @override
  void play() => state = SoundState.playing;

  @override
  void pause() => state = SoundState.paused;

  @override
  void stop() => state = SoundState.stopped;

  @override
  void unload() {}
}
