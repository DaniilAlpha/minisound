import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart";
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
  static final _soundsFinalizer = Finalizer<Sound>((sound) => sound.unload());

  final _engine = PlatformEngine();

  var _isInit = false;
  bool get isInit => _isInit;

  /// Initializes the engine.
  ///
  /// `periodMs` - affects sounds latency (lower period means lower latency but possibly jittering). Must be greater than zero.
  Future<void> init([int periodMs = 10]) async {
    assert(periodMs > 0);

    if (_isInit) return;

    await _engine.init(periodMs);
    _isInit = true;
  }

  /// Starts the engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSound(TypedData audioData) async {
    final platformSound = await _engine.loadSound(audioData);
    final sound = LoadedSound._(platformSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Loads a file and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSoundFile(String filePath) async =>
      loadSound(await File(filePath).readAsBytes());

  /// Generates a waveform sound using given parameters.
  WaveformSound genWaveform(
    WaveformType type, {
    double freq = 440.0,
  }) {
    final engineSound = _engine.generateWaveform(type: type, freq: freq);
    final sound = WaveformSound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Generates a noise sound using given parameters.
  NoiseSound genNoise(NoiseType type, {int seed = 0}) {
    final engineSound = _engine.generateNoise(type: type, seed: seed);
    final sound = NoiseSound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Generates a pulsewave sound using given parameters.
  PulseSound genPulse({double freq = 440.0, double dutyCycle = 0.5}) {
    final engineSound = _engine.generatePulse(freq: freq, dutyCycle: dutyCycle);
    final sound = PulseSound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }
}
