import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";
export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        AudioData,
        AudioFormat,
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        NoiseType,
        WaveformType;

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
  var isInit = false;

  /// Initializes an engine.
  ///
  /// Change an update period (affects the sound latency).
  Future<void> init([int periodMs = 10]) async {
    if (isInit) throw EngineAlreadyInitError();

    await _engine.init(periodMs);
    isInit = true;
  }

  /// Starts an engine.
  Future<void> start() async => _engine.start();

  /// Copies `data` to the internal memory location and creates a `Sound` from it.
  Future<Sound> loadSound(AudioData audioData) async {
    final engineSound = await _engine.loadSound(audioData);
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

final class Recorder {
  @override
  Recorder({Engine? mainEngine})
      : engine = mainEngine ?? Engine(),
        _recorder = MinisoundPlatform.instance.createRecorder() {
    if (!engine.isInit) {
      initEngine();
    }
  }

  final PlatformRecorder _recorder;
  Engine engine;
  late int sampleRate;
  late int channels;
  late int format;
  late int bufferDurationSeconds;
  bool isInit = false;

  /// Initializes the recorder's engine.
  Future<void> initEngine([int periodMs = 10]) async {
    await engine.init(periodMs);
  }

  /// Initializes the recorder to save to a file.
  Future<void> initFile(String filename,
      {int sampleRate = 44800,
      int channels = 1,
      int format = AudioFormat.float32}) async {
    if (sampleRate <= 0 || channels <= 0) {
      throw ArgumentError("Invalid recorder parameters");
    }
    if (!isInit) {
      this.sampleRate = sampleRate;
      this.channels = channels;
      this.format = format;
      await _recorder.initFile(filename,
          sampleRate: sampleRate, channels: channels, format: format);
      isInit = true;
    }
  }

  /// Initializes the recorder for streaming.
  Future<void> initStream(
      {int sampleRate = 44800,
      int channels = 1,
      int format = AudioFormat.float32,
      int bufferDurationSeconds = 5}) async {
    if (sampleRate <= 0 || channels <= 0 || bufferDurationSeconds <= 0) {
      throw ArgumentError("Invalid recorder parameters");
    }
    if (!isInit) {
      this.sampleRate = sampleRate;
      this.channels = channels;
      this.format = format;
      this.bufferDurationSeconds = bufferDurationSeconds;
      print(
          "creating record with $sampleRate, $channels, $format, $bufferDurationSeconds");
      await _recorder.initStream(
          sampleRate: sampleRate,
          channels: channels,
          format: format,
          bufferDurationSeconds: bufferDurationSeconds);
      isInit = true;
    }
  }

  /// Starts recording.
  void start() => _recorder.start();

  /// Stops recording.
  void stop() => _recorder.stop();

  /// Checks if the recorder is currently recording.
  bool get isRecording => _recorder.isRecording;

  /// Gets the recorded buffer.
  Float32List getBuffer(int framesToRead) => _recorder.getBuffer(framesToRead);

  /// Gets available frames from the recorder.
  int getAvailableFrames() => _recorder.getAvailableFrames();

  /// Disposes of the recorder resources.
  void dispose() {
    _recorder.dispose();
  }
}

/// A generator for waveforms and noise.
final class Generator {
  Generator({Engine? mainEngine})
      : engine = mainEngine ?? Engine(),
        _generator = MinisoundPlatform.instance.createGenerator();

  double get volume => _generator.volume;
  set volume(double value) => _generator.volume = value < 0 ? 0 : value;

  final PlatformGenerator _generator;
  late Engine engine;
  bool isInit = false;

  /// Initializes the generator's engine.
  Future initEngine([int periodMs = 10]) async {
    await engine.init(periodMs);
  }

  /// Initializes the generator.
  Future<void> init(int format, int channels, int sampleRate,
      int bufferDurationSeconds) async {
    if (!engine.isInit) {
      await initEngine();
    }
    if (!isInit) {
      await _generator.init(
          format, channels, sampleRate, bufferDurationSeconds);
      isInit = true;
    }
  }

  /// Sets the waveform type, frequency, and amplitude.
  void setWaveform(WaveformType type, double frequency, double amplitude) =>
      _generator.setWaveform(type, frequency, amplitude);

  /// Sets the pulse wave frequency, amplitude, and duty cycle.
  void setPulsewave(double frequency, double amplitude, double dutyCycle) =>
      _generator.setPulsewave(frequency, amplitude, dutyCycle);

  /// Sets the noise type, seed, and amplitude.
  void setNoise(NoiseType type, int seed, double amplitude) =>
      _generator.setNoise(type, seed, amplitude);

  /// Starts the generator.
  void start() => _generator.start();

  /// Stops the generator.
  void stop() => _generator.stop();

  /// Reads generated data.
  Float32List getBuffer(int framesToRead) => _generator.getBuffer(framesToRead);

  /// Gets the number of available frames in the generator's buffer.
  int getAvailableFrames() => _generator.getAvailableFrames();

  /// Disposes of the generator resources.
  void dispose() {
    _generator.dispose();
  }
}

class EngineAlreadyInitError extends Error {
  EngineAlreadyInitError([this.message]);

  final String? message;

  @override
  String toString() =>
      message == null ? "Engine already init" : "Engine already init: $message";
}
