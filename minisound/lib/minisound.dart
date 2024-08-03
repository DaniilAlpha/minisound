import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show MinisoundPlatformException, MinisoundPlatformOutOfMemoryException;

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
  static final _recorderFinalizer =
      Finalizer<Recorder>((recorder) => recorder.dispose());
  static final _waveFinalizer = Finalizer<Wave>((wave) => wave.dispose());

  final _engine = PlatformEngine();
  var _isInit = false;

  /// Initializes an engine.
  ///
  /// Change an update period (affects the sound latency).
  Future<void> init([int periodMs = kIsWeb ? 33 : 10]) async {
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

  /// Creates a new Recorder instance.
  Recorder createRecorder() {
    final recorder = Recorder._();
    _recorderFinalizer.attach(this, recorder);
    return recorder;
  }

  /// Creates a new Wave instance.
  Wave createWave() {
    final wave = Wave._();
    _waveFinalizer.attach(this, wave);
    return wave;
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

  /// Starts a sound. Stopped and played again if it is already started.
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

  /// Does not reset a sound position.
  ///
  /// If sound is looped, when played again will wait `loopDelay` and play. If you do not want this, use `stop()`.
  void pause() {
    if (_sound.looping.$1) _sound.looping = (false, 0);

    _sound.pause();
  }

  /// Resets a sound position.
  ///
  /// If sound is looped, when played again will NOT wait `loopDelay` and play. If you do not want this, use `pause()`.
  void stop() {
    if (_sound.looping.$1) _sound.looping = (false, 0);

    _sound.stop();
  }

  void unload() => _sound.unload();
}

/// A recorder for audio input.
final class Recorder {
  Recorder._() : _recorder = PlatformRecorder();

  final PlatformRecorder _recorder;

  /// Initializes the recorder to save to a file.
  Future<void> initFile(String filename) async => _recorder.initFile(filename);

  /// Initializes the recorder for streaming.
  Future<void> initStream() async => _recorder.initStream();

  /// Starts recording.
  void start() => _recorder.start();

  /// Stops recording.
  void stop() => _recorder.stop();

  /// Checks if the recorder is currently recording.
  bool get isRecording => _recorder.isRecording;

  /// Gets the recorded buffer.
  Float32List getBuffer(int framesToRead) => _recorder.getBuffer(framesToRead);

  /// Disposes of the recorder resources.
  void dispose() => _recorder.dispose();
}

/// A wave generator.
final class Wave {
  Wave._() : _wave = PlatformWave();

  final PlatformWave _wave;

  /// Initializes the wave generator.
  Future<void> init(
          int type, double frequency, double amplitude, int sampleRate) async =>
      _wave.init(type, frequency, amplitude, sampleRate);

  /// Sets the wave type.
  void setType(int type) => _wave.setType(type);

  /// Sets the wave frequency.
  void setFrequency(double frequency) => _wave.setFrequency(frequency);

  /// Sets the wave amplitude.
  void setAmplitude(double amplitude) => _wave.setAmplitude(amplitude);

  /// Sets the wave sample rate.
  void setSampleRate(int sampleRate) => _wave.setSampleRate(sampleRate);

  /// Reads wave data.
  Float32List read(int framesToRead) => _wave.read(framesToRead);

  /// Disposes of the wave generator resources.
  void dispose() => _wave.dispose();
}

class EngineAlreadyInitError extends Error {
  EngineAlreadyInitError([this.message]);

  final String? message;

  @override
  String toString() =>
      message == null ? "Engine already init" : "Engine already init: $message";
}
