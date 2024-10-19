// ignore_for_file: camel_case_types
// ignore_for_file: prefer_double_quotes
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unused_element, unused_field

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings for minisound.h
class MinisoundFfiBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  MinisoundFfiBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  MinisoundFfiBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<EncodedSoundData> encoded_sound_data_alloc() {
    return _encoded_sound_data_alloc();
  }

  late final _encoded_sound_data_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<EncodedSoundData> Function()>>(
          'encoded_sound_data_alloc');
  late final _encoded_sound_data_alloc = _encoded_sound_data_allocPtr
      .asFunction<ffi.Pointer<EncodedSoundData> Function()>();

  int encoded_sound_data_init(
    ffi.Pointer<EncodedSoundData> self,
    ffi.Pointer<ffi.Uint8> data,
    int data_size,
  ) {
    return _encoded_sound_data_init(
      self,
      data,
      data_size,
    );
  }

  late final _encoded_sound_data_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<EncodedSoundData>,
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('encoded_sound_data_init');
  late final _encoded_sound_data_init = _encoded_sound_data_initPtr.asFunction<
      int Function(
          ffi.Pointer<EncodedSoundData>, ffi.Pointer<ffi.Uint8>, int)>();

  void encoded_sound_data_uninit(
    ffi.Pointer<EncodedSoundData> self,
  ) {
    return _encoded_sound_data_uninit(
      self,
    );
  }

  late final _encoded_sound_data_uninitPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<EncodedSoundData>)>>(
      'encoded_sound_data_uninit');
  late final _encoded_sound_data_uninit = _encoded_sound_data_uninitPtr
      .asFunction<void Function(ffi.Pointer<EncodedSoundData>)>();

  bool encoded_sound_data_get_is_looped(
    ffi.Pointer<EncodedSoundData> self,
  ) {
    return _encoded_sound_data_get_is_looped(
      self,
    );
  }

  late final _encoded_sound_data_get_is_loopedPtr = _lookup<
          ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<EncodedSoundData>)>>(
      'encoded_sound_data_get_is_looped');
  late final _encoded_sound_data_get_is_looped =
      _encoded_sound_data_get_is_loopedPtr
          .asFunction<bool Function(ffi.Pointer<EncodedSoundData>)>();

  void encoded_sound_data_set_looped(
    ffi.Pointer<EncodedSoundData> self,
    bool value,
    int delay_ms,
  ) {
    return _encoded_sound_data_set_looped(
      self,
      value,
      delay_ms,
    );
  }

  late final _encoded_sound_data_set_loopedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<EncodedSoundData>, ffi.Bool,
              ffi.Size)>>('encoded_sound_data_set_looped');
  late final _encoded_sound_data_set_looped = _encoded_sound_data_set_loopedPtr
      .asFunction<void Function(ffi.Pointer<EncodedSoundData>, bool, int)>();

  SoundData encoded_sound_data_ww_sound_data(
    ffi.Pointer<EncodedSoundData> self,
  ) {
    return _encoded_sound_data_ww_sound_data(
      self,
    );
  }

  late final _encoded_sound_data_ww_sound_dataPtr = _lookup<
          ffi
          .NativeFunction<SoundData Function(ffi.Pointer<EncodedSoundData>)>>(
      'encoded_sound_data_ww_sound_data');
  late final _encoded_sound_data_ww_sound_data =
      _encoded_sound_data_ww_sound_dataPtr
          .asFunction<SoundData Function(ffi.Pointer<EncodedSoundData>)>();

  ffi.Pointer<WaveformSoundData> waveform_sound_data_alloc() {
    return _waveform_sound_data_alloc();
  }

  late final _waveform_sound_data_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<WaveformSoundData> Function()>>(
          'waveform_sound_data_alloc');
  late final _waveform_sound_data_alloc = _waveform_sound_data_allocPtr
      .asFunction<ffi.Pointer<WaveformSoundData> Function()>();

  int waveform_sound_data_init(
    ffi.Pointer<WaveformSoundData> self,
    int type,
    double frequency,
  ) {
    return _waveform_sound_data_init(
      self,
      type,
      frequency,
    );
  }

  late final _waveform_sound_data_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<WaveformSoundData>, ffi.Int32,
              ffi.Double)>>('waveform_sound_data_init');
  late final _waveform_sound_data_init = _waveform_sound_data_initPtr
      .asFunction<int Function(ffi.Pointer<WaveformSoundData>, int, double)>();

  void waveform_sound_data_uninit(
    ffi.Pointer<WaveformSoundData> self,
  ) {
    return _waveform_sound_data_uninit(
      self,
    );
  }

  late final _waveform_sound_data_uninitPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<WaveformSoundData>)>>(
      'waveform_sound_data_uninit');
  late final _waveform_sound_data_uninit = _waveform_sound_data_uninitPtr
      .asFunction<void Function(ffi.Pointer<WaveformSoundData>)>();

  void waveform_sound_data_set_type(
    ffi.Pointer<WaveformSoundData> self,
    int value,
  ) {
    return _waveform_sound_data_set_type(
      self,
      value,
    );
  }

  late final _waveform_sound_data_set_typePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<WaveformSoundData>,
              ffi.Int32)>>('waveform_sound_data_set_type');
  late final _waveform_sound_data_set_type = _waveform_sound_data_set_typePtr
      .asFunction<void Function(ffi.Pointer<WaveformSoundData>, int)>();

  void waveform_sound_data_set_freq(
    ffi.Pointer<WaveformSoundData> self,
    double value,
  ) {
    return _waveform_sound_data_set_freq(
      self,
      value,
    );
  }

  late final _waveform_sound_data_set_freqPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<WaveformSoundData>,
              ffi.Double)>>('waveform_sound_data_set_freq');
  late final _waveform_sound_data_set_freq = _waveform_sound_data_set_freqPtr
      .asFunction<void Function(ffi.Pointer<WaveformSoundData>, double)>();

  SoundData waveform_sound_data_ww_sound_data(
    ffi.Pointer<WaveformSoundData> self,
  ) {
    return _waveform_sound_data_ww_sound_data(
      self,
    );
  }

  late final _waveform_sound_data_ww_sound_dataPtr = _lookup<
          ffi
          .NativeFunction<SoundData Function(ffi.Pointer<WaveformSoundData>)>>(
      'waveform_sound_data_ww_sound_data');
  late final _waveform_sound_data_ww_sound_data =
      _waveform_sound_data_ww_sound_dataPtr
          .asFunction<SoundData Function(ffi.Pointer<WaveformSoundData>)>();

  ffi.Pointer<NoiseSoundData> noise_sound_data_alloc() {
    return _noise_sound_data_alloc();
  }

  late final _noise_sound_data_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<NoiseSoundData> Function()>>(
          'noise_sound_data_alloc');
  late final _noise_sound_data_alloc = _noise_sound_data_allocPtr
      .asFunction<ffi.Pointer<NoiseSoundData> Function()>();

  int noise_sound_data_init(
    ffi.Pointer<NoiseSoundData> self,
    int type,
    int seed,
  ) {
    return _noise_sound_data_init(
      self,
      type,
      seed,
    );
  }

  late final _noise_sound_data_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<NoiseSoundData>, ffi.Int32,
              ffi.Int32)>>('noise_sound_data_init');
  late final _noise_sound_data_init = _noise_sound_data_initPtr
      .asFunction<int Function(ffi.Pointer<NoiseSoundData>, int, int)>();

  void noise_sound_data_uninit(
    ffi.Pointer<NoiseSoundData> self,
  ) {
    return _noise_sound_data_uninit(
      self,
    );
  }

  late final _noise_sound_data_uninitPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<NoiseSoundData>)>>(
      'noise_sound_data_uninit');
  late final _noise_sound_data_uninit = _noise_sound_data_uninitPtr
      .asFunction<void Function(ffi.Pointer<NoiseSoundData>)>();

  void noise_sound_data_set_seed(
    ffi.Pointer<NoiseSoundData> self,
    int seed,
  ) {
    return _noise_sound_data_set_seed(
      self,
      seed,
    );
  }

  late final _noise_sound_data_set_seedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<NoiseSoundData>,
              ffi.Int32)>>('noise_sound_data_set_seed');
  late final _noise_sound_data_set_seed = _noise_sound_data_set_seedPtr
      .asFunction<void Function(ffi.Pointer<NoiseSoundData>, int)>();

  SoundData noise_sound_data_ww_sound_data(
    ffi.Pointer<NoiseSoundData> self,
  ) {
    return _noise_sound_data_ww_sound_data(
      self,
    );
  }

  late final _noise_sound_data_ww_sound_dataPtr = _lookup<
          ffi.NativeFunction<SoundData Function(ffi.Pointer<NoiseSoundData>)>>(
      'noise_sound_data_ww_sound_data');
  late final _noise_sound_data_ww_sound_data =
      _noise_sound_data_ww_sound_dataPtr
          .asFunction<SoundData Function(ffi.Pointer<NoiseSoundData>)>();

  ffi.Pointer<PulseSoundData> pulse_sound_data_alloc() {
    return _pulse_sound_data_alloc();
  }

  late final _pulse_sound_data_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<PulseSoundData> Function()>>(
          'pulse_sound_data_alloc');
  late final _pulse_sound_data_alloc = _pulse_sound_data_allocPtr
      .asFunction<ffi.Pointer<PulseSoundData> Function()>();

  int pulse_sound_data_init(
    ffi.Pointer<PulseSoundData> self,
    double frequency,
    double duty_cycle,
  ) {
    return _pulse_sound_data_init(
      self,
      frequency,
      duty_cycle,
    );
  }

  late final _pulse_sound_data_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<PulseSoundData>, ffi.Double,
              ffi.Double)>>('pulse_sound_data_init');
  late final _pulse_sound_data_init = _pulse_sound_data_initPtr
      .asFunction<int Function(ffi.Pointer<PulseSoundData>, double, double)>();

  void pulse_sound_data_uninit(
    ffi.Pointer<PulseSoundData> self,
  ) {
    return _pulse_sound_data_uninit(
      self,
    );
  }

  late final _pulse_sound_data_uninitPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<PulseSoundData>)>>(
      'pulse_sound_data_uninit');
  late final _pulse_sound_data_uninit = _pulse_sound_data_uninitPtr
      .asFunction<void Function(ffi.Pointer<PulseSoundData>)>();

  void pulse_sound_data_set_freq(
    ffi.Pointer<PulseSoundData> self,
    double value,
  ) {
    return _pulse_sound_data_set_freq(
      self,
      value,
    );
  }

  late final _pulse_sound_data_set_freqPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<PulseSoundData>,
              ffi.Double)>>('pulse_sound_data_set_freq');
  late final _pulse_sound_data_set_freq = _pulse_sound_data_set_freqPtr
      .asFunction<void Function(ffi.Pointer<PulseSoundData>, double)>();

  void pulse_sound_data_set_duty_cycle(
    ffi.Pointer<PulseSoundData> self,
    double value,
  ) {
    return _pulse_sound_data_set_duty_cycle(
      self,
      value,
    );
  }

  late final _pulse_sound_data_set_duty_cyclePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<PulseSoundData>,
              ffi.Double)>>('pulse_sound_data_set_duty_cycle');
  late final _pulse_sound_data_set_duty_cycle =
      _pulse_sound_data_set_duty_cyclePtr
          .asFunction<void Function(ffi.Pointer<PulseSoundData>, double)>();

  SoundData pulse_sound_data_ww_sound_data(
    ffi.Pointer<PulseSoundData> self,
  ) {
    return _pulse_sound_data_ww_sound_data(
      self,
    );
  }

  late final _pulse_sound_data_ww_sound_dataPtr = _lookup<
          ffi.NativeFunction<SoundData Function(ffi.Pointer<PulseSoundData>)>>(
      'pulse_sound_data_ww_sound_data');
  late final _pulse_sound_data_ww_sound_data =
      _pulse_sound_data_ww_sound_dataPtr
          .asFunction<SoundData Function(ffi.Pointer<PulseSoundData>)>();

  ffi.Pointer<Sound> sound_alloc() {
    return _sound_alloc();
  }

  late final _sound_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Sound> Function()>>('sound_alloc');
  late final _sound_alloc =
      _sound_allocPtr.asFunction<ffi.Pointer<Sound> Function()>();

  int sound_init(
    ffi.Pointer<Sound> self,
    SoundData sound_data,
    ffi.Pointer<ffi.Void> v_engine,
  ) {
    return _sound_init(
      self,
      sound_data,
      v_engine,
    );
  }

  late final _sound_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Sound>, SoundData,
              ffi.Pointer<ffi.Void>)>>('sound_init');
  late final _sound_init = _sound_initPtr.asFunction<
      int Function(ffi.Pointer<Sound>, SoundData, ffi.Pointer<ffi.Void>)>();

  void sound_unload(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_unload(
      self,
    );
  }

  late final _sound_unloadPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Sound>)>>(
          'sound_unload');
  late final _sound_unload =
      _sound_unloadPtr.asFunction<void Function(ffi.Pointer<Sound>)>();

  int sound_play(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_play(
      self,
    );
  }

  late final _sound_playPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Sound>)>>(
          'sound_play');
  late final _sound_play =
      _sound_playPtr.asFunction<int Function(ffi.Pointer<Sound>)>();

  void sound_pause(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_pause(
      self,
    );
  }

  late final _sound_pausePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Sound>)>>(
          'sound_pause');
  late final _sound_pause =
      _sound_pausePtr.asFunction<void Function(ffi.Pointer<Sound>)>();

  void sound_stop(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_stop(
      self,
    );
  }

  late final _sound_stopPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Sound>)>>(
          'sound_stop');
  late final _sound_stop =
      _sound_stopPtr.asFunction<void Function(ffi.Pointer<Sound>)>();

  double sound_get_volume(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_volume(
      self,
    );
  }

  late final _sound_get_volumePtr =
      _lookup<ffi.NativeFunction<ffi.Float Function(ffi.Pointer<Sound>)>>(
          'sound_get_volume');
  late final _sound_get_volume =
      _sound_get_volumePtr.asFunction<double Function(ffi.Pointer<Sound>)>();

  void sound_set_volume(
    ffi.Pointer<Sound> self,
    double value,
  ) {
    return _sound_set_volume(
      self,
      value,
    );
  }

  late final _sound_set_volumePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Sound>, ffi.Float)>>(
      'sound_set_volume');
  late final _sound_set_volume = _sound_set_volumePtr
      .asFunction<void Function(ffi.Pointer<Sound>, double)>();

  double sound_get_duration(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_duration(
      self,
    );
  }

  late final _sound_get_durationPtr =
      _lookup<ffi.NativeFunction<ffi.Double Function(ffi.Pointer<Sound>)>>(
          'sound_get_duration');
  late final _sound_get_duration =
      _sound_get_durationPtr.asFunction<double Function(ffi.Pointer<Sound>)>();

  ffi.Pointer<EncodedSoundData> sound_get_encoded_data(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_encoded_data(
      self,
    );
  }

  late final _sound_get_encoded_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<EncodedSoundData> Function(
              ffi.Pointer<Sound>)>>('sound_get_encoded_data');
  late final _sound_get_encoded_data = _sound_get_encoded_dataPtr
      .asFunction<ffi.Pointer<EncodedSoundData> Function(ffi.Pointer<Sound>)>();

  ffi.Pointer<WaveformSoundData> sound_get_waveform_data(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_waveform_data(
      self,
    );
  }

  late final _sound_get_waveform_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<WaveformSoundData> Function(
              ffi.Pointer<Sound>)>>('sound_get_waveform_data');
  late final _sound_get_waveform_data = _sound_get_waveform_dataPtr.asFunction<
      ffi.Pointer<WaveformSoundData> Function(ffi.Pointer<Sound>)>();

  ffi.Pointer<NoiseSoundData> sound_get_noise_data(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_noise_data(
      self,
    );
  }

  late final _sound_get_noise_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<NoiseSoundData> Function(
              ffi.Pointer<Sound>)>>('sound_get_noise_data');
  late final _sound_get_noise_data = _sound_get_noise_dataPtr
      .asFunction<ffi.Pointer<NoiseSoundData> Function(ffi.Pointer<Sound>)>();

  ffi.Pointer<PulseSoundData> sound_get_pulse_data(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_get_pulse_data(
      self,
    );
  }

  late final _sound_get_pulse_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<PulseSoundData> Function(
              ffi.Pointer<Sound>)>>('sound_get_pulse_data');
  late final _sound_get_pulse_data = _sound_get_pulse_dataPtr
      .asFunction<ffi.Pointer<PulseSoundData> Function(ffi.Pointer<Sound>)>();

  ffi.Pointer<Engine> engine_alloc() {
    return _engine_alloc();
  }

  late final _engine_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Engine> Function()>>(
          'engine_alloc');
  late final _engine_alloc =
      _engine_allocPtr.asFunction<ffi.Pointer<Engine> Function()>();

  int engine_init(
    ffi.Pointer<Engine> self,
    int period_ms,
  ) {
    return _engine_init(
      self,
      period_ms,
    );
  }

  late final _engine_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Engine>, ffi.Uint32)>>('engine_init');
  late final _engine_init =
      _engine_initPtr.asFunction<int Function(ffi.Pointer<Engine>, int)>();

  void engine_uninit(
    ffi.Pointer<Engine> self,
  ) {
    return _engine_uninit(
      self,
    );
  }

  late final _engine_uninitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Engine>)>>(
          'engine_uninit');
  late final _engine_uninit =
      _engine_uninitPtr.asFunction<void Function(ffi.Pointer<Engine>)>();

  int engine_start(
    ffi.Pointer<Engine> self,
  ) {
    return _engine_start(
      self,
    );
  }

  late final _engine_startPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Engine>)>>(
          'engine_start');
  late final _engine_start =
      _engine_startPtr.asFunction<int Function(ffi.Pointer<Engine>)>();

  int engine_load_sound(
    ffi.Pointer<Engine> self,
    ffi.Pointer<Sound> sound,
    ffi.Pointer<ffi.Uint8> data,
    int data_size,
  ) {
    return _engine_load_sound(
      self,
      sound,
      data,
      data_size,
    );
  }

  late final _engine_load_soundPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>,
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('engine_load_sound');
  late final _engine_load_sound = _engine_load_soundPtr.asFunction<
      int Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>,
          ffi.Pointer<ffi.Uint8>, int)>();

  int engine_generate_waveform(
    ffi.Pointer<Engine> self,
    ffi.Pointer<Sound> sound,
    int type,
    double frequency,
  ) {
    return _engine_generate_waveform(
      self,
      sound,
      type,
      frequency,
    );
  }

  late final _engine_generate_waveformPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>, ffi.Int32,
              ffi.Double)>>('engine_generate_waveform');
  late final _engine_generate_waveform =
      _engine_generate_waveformPtr.asFunction<
          int Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>, int, double)>();

  int engine_generate_noise(
    ffi.Pointer<Engine> self,
    ffi.Pointer<Sound> sound,
    int type,
    int seed,
  ) {
    return _engine_generate_noise(
      self,
      sound,
      type,
      seed,
    );
  }

  late final _engine_generate_noisePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>, ffi.Int32,
              ffi.Int32)>>('engine_generate_noise');
  late final _engine_generate_noise = _engine_generate_noisePtr.asFunction<
      int Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>, int, int)>();

  int engine_generate_pulse(
    ffi.Pointer<Engine> self,
    ffi.Pointer<Sound> sound,
    double frequency,
    double duty_cycle,
  ) {
    return _engine_generate_pulse(
      self,
      sound,
      frequency,
      duty_cycle,
    );
  }

  late final _engine_generate_pulsePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>,
              ffi.Double, ffi.Double)>>('engine_generate_pulse');
  late final _engine_generate_pulse = _engine_generate_pulsePtr.asFunction<
      int Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>, double, double)>();

  ffi.Pointer<RecorderBuffer> recorder_buffer_alloc() {
    return _recorder_buffer_alloc();
  }

  late final _recorder_buffer_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<RecorderBuffer> Function()>>(
          'recorder_buffer_alloc');
  late final _recorder_buffer_alloc = _recorder_buffer_allocPtr
      .asFunction<ffi.Pointer<RecorderBuffer> Function()>();

  int recorder_buffer_init(
    ffi.Pointer<RecorderBuffer> self,
    int encoding,
    ffi.Pointer<ffi.Void> v_device,
  ) {
    return _recorder_buffer_init(
      self,
      encoding,
      v_device,
    );
  }

  late final _recorder_buffer_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<RecorderBuffer>, ffi.Int32,
              ffi.Pointer<ffi.Void>)>>('recorder_buffer_init');
  late final _recorder_buffer_init = _recorder_buffer_initPtr.asFunction<
      int Function(ffi.Pointer<RecorderBuffer>, int, ffi.Pointer<ffi.Void>)>();

  void recorder_buffer_uninit(
    ffi.Pointer<RecorderBuffer> self,
  ) {
    return _recorder_buffer_uninit(
      self,
    );
  }

  late final _recorder_buffer_uninitPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<RecorderBuffer>)>>(
      'recorder_buffer_uninit');
  late final _recorder_buffer_uninit = _recorder_buffer_uninitPtr
      .asFunction<void Function(ffi.Pointer<RecorderBuffer>)>();

  int recorder_buffer_write(
    ffi.Pointer<RecorderBuffer> self,
    ffi.Pointer<ffi.Uint8> data,
    int data_size,
  ) {
    return _recorder_buffer_write(
      self,
      data,
      data_size,
    );
  }

  late final _recorder_buffer_writePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<RecorderBuffer>,
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('recorder_buffer_write');
  late final _recorder_buffer_write = _recorder_buffer_writePtr.asFunction<
      int Function(ffi.Pointer<RecorderBuffer>, ffi.Pointer<ffi.Uint8>, int)>();

  RecorderBufferFlush recorder_buffer_flush(
    ffi.Pointer<RecorderBuffer> self,
  ) {
    return _recorder_buffer_flush(
      self,
    );
  }

  late final _recorder_buffer_flushPtr = _lookup<
      ffi.NativeFunction<
          RecorderBufferFlush Function(
              ffi.Pointer<RecorderBuffer>)>>('recorder_buffer_flush');
  late final _recorder_buffer_flush = _recorder_buffer_flushPtr
      .asFunction<RecorderBufferFlush Function(ffi.Pointer<RecorderBuffer>)>();

  RecorderBufferFlush recorder_buffer_consume(
    ffi.Pointer<RecorderBuffer> self,
  ) {
    return _recorder_buffer_consume(
      self,
    );
  }

  late final _recorder_buffer_consumePtr = _lookup<
      ffi.NativeFunction<
          RecorderBufferFlush Function(
              ffi.Pointer<RecorderBuffer>)>>('recorder_buffer_consume');
  late final _recorder_buffer_consume = _recorder_buffer_consumePtr
      .asFunction<RecorderBufferFlush Function(ffi.Pointer<RecorderBuffer>)>();

  ffi.Pointer<Recorder> recorder_alloc() {
    return _recorder_alloc();
  }

  late final _recorder_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Recorder> Function()>>(
          'recorder_alloc');
  late final _recorder_alloc =
      _recorder_allocPtr.asFunction<ffi.Pointer<Recorder> Function()>();

  int recorder_init(
    ffi.Pointer<Recorder> self,
    int format,
    int channel_count,
    int sample_rate,
  ) {
    return _recorder_init(
      self,
      format,
      channel_count,
      sample_rate,
    );
  }

  late final _recorder_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Recorder>, ffi.Int32, ffi.Uint32,
              ffi.Uint32)>>('recorder_init');
  late final _recorder_init = _recorder_initPtr
      .asFunction<int Function(ffi.Pointer<Recorder>, int, int, int)>();

  void recorder_uninit(
    ffi.Pointer<Recorder> self,
  ) {
    return _recorder_uninit(
      self,
    );
  }

  late final _recorder_uninitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Recorder>)>>(
          'recorder_uninit');
  late final _recorder_uninit =
      _recorder_uninitPtr.asFunction<void Function(ffi.Pointer<Recorder>)>();

  bool recorder_get_is_recording(
    ffi.Pointer<Recorder> recorder,
  ) {
    return _recorder_get_is_recording(
      recorder,
    );
  }

  late final _recorder_get_is_recordingPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<Recorder>)>>(
          'recorder_get_is_recording');
  late final _recorder_get_is_recording = _recorder_get_is_recordingPtr
      .asFunction<bool Function(ffi.Pointer<Recorder>)>();

  int recorder_start(
    ffi.Pointer<Recorder> self,
    int encoding,
  ) {
    return _recorder_start(
      self,
      encoding,
    );
  }

  late final _recorder_startPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<Recorder>, ffi.Int32)>>('recorder_start');
  late final _recorder_start =
      _recorder_startPtr.asFunction<int Function(ffi.Pointer<Recorder>, int)>();

  RecorderBufferFlush recorder_flush(
    ffi.Pointer<Recorder> self,
  ) {
    return _recorder_flush(
      self,
    );
  }

  late final _recorder_flushPtr = _lookup<
          ffi
          .NativeFunction<RecorderBufferFlush Function(ffi.Pointer<Recorder>)>>(
      'recorder_flush');
  late final _recorder_flush = _recorder_flushPtr
      .asFunction<RecorderBufferFlush Function(ffi.Pointer<Recorder>)>();

  RecorderBufferFlush recorder_stop(
    ffi.Pointer<Recorder> self,
  ) {
    return _recorder_stop(
      self,
    );
  }

  late final _recorder_stopPtr = _lookup<
          ffi
          .NativeFunction<RecorderBufferFlush Function(ffi.Pointer<Recorder>)>>(
      'recorder_stop');
  late final _recorder_stop = _recorder_stopPtr
      .asFunction<RecorderBufferFlush Function(ffi.Pointer<Recorder>)>();
}

