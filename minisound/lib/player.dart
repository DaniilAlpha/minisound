import "dart:math";
import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound/src/player_io.dart"
    if (dart.library.io) "package:minisound/src/dummy.dart";
export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        AudioEncoding,
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        NoiseType,
        SampleFormat,
        WaveformType;

part "sound.dart";

/// Controls loading, unloading and generating of `Sound`s.
///
/// Should be initialized before doing anything.
/// Should be started to hear any sound.
final class Player {
  Player() {
    _finalizer.attach(this, _engine);
  }

  static final _finalizer =
      Finalizer<PlatformEngine>((engine) => engine.dispose());
  static final _soundsFinalizer =
      Finalizer<PlatformSound>((sound) => sound.unload());

  final _engine = PlatformEngine();

  /// Initializes the engine.
  ///
  /// `periodMs` - affects sounds latency (lower period means lower latency but possibble crackles). Clamped between `1` and `1000` (1s). Probably has no effect on the web.
  Future<void> init([int periodMs = 32]) =>
      _engine.init(periodMs.clamp(1, 1000));

  /// Starts the engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSound(TypedData audioData) async {
    final platformSound = await _engine.loadSound(audioData);
    final sound = LoadedSound._(platformSound);
    _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }

  /// Generates a waveform sound with provided `type` and `freq`.
  WaveformSound genWaveform(WaveformType type, {double freq = 440.0}) {
    final platformSound = _engine.generateWaveform();
    final sound = WaveformSound._(platformSound);
    _soundsFinalizer.attach(sound, platformSound);
    return sound
      ..type = type
      ..freq = freq;
  }

  /// Generates a noise with the provided `type`.
  NoiseSound genNoise(NoiseType type) {
    final platformSound = _engine.generateNoise(type);
    final sound = NoiseSound._(platformSound);
    _soundsFinalizer.attach(sound, platformSound);
    return sound;
  }

  /// Generates a pulsewave sound with provided `freq` and `dutyCycle`.
  @Deprecated(
      "This is a part of a non-consistent API, so probably will be removed in the future. Use `generateWaveform` with `WaveformType.square` instead. In case you are really relying on the variable duty cycle, create a GitHub issue explaining your usecase and I will bring this capability into regular waveforms.")
  PulseSound genPulse({double freq = 440.0, double dutyCycle = 0.5}) {
    final platformSound = _engine.generatePulse();
    final sound = PulseSound._(platformSound);
    _soundsFinalizer.attach(sound, platformSound);
    return sound
      ..freq = freq
      ..dutyCycle = dutyCycle;
  }
}
