// ignore_for_file: camel_case_types
// ignore_for_file: prefer_double_quotes
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unused_element

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

  ffi.Pointer<Sound> sound_alloc() {
    return _sound_alloc();
  }

  late final _sound_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Sound> Function()>>('sound_alloc');
  late final _sound_alloc =
      _sound_allocPtr.asFunction<ffi.Pointer<Sound> Function()>();

  int sound_init(
    ffi.Pointer<Sound> self,
    ffi.Pointer<ffi.Float> data,
    int data_size,
    int sound_format,
    int channels,
    int sample_rate,
    ffi.Pointer<ffi.Void> vengine,
  ) {
    return _sound_init(
      self,
      data,
      data_size,
      sound_format,
      channels,
      sample_rate,
      vengine,
    );
  }

  late final _sound_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<Sound>,
              ffi.Pointer<ffi.Float>,
              ffi.Size,
              ffi.Int32,
              ffi.Uint32,
              ffi.Uint32,
              ffi.Pointer<ffi.Void>)>>('sound_init');
  late final _sound_init = _sound_initPtr.asFunction<
      int Function(ffi.Pointer<Sound>, ffi.Pointer<ffi.Float>, int, int, int,
          int, ffi.Pointer<ffi.Void>)>();

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

  int sound_replay(
    ffi.Pointer<Sound> self,
  ) {
    return _sound_replay(
      self,
    );
  }

  late final _sound_replayPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Sound>)>>(
          'sound_replay');
  late final _sound_replay =
      _sound_replayPtr.asFunction<int Function(ffi.Pointer<Sound>)>();

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
      _lookup<ffi.NativeFunction<ffi.Float Function(ffi.Pointer<Sound>)>>(
          'sound_get_duration');
  late final _sound_get_duration =
      _sound_get_durationPtr.asFunction<double Function(ffi.Pointer<Sound>)>();

  void sound_set_looped(
    ffi.Pointer<Sound> self,
    bool value,
    int delay_ms,
  ) {
    return _sound_set_looped(
      self,
      value,
      delay_ms,
    );
  }

  late final _sound_set_loopedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<Sound>, ffi.Bool, ffi.Size)>>('sound_set_looped');
  late final _sound_set_looped = _sound_set_loopedPtr
      .asFunction<void Function(ffi.Pointer<Sound>, bool, int)>();

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
    ffi.Pointer<ffi.Float> data,
    int data_size,
    int sound_format,
    int channels,
    int sample_rate,
  ) {
    return _engine_load_sound(
      self,
      sound,
      data,
      data_size,
      sound_format,
      channels,
      sample_rate,
    );
  }

  late final _engine_load_soundPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<Engine>,
              ffi.Pointer<Sound>,
              ffi.Pointer<ffi.Float>,
              ffi.Size,
              ffi.Int32,
              ffi.Uint32,
              ffi.Uint32)>>('engine_load_sound');
  late final _engine_load_sound = _engine_load_soundPtr.asFunction<
      int Function(ffi.Pointer<Engine>, ffi.Pointer<Sound>,
          ffi.Pointer<ffi.Float>, int, int, int, int)>();

  ffi.Pointer<Generator> generator_create() {
    return _generator_create();
  }

  late final _generator_createPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Generator> Function()>>(
          'generator_create');
  late final _generator_create =
      _generator_createPtr.asFunction<ffi.Pointer<Generator> Function()>();

  int generator_init(
    ffi.Pointer<Generator> self,
    int sound_format,
    int channels,
    int sample_rate,
    double buffer_len_s,
  ) {
    return _generator_init(
      self,
      sound_format,
      channels,
      sample_rate,
      buffer_len_s,
    );
  }

  late final _generator_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Generator>, ffi.Int32, ffi.Uint32,
              ffi.Uint32, ffi.Float)>>('generator_init');
  late final _generator_init = _generator_initPtr.asFunction<
      int Function(ffi.Pointer<Generator>, int, int, int, double)>();

  void generator_uninit(
    ffi.Pointer<Generator> self,
  ) {
    return _generator_uninit(
      self,
    );
  }

  late final _generator_uninitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Generator>)>>(
          'generator_uninit');
  late final _generator_uninit =
      _generator_uninitPtr.asFunction<void Function(ffi.Pointer<Generator>)>();

  double generator_get_volume(
    ffi.Pointer<Generator> self,
  ) {
    return _generator_get_volume(
      self,
    );
  }

  late final _generator_get_volumePtr =
      _lookup<ffi.NativeFunction<ffi.Float Function(ffi.Pointer<Generator>)>>(
          'generator_get_volume');
  late final _generator_get_volume = _generator_get_volumePtr
      .asFunction<double Function(ffi.Pointer<Generator>)>();

  void generator_set_volume(
    ffi.Pointer<Generator> self,
    double value,
  ) {
    return _generator_set_volume(
      self,
      value,
    );
  }

  late final _generator_set_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<Generator>, ffi.Float)>>('generator_set_volume');
  late final _generator_set_volume = _generator_set_volumePtr
      .asFunction<void Function(ffi.Pointer<Generator>, double)>();

  int generator_set_waveform(
    ffi.Pointer<Generator> self,
    int type,
    double frequency,
    double amplitude,
  ) {
    return _generator_set_waveform(
      self,
      type,
      frequency,
      amplitude,
    );
  }

  late final _generator_set_waveformPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Generator>, ffi.Int32, ffi.Double,
              ffi.Double)>>('generator_set_waveform');
  late final _generator_set_waveform = _generator_set_waveformPtr
      .asFunction<int Function(ffi.Pointer<Generator>, int, double, double)>();

  int generator_set_pulsewave(
    ffi.Pointer<Generator> generator,
    double frequency,
    double amplitude,
    double duty_cycle,
  ) {
    return _generator_set_pulsewave(
      generator,
      frequency,
      amplitude,
      duty_cycle,
    );
  }

  late final _generator_set_pulsewavePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Generator>, ffi.Double, ffi.Double,
              ffi.Double)>>('generator_set_pulsewave');
  late final _generator_set_pulsewave = _generator_set_pulsewavePtr.asFunction<
      int Function(ffi.Pointer<Generator>, double, double, double)>();

  int generator_set_noise(
    ffi.Pointer<Generator> self,
    int type,
    int seed,
    double amplitude,
  ) {
    return _generator_set_noise(
      self,
      type,
      seed,
      amplitude,
    );
  }

  late final _generator_set_noisePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Generator>, ffi.Int32, ffi.Int32,
              ffi.Double)>>('generator_set_noise');
  late final _generator_set_noise = _generator_set_noisePtr
      .asFunction<int Function(ffi.Pointer<Generator>, int, int, double)>();

  int generator_start(
    ffi.Pointer<Generator> self,
  ) {
    return _generator_start(
      self,
    );
  }

  late final _generator_startPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Generator>)>>(
          'generator_start');
  late final _generator_start =
      _generator_startPtr.asFunction<int Function(ffi.Pointer<Generator>)>();

  void generator_stop(
    ffi.Pointer<Generator> self,
  ) {
    return _generator_stop(
      self,
    );
  }

  late final _generator_stopPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Generator>)>>(
          'generator_stop');
  late final _generator_stop =
      _generator_stopPtr.asFunction<void Function(ffi.Pointer<Generator>)>();

  int generator_get_available_float_count(
    ffi.Pointer<Generator> self,
  ) {
    return _generator_get_available_float_count(
      self,
    );
  }

  late final _generator_get_available_float_countPtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<Generator>)>>(
          'generator_get_available_float_count');
  late final _generator_get_available_float_count =
      _generator_get_available_float_countPtr
          .asFunction<int Function(ffi.Pointer<Generator>)>();

  int generator_load_buffer(
    ffi.Pointer<Generator> self,
    ffi.Pointer<ffi.Float> output,
    int floats_to_read,
  ) {
    return _generator_load_buffer(
      self,
      output,
      floats_to_read,
    );
  }

  late final _generator_load_bufferPtr = _lookup<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<Generator>, ffi.Pointer<ffi.Float>,
              ffi.Size)>>('generator_load_buffer');
  late final _generator_load_buffer = _generator_load_bufferPtr.asFunction<
      int Function(ffi.Pointer<Generator>, ffi.Pointer<ffi.Float>, int)>();

  ffi.Pointer<Recorder> recorder_create() {
    return _recorder_create();
  }

  late final _recorder_createPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Recorder> Function()>>(
          'recorder_create');
  late final _recorder_create =
      _recorder_createPtr.asFunction<ffi.Pointer<Recorder> Function()>();

  int recorder_init_file(
    ffi.Pointer<Recorder> self,
    ffi.Pointer<ffi.Char> filename,
    int sample_rate,
    int channels,
    int sound_format,
  ) {
    return _recorder_init_file(
      self,
      filename,
      sample_rate,
      channels,
      sound_format,
    );
  }

  late final _recorder_init_filePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Recorder>, ffi.Pointer<ffi.Char>,
              ffi.Uint32, ffi.Uint32, ffi.Int32)>>('recorder_init_file');
  late final _recorder_init_file = _recorder_init_filePtr.asFunction<
      int Function(
          ffi.Pointer<Recorder>, ffi.Pointer<ffi.Char>, int, int, int)>();

  int recorder_init_stream(
    ffi.Pointer<Recorder> self,
    int sample_rate,
    int channels,
    int sound_format,
    int buffer_duration_seconds,
  ) {
    return _recorder_init_stream(
      self,
      sample_rate,
      channels,
      sound_format,
      buffer_duration_seconds,
    );
  }

  late final _recorder_init_streamPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Recorder>, ffi.Uint32, ffi.Uint32,
              ffi.Int32, ffi.Int)>>('recorder_init_stream');
  late final _recorder_init_stream = _recorder_init_streamPtr
      .asFunction<int Function(ffi.Pointer<Recorder>, int, int, int, int)>();

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

  bool recorder_is_recording(
    ffi.Pointer<Recorder> recorder,
  ) {
    return _recorder_is_recording(
      recorder,
    );
  }

  late final _recorder_is_recordingPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<Recorder>)>>(
          'recorder_is_recording');
  late final _recorder_is_recording = _recorder_is_recordingPtr
      .asFunction<bool Function(ffi.Pointer<Recorder>)>();

  int recorder_start(
    ffi.Pointer<Recorder> recorder,
  ) {
    return _recorder_start(
      recorder,
    );
  }

  late final _recorder_startPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Recorder>)>>(
          'recorder_start');
  late final _recorder_start =
      _recorder_startPtr.asFunction<int Function(ffi.Pointer<Recorder>)>();

  int recorder_stop(
    ffi.Pointer<Recorder> recorder,
  ) {
    return _recorder_stop(
      recorder,
    );
  }

  late final _recorder_stopPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Recorder>)>>(
          'recorder_stop');
  late final _recorder_stop =
      _recorder_stopPtr.asFunction<int Function(ffi.Pointer<Recorder>)>();

  int recorder_get_available_float_count(
    ffi.Pointer<Recorder> self,
  ) {
    return _recorder_get_available_float_count(
      self,
    );
  }

  late final _recorder_get_available_float_countPtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<Recorder>)>>(
          'recorder_get_available_float_count');
  late final _recorder_get_available_float_count =
      _recorder_get_available_float_countPtr
          .asFunction<int Function(ffi.Pointer<Recorder>)>();

  int recorder_load_buffer(
    ffi.Pointer<Recorder> self,
    ffi.Pointer<ffi.Float> output,
    int floats_to_read,
  ) {
    return _recorder_load_buffer(
      self,
      output,
      floats_to_read,
    );
  }

  late final _recorder_load_bufferPtr = _lookup<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<Recorder>, ffi.Pointer<ffi.Float>,
              ffi.Size)>>('recorder_load_buffer');
  late final _recorder_load_buffer = _recorder_load_bufferPtr.asFunction<
      int Function(ffi.Pointer<Recorder>, ffi.Pointer<ffi.Float>, int)>();
}

