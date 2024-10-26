part of "minisound_ffi.dart";

sealed class FfiSound implements PlatformSound {
  FfiSound(Pointer<c.Sound> self) : _self = self;

  final Pointer<c.Sound> _self;

  late var _volume = _bindings.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    _bindings.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  void unload() {
    _bindings.sound_unload(_self);
    malloc.free(_self);
  }

  @override
  void play() {
    final r = _bindings.sound_play(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound (code: $r).");
    }
  }

  @override
  void pause() => _bindings.sound_pause(_self);
  @override
  void stop() => _bindings.sound_stop(_self);
}

final class FfiEncodedSound extends FfiSound implements PlatformEncodedSound {
  FfiEncodedSound._(super.self, {required Pointer data}) : _data = data;

  late final _soundData = _bindings.sound_get_encoded_data(_self);

  final Pointer _data;

  @override
  late final duration = _bindings.sound_get_duration(_self);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    _bindings.encoded_sound_data_set_looped(_soundData, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    super.unload();
    malloc.free(_data);
  }
}

final class FfiWaveformSound extends FfiSound implements PlatformWaveformSound {
  FfiWaveformSound._(
    super.self, {
    required WaveformType type,
    required double freq,
  })  : _type = type,
        _freq = freq;

  late final _soundData = _bindings.sound_get_waveform_data(_self);

  WaveformType _type;
  @override
  WaveformType get type => _type;
  @override
  set type(WaveformType value) {
    _bindings.waveform_sound_data_set_type(_soundData, value.toC());
    _type = value;
  }

  double _freq;
  @override
  double get freq => _freq;
  @override
  set freq(double value) {
    _bindings.waveform_sound_data_set_freq(_soundData, value);
    _freq = value;
  }
}

final class FfiNoiseSound extends FfiSound implements PlatformNoiseSound {
  FfiNoiseSound._(
    super.self, {
    required this.type,
    required int seed,
  }) : _seed = seed;

  late final _soundData = _bindings.sound_get_noise_data(_self);

  @override
  final NoiseType type;

  int _seed;
  @override
  int get seed => _seed;
  @override
  set seed(int value) {
    _bindings.noise_sound_data_set_seed(_soundData, value);
    _seed = value;
  }
}

final class FfiPulseSound extends FfiSound implements PlatformPulseSound {
  FfiPulseSound._(
    super.self, {
    required double freq,
    required double dutyCycle,
  })  : _freq = freq,
        _dutyCycle = dutyCycle;

  late final _soundData = _bindings.sound_get_pulse_data(_self);

  double _freq;
  @override
  double get freq => _freq;
  @override
  set freq(double value) {
    _bindings.pulse_sound_data_set_freq(_soundData, value);
    _freq = value;
  }

  double _dutyCycle;
  @override
  double get dutyCycle => _dutyCycle;
  @override
  set dutyCycle(double value) {
    _bindings.pulse_sound_data_set_duty_cycle(_soundData, value);
    _dutyCycle = value;
  }
}
