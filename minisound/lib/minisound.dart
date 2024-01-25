import "dart:io";

import "package:flutter/services.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show MinisoundPlatformException, MinisoundPlatformOutOfMemoryException;

/// Controls the loading and unloading of `Sound`s.
///
/// Should be initialized before doind anything.
/// Should be started to hear any sound.
final class Engine {
  Engine() {
    _finalizer.attach(this, _engine);
  }

  static final _finalizer =
      Finalizer<PlatformEngine>((engine) => engine.dispose());
  static final _soundsFinalizer = Finalizer<Sound>((sound) => sound.unload());

  final _engine = PlatformEngine();
  var _isInit = false;

  /// Initializes an engine.
  ///
  /// Change an update period (affects the sound latency).
  Future<void> init([int periodMs = 10]) async {
    if (_isInit) throw EngineAlreadyInitError();

    await _engine.init(periodMs);
    _isInit = true;
  }

  /// Starts an engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSound(Uint8List data) async {
    final sound = Sound._(await _engine.loadSound(data));
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Copies asset data to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSoundAsset(String path) async {
    final asset = await rootBundle.load(path);
    return loadSound(asset.buffer.asUint8List());
  }

  /// Copies file data to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSoundFile(String path) async {
    final file = await File(path).readAsBytes();
    return loadSound(file);
  }
}

/// A sound.
final class Sound {
  Sound._(PlatformSound sound) : _sound = sound;

  final PlatformSound _sound;

  /// a `double` greater than `0` (support for values greater than `1` is tested only on windows)
  double get volume => _sound.volume;
  set volume(double value) => _sound.volume = value < 0 ? 0 : value;

  late final duration =
      Duration(milliseconds: (_sound.duration * 1000).toInt());

  bool get isLooped => _sound.isLooped;
  set isLooped(bool value) => _sound.isLooped = value;
  void play() => _sound.play();

  /// Does not reset a sound position.
  void pause() => _sound.pause();

  /// Resets a sound position.
  void stop() => _sound.stop();

  void unload() => _sound.unload();
}

class EngineAlreadyInitError extends Error {
  EngineAlreadyInitError([this.message]);

  final String? message;

  @override
  String toString() =>
      message == null ? "Engine already init" : "Engine already init: $message";
}
