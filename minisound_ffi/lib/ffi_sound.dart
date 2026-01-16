part of "minisound_ffi.dart";

sealed class FfiSound implements PlatformSound {
  FfiSound(Pointer<c.Sound> self) : _self = self;

  final Pointer<c.Sound> _self;

  late var _volume = _binds.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    _binds.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  bool get isPlaying => _binds.sound_get_is_playing(_self);

  late var _pitch = _binds.sound_get_pitch(_self);
  @override
  double get pitch => _pitch;
  @override
  set pitch(double value) {
    _binds.sound_set_pitch(_self, value);
    _pitch = value;
  }

  @override
  void unload() {
    _binds.sound_unload(_self);
    malloc.free(_self);
  }

  @override
  void play() {
    final r = _binds.sound_play(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound (code: $r).");
    }
  }

  @override
  void pause() => _binds.sound_pause(_self);
  @override
  void stop() => _binds.sound_stop(_self);
}

final class FfiEncodedSound extends FfiSound implements PlatformEncodedSound {
  FfiEncodedSound._(super.self, {required Pointer data})
      : _data = data,
        _soundData = _binds.sound_get_encoded_data(self) {
    if (_soundData == nullptr) {
      throw MinisoundPlatformException("Failed to get the sound data.");
    }
  }

  final Pointer _data;
  final Pointer<c.EncodedSoundData> _soundData;

  @override
  late final duration = _binds.sound_get_duration(_self);

  @override
  double get cursor => _binds.sound_get_cursor(_self);
  @override
  set cursor(double value) => _binds.sound_set_cursor(_self, value);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    _binds.encoded_sound_data_set_looped(_soundData, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    super.unload();
    malloc.free(_data);
  }
}

final class FfiWaveformSound extends FfiSound implements PlatformWaveformSound {
  FfiWaveformSound._(super.self)
      : _waveform = _binds.sound_get_waveform_data(self) {
    if (_waveform == nullptr) {
      throw MinisoundPlatformException("Failed to get the sound data.");
    }
  }

  final Pointer<c.WaveformSoundData> _waveform;

  late var _type = _binds.waveform_sound_data_get_type(_waveform).toDart();
  @override
  WaveformType get type => _type;
  @override
  set type(WaveformType value) {
    _binds.waveform_sound_data_set_type(_waveform, value.toC());
    _type = value;
  }

  late var _freq = _binds.waveform_sound_data_get_freq(_waveform);
  @override
  double get freq => _freq;
  @override
  set freq(double value) {
    _binds.waveform_sound_data_set_freq(_waveform, value);
    _freq = value;
  }
}

final class FfiNoiseSound extends FfiSound implements PlatformNoiseSound {
  FfiNoiseSound._(super.self, this.type);

  // late final _noise = _binds.sound_get_noise_data(_self);

  @override
  final NoiseType type;
}

final class FfiPulseSound extends FfiSound implements PlatformPulseSound {
  FfiPulseSound._(super.self);

  late final _pulse = _binds.sound_get_pulse_data(_self);

  late double _freq = _binds.pulse_sound_data_get_freq(_pulse);
  @override
  double get freq => _freq;
  @override
  set freq(double value) {
    _binds.pulse_sound_data_set_freq(_pulse, value);
    _freq = value;
  }

  late double _dutyCycle = _binds.pulse_sound_data_get_duty_cycle(_pulse);
  @override
  double get dutyCycle => _dutyCycle;
  @override
  set dutyCycle(double value) {
    _binds.pulse_sound_data_set_duty_cycle(_pulse, value);
    _dutyCycle = value;
  }
}
