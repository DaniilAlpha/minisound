import "dart:io";

import "package:minisound_platform_interface/minisound_platform_interface.dart";
export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        AudioData,
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException;

/// Controls the loading and unloading of `Sound`s.
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
  /// Change an update period (affects the sound latency).
  Future<void> init([int periodMs = 10]) async {
    if (_isInit) return;

    await _engine.init(periodMs);
    _isInit = true;
  }

  /// Starts the engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSound(AudioData audioData) async {
    final engineSound = await _engine.loadSound(audioData);
    final sound = Sound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Loads a sound file and creates a `Sound` from it.
  Future<Sound> loadSoundFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return loadSound(AudioData(bytes));
  }

  /// Generates a waveform sound using given parameters.
  Sound generateWaveform({
    WaveformType type = WaveformType.sine,
    double freq = 440.0,
  }) {
    final engineSound = _engine.generateWaveform(type: type, freq: freq);
    final sound = Sound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Generates a noise sound using given parameters.
  Sound generateNoise({NoiseType type = NoiseType.white, int seed = 0}) {
    final engineSound = _engine.generateNoise(type: type, seed: seed);
    final sound = Sound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }

  /// Generates a pulsewave sound using given parameters.
  Sound generatePulse({double freq = 440.0, double dutyCycle = 0.5}) {
    final engineSound = _engine.generatePulse(freq: freq, dutyCycle: dutyCycle);
    final sound = Sound._(engineSound);
    _soundsFinalizer.attach(this, sound);
    return sound;
  }
}

/// A sound.
final class Sound {
  Sound._(PlatformSound sound) : _sound = sound;

  final PlatformSound _sound;

  /// a `double` greater than `0` (values greater than `1` may behave differently from platform to platform)
  double get volume => _sound.volume;
  set volume(double value) => _sound.volume = value < 0 ? 0 : value;

  Duration get duration =>
      Duration(milliseconds: (_sound.duration * 1000).toInt());

  bool get isLooped => _sound.looping.$1;
  Duration get loopDelay => Duration(milliseconds: _sound.looping.$2);

  /// Starts the sound. Stopped and played again if it is already started.
  void play() {
    if (_sound.looping.$1) _sound.looping = (false, 0);

    _sound.replay();
  }

  /// Starts sound looping.
  ///
  /// `delay` is clamped positive
  void playLooped({Duration delay = Duration.zero}) {
    final delayMs = delay < Duration.zero ? 0 : delay.inMilliseconds;
    if (!_sound.looping.$1 || _sound.looping.$2 != delayMs) {
      _sound.looping = (true, delayMs);
    }

    _sound.play();
  }

  /// Like `stop()`, but does not reset a sound position.
  ///
  /// If sound is looped, when played again will wait `loopDelay` and play. If you do not want this, use `stop()`.
  void pause() {
    if (_sound.looping.$1) _sound.looping = (false, 0);

    _sound.pause();
  }

  /// Stops sound and resets a sound position.
  ///
  /// If sound is looped, when played again will NOT wait `loopDelay` and play. If you do not want this, use `pause()`.
  void stop() {
    if (_sound.looping.$1) _sound.looping = (false, 0);

    _sound.stop();
  }

  void unload() => _sound.unload();
}