abstract class SoundFormat {
  static const int SOUND_FORMAT_UNKNOWN = 0;
  static const int SOUND_FORMAT_U8 = 1;
  static const int SOUND_FORMAT_S16 = 2;
  static const int SOUND_FORMAT_S24 = 3;
  static const int SOUND_FORMAT_S32 = 4;
  static const int SOUND_FORMAT_F32 = 5;
  static const int SOUND_FORMAT_COUNT = 6;
}

final class Sound extends ffi.Opaque {}

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

final class Engine extends ffi.Opaque {}

abstract class GeneratorResult {
  static const int GENERATOR_OK = 0;
  static const int GENERATOR_UNKNOWN_ERROR = 1;
  static const int GENERATOR_DEVICE_INIT_ERROR = 2;
  static const int GENERATOR_ARG_ERROR = 3;
  static const int GENERATOR_CIRCULAR_BUFFER_INIT_ERROR = 4;
  static const int GENERATOR_SET_TYPE_ERROR = 5;
  static const int GENERATOR_DEVICE_START_ERROR = 6;
}

abstract class GeneratorType {
  static const int GENERATOR_TYPE_WAVEFORM = 0;
  static const int GENERATOR_TYPE_PULSEWAVE = 1;
  static const int GENERATOR_TYPE_NOISE = 2;
}