final class EncodedSoundData extends ffi.Opaque {}

abstract class Result {
  static const int Ok = 0;
  static const int UnknownErr = 1;
  static const int OutOfMemErr = 2;
  static const int RangeErr = 3;
  static const int HashCollisionErr = 4;
  static const int FileUnavailableErr = 5;
  static const int FileReadingErr = 6;
  static const int FileWritingErr = 7;
  static const int FormatErr = 8;
  static const int ArgErr = 9;
  static const int StateErr = 10;
  static const int RESULT_COUNT = 11;
}

final class SoundData extends ffi.Struct {
  external ffi.Pointer<PrivateSoundDataImpl> __vtbl;

  external ffi.Pointer<ffi.Void> _self;
}

final class PrivateSoundDataImpl extends ffi.Opaque {}

final class WaveformSoundData extends ffi.Opaque {}

abstract class WaveformType {
  static const int WAVEFORM_TYPE_SINE = 0;
  static const int WAVEFORM_TYPE_SQUARE = 1;
  static const int WAVEFORM_TYPE_TRIANGLE = 2;
  static const int WAVEFORM_TYPE_SAWTOOTH = 3;
}

final class NoiseSoundData extends ffi.Opaque {}

abstract class NoiseType {
  static const int NOISE_TYPE_WHITE = 0;
  static const int NOISE_TYPE_PINK = 1;
  static const int NOISE_TYPE_BROWNIAN = 2;
}

final class PulseSoundData extends ffi.Opaque {}

final class Sound extends ffi.Opaque {}

final class Engine extends ffi.Opaque {}

final class RecorderBufferFlush extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> buf;

  @ffi.Size()
  external int size;
}

final class RecorderBuffer extends ffi.Opaque {}

abstract class RecordingEncoding {
  static const int RECORDING_ENCODING_WAV = 1;
}

final class Recorder extends ffi.Opaque {}

abstract class RecorderFormat {
  static const int RECORDER_FORMAT_U8 = 1;
  static const int RECORDER_FORMAT_S16 = 2;
  static const int RECORDER_FORMAT_S24 = 3;
  static const int RECORDER_FORMAT_S32 = 4;
  static const int RECORDER_FORMAT_F32 = 5;
}

const int __bool_true_false_are_defined = 1;

const int true1 = 1;

const int false1 = 0;
