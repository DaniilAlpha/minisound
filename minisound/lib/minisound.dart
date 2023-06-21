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
  // TODO add finisher for automatic disposing

  final _engine = PlatformEngine();

  /// Initializes an engine.
  ///
  /// Change an update period (affects the sound latency).
  Future<void> init([int periodMs = 10]) => _engine.init(periodMs);

  /// Uninitializes an engine. Unload all sounds before doing this.
  ///
  /// Cannot be reinitialized.
  Future<void> dispose() async => _engine.dispose();

  /// Starts an engine.
  ///
  /// There is no `stop` function. Just call `dispose`.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSound(Uint8List data) async =>
      Sound._(await _engine.loadSound(data));

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

  /// Unloads a sound.
  Future<void> unloadSound(Sound sound) async =>
      _engine.unloadSound(sound._sound);
}

/// A sound.
///
/// Remember to unload sounds that you are not longer using.
final class Sound {
  // TODO add finisher for automatic unloading

  Sound._(PlatformSound sound) : _sound = sound;

  final PlatformSound _sound;

  /// a `double` between `0` and `1`
  double get volume => _sound.volume;
  set volume(double value) {
    if (value < 0 || value > 1) {
      throw ArgumentError(
          "Volume should be between 0 and 1 inclusive, but is now $value.");
    }
    _sound.volume = value;
  }

  late final duration =
      Duration(milliseconds: (_sound.duration * 1000).toInt());

  void play() => _sound.play();

  /// Does not reset a sound position.
  void pause() => _sound.pause();

  /// Resets a sound position.
  void stop() => _sound.stop();
}