abstract class GeneratorWaveformType {
  static const int GENERATOR_WAVEFORM_TYPE_SINE = 0;
  static const int GENERATOR_WAVEFORM_TYPE_SQUARE = 1;
  static const int GENERATOR_WAVEFORM_TYPE_TRIANGLE = 2;
  static const int GENERATOR_WAVEFORM_TYPE_SAWTOOTH = 3;
}

abstract class GeneratorNoiseType {
  static const int GENERATOR_NOISE_TYPE_WHITE = 0;
  static const int GENERATOR_NOISE_TYPE_PINK = 1;
  static const int GENERATOR_NOISE_TYPE_BROWNIAN = 2;
}

final class Generator extends ffi.Opaque {}

abstract class RecorderResult {
  static const int RECORDER_OK = 0;
  static const int RECORDER_ERROR_UNKNOWN = 1;
  static const int RECORDER_ERROR_OUT_OF_MEMORY = 2;
  static const int RECORDER_ERROR_INVALID_ARGUMENT = 3;
  static const int RECORDER_ERROR_ALREADY_RECORDING = 4;
  static const int RECORDER_ERROR_NOT_RECORDING = 5;
  static const int RECORDER_ERROR_INVALID_FORMAT = 6;
  static const int RECORDER_ERROR_INVALID_CHANNELS = 7;
}

final class Recorder extends ffi.Opaque {}

const int __bool_true_false_are_defined = 1;

const int true1 = 1;

const int false1 = 0;
