part of "engine.dart";

abstract class Sound {
  Sound();

  PlatformSound get _sound;

  /// A `double` greater than `0` (values greater than `1` may behave differently from platform to platform).
  double get volume => _sound.volume;
  set volume(double value) => _sound.volume = value < 0 ? 0 : value;

  bool get isPlaying => _sound.isPlaying;

  /// Starts the sound. Continues if was paused.
  void resume() => _sound.play();

  /// Stop the sound, but keep it's position.
  ///
  /// If sound is looped, when played again will wait `loopDelay` and play. If you do not want this, use `stop()`.
  void pause() => _sound.pause();

  /// Stops the sound and resets it's position.
  void stop() => _sound.stop();

  /// Starts the sound. Played from the beginning if was paused.
  @nonVirtual
  void play() {
    stop();
    resume();
  }

  @Deprecated("Only use if loading sound WITHOUT auto management.")
  void unload() => _sound.unload();
}

/// A sound loaded from some kind of source.
class LoadedSound extends Sound {
  LoadedSound._(PlatformEncodedSound sound) : _sound = sound;

  @override
  final PlatformEncodedSound _sound;

  Duration get duration =>
      Duration(milliseconds: (_sound.duration * 1000).toInt());
  Duration get position =>
      // TODO? maybe increase resolution?
      Duration(milliseconds: (_sound.position * 1000).toInt());

  /// Returns the current loop delay, or `null` if not looped (or not playing at all).
  Duration? get loopDelay =>
      !_sound.looping.$1 ? null : Duration(milliseconds: _sound.looping.$2);

  /// Starts sound with looping.
  ///
  /// `delay` - delay before sound will be played again. Clamped positive.
  void playLooped({Duration delay = Duration.zero}) {
    super.pause();
    final delayMs = delay < Duration.zero ? 0 : delay.inMilliseconds;
    if (!_sound.looping.$1 || _sound.looping.$2 != delayMs) {
      _sound.looping = (true, delayMs);
    }
    super.resume();
  }

  @override
  void stop() {
    if (_sound.looping.$1) _sound.looping = (false, 0);
    super.stop();
  }
}

abstract class GeneratedSound extends Sound {}

class WaveformSound extends GeneratedSound {
  WaveformSound._(PlatformWaveformSound sound) : _sound = sound;

  @override
  final PlatformWaveformSound _sound;

  WaveformType get type => _sound.type;
  set type(WaveformType value) => _sound.type = value;

  /// Waveform frequency. Corresponds to pitch.
  double get freq => _sound.freq;
  set freq(double value) => _sound.freq = value < 0 ? 0 : value;
}

class NoiseSound extends GeneratedSound {
  NoiseSound._(PlatformNoiseSound sound) : _sound = sound;

  @override
  final PlatformNoiseSound _sound;

  NoiseType get type => _sound.type;
}

class PulseSound extends GeneratedSound {
  PulseSound._(PlatformPulseSound sound) : _sound = sound;

  @override
  final PlatformPulseSound _sound;

  /// Waveform frequency. Corresponds to pitch.
  double get freq => _sound.freq;
  set freq(double value) => _sound.freq = value < 0 ? 0 : value;

  /// Duty cycle of the pulsewave. Percentage of the cycle in which wave is in the high state. Clamped between 0 and 1.
  ///
  /// `0.0` and `1.0` will probably not be heard.
  /// `0.5` will sound exactly like a square wave with the same frequency.
  double get dutyCycle => _sound.dutyCycle;
  set dutyCycle(double value) => _sound.dutyCycle = value.clamp(0, 1);
}
