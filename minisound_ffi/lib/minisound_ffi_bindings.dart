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
      _lookup<ffi.NativeFunction<ffi.Double Function(ffi.Pointer<Sound>)>>(
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

  ffi.Pointer<Recording> recording_alloc() {
    return _recording_alloc();
  }

  late final _recording_allocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Recording> Function()>>(
          'recording_alloc');
  late final _recording_alloc =
      _recording_allocPtr.asFunction<ffi.Pointer<Recording> Function()>();

  int recording_init(
    ffi.Pointer<Recording> self,
    int encoding,
    ffi.Pointer<ffi.Void> v_device,
  ) {
    return _recording_init(
      self,
      encoding,
      v_device,
    );
  }

  late final _recording_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Recording>, ffi.Int32,
              ffi.Pointer<ffi.Void>)>>('recording_init');
  late final _recording_init = _recording_initPtr.asFunction<
      int Function(ffi.Pointer<Recording>, int, ffi.Pointer<ffi.Void>)>();

  void recording_uninit(
    ffi.Pointer<Recording> self,
  ) {
    return _recording_uninit(
      self,
    );
  }

  late final _recording_uninitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Recording>)>>(
          'recording_uninit');
  late final _recording_uninit =
      _recording_uninitPtr.asFunction<void Function(ffi.Pointer<Recording>)>();

  ffi.Pointer<ffi.Uint8> recording_get_buf(
    ffi.Pointer<Recording> self,
  ) {
    return _recording_get_buf(
      self,
    );
  }

  late final _recording_get_bufPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<Recording>)>>('recording_get_buf');
  late final _recording_get_buf = _recording_get_bufPtr
      .asFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<Recording>)>();

  int recording_get_size(
    ffi.Pointer<Recording> self,
  ) {
    return _recording_get_size(
      self,
    );
  }

  late final _recording_get_sizePtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<Recording>)>>(
          'recording_get_size');
  late final _recording_get_size =
      _recording_get_sizePtr.asFunction<int Function(ffi.Pointer<Recording>)>();

  int recording_write(
    ffi.Pointer<Recording> self,
    ffi.Pointer<ffi.Uint8> data,
    int data_size,
  ) {
    return _recording_write(
      self,
      data,
      data_size,
    );
  }

  late final _recording_writePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<Recording>, ffi.Pointer<ffi.Uint8>,
              ffi.Size)>>('recording_write');
  late final _recording_write = _recording_writePtr.asFunction<
      int Function(ffi.Pointer<Recording>, ffi.Pointer<ffi.Uint8>, int)>();

  int recording_fit(
    ffi.Pointer<Recording> self,
  ) {
    return _recording_fit(
      self,
    );
  }

  late final _recording_fitPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<Recording>)>>(
          'recording_fit');
  late final _recording_fit =
      _recording_fitPtr.asFunction<int Function(ffi.Pointer<Recording>)>();

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

  ffi.Pointer<Recording> recorder_stop(
    ffi.Pointer<Recorder> self,
  ) {
    return _recorder_stop(
      self,
    );
  }

  late final _recorder_stopPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Recording> Function(
              ffi.Pointer<Recorder>)>>('recorder_stop');
  late final _recorder_stop = _recorder_stopPtr
      .asFunction<ffi.Pointer<Recording> Function(ffi.Pointer<Recorder>)>();
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

final class SoundData extends ffi.Struct {
  external ffi.Pointer<PrivateSoundDataImpl> __vtbl;

  external ffi.Pointer<ffi.Void> _self;
}

final class PrivateSoundDataImpl extends ffi.Opaque {}

final class Engine extends ffi.Opaque {}

abstract class WaveformType {
  static const int WAVEFORM_TYPE_SINE = 0;
  static const int WAVEFORM_TYPE_SQUARE = 1;
  static const int WAVEFORM_TYPE_TRIANGLE = 2;
  static const int WAVEFORM_TYPE_SAWTOOTH = 3;
}

abstract class NoiseType {
  static const int NOISE_TYPE_WHITE = 0;
  static const int NOISE_TYPE_PINK = 1;
  static const int NOISE_TYPE_BROWNIAN = 2;
}

final class Recording extends ffi.Opaque {}

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
