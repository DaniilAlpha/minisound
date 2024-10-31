import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        NoiseType,
        WaveformType;

part "sound.dart";

/// Controls loading, unloading and generating of `Sound`s.
///
/// Should be initialized before doing anything.
/// Should be started to hear any sound.
final class Engine {
  Engine() {
    _finalizer.attach(this, _engine);
  }

  static final _finalizer =
      Finalizer<PlatformEngine>((engine) => engine.dispose());
  static final _soundsFinalizer =
      Finalizer<PlatformSound>((sound) => sound.unload());

  final _engine = PlatformEngine();

  var _isInit = false;
  bool get isInit => _isInit;

  /// Initializes the engine.
  ///
  /// `periodMs` - affects sounds latency (lower period means lower latency but possibble crackles). Must be greater than zero. Ignored on the web.
  Future<void> init([int periodMs = 10]) async {
    assert(periodMs > 0);

    if (_isInit) return;

    await _engine.init(periodMs);
    _isInit = true;

    // await _engine.test(
    //   await rootBundle.load("assets/kevin_macleod_call_to_adventure.mp3"),
    // );
  }

  /// Starts the engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSound(
    TypedData audioData, {
    @Deprecated("Should be used only in case something is not working.")
    bool doAddToFinalizer = true,
  }) async {
    final platformSound = await _engine.loadSound(audioData);
    final sound = LoadedSound._(platformSound);
    if (doAddToFinalizer) _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }

  /// Loads a file and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSoundFile(String filePath) async =>
      loadSound(await File(filePath).readAsBytes());

  /// Generates a waveform sound using given parameters.
  WaveformSound genWaveform(
    WaveformType type, {
    double freq = 440.0,
    @Deprecated(
        "Should be used only in special cases (see the migration guide in README).")
    bool doAddToFinalizer = true,
  }) {
    final platformSound = _engine.generateWaveform(type: type, freq: freq);
    final sound = WaveformSound._(platformSound);
    if (doAddToFinalizer) _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }

  /// Generates a noise sound using given parameters.
  NoiseSound genNoise(
    NoiseType type, {
    int seed = 0,
    @Deprecated(
        "Should be used only in special cases (see the migration guide in README).")
    bool doAddToFinalizer = true,
  }) {
    final platformSound = _engine.generateNoise(type: type, seed: seed);
    final sound = NoiseSound._(platformSound);
    if (doAddToFinalizer) _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }

  /// Generates a pulsewave sound using given parameters.
  PulseSound genPulse({
    double freq = 440.0,
    double dutyCycle = 0.5,
    @Deprecated(
        "Should be used only in special cases (see the migration guide in README).")
    bool doAddToFinalizer = true,
  }) {
    final platformSound =
        _engine.generatePulse(freq: freq, dutyCycle: dutyCycle);
    final sound = PulseSound._(platformSound);
    if (doAddToFinalizer) _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }
}
