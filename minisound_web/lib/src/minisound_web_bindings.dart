// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters
// ignore_for_file: prefer_double_quotes
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first

@JS("Module")
library;

import "dart:js_interop";
import "package:minisound_web/src/wasm/wasm.dart" as ffi;

// result

enum Result {
  Ok(0),
  UnknownErr(1),
  OutOfMemErr(2),
  RangeErr(3),
  HashCollisionErr(4),
  FileUnavailableErr(5),
  FileReadingErr(6),
  FileWritingErr(7),
  FormatErr(8),
  ArgErr(9),
  StateErr(10),
  RESULT_COUNT(11);

  final int value;
  const Result(this.value);

  static Result fromValue(int value) => switch (value) {
        0 => Ok,
        1 => UnknownErr,
        2 => OutOfMemErr,
        3 => RangeErr,
        4 => HashCollisionErr,
        5 => FileUnavailableErr,
        6 => FileReadingErr,
        7 => FileWritingErr,
        8 => FormatErr,
        9 => ArgErr,
        10 => StateErr,
        11 => RESULT_COUNT,
        _ => throw ArgumentError('Unknown value for Result: $value'),
      };
}

// audio common

enum AudioEncoding {
  AUDIO_ENCODING_RAW(0),
  AUDIO_ENCODING_WAV(1),
  AUDIO_ENCODING_FLAC(2),
  AUDIO_ENCODING_MP3(3);

  final int value;
  const AudioEncoding(this.value);

  static AudioEncoding fromValue(int value) => switch (value) {
        0 => AUDIO_ENCODING_RAW,
        1 => AUDIO_ENCODING_WAV,
        2 => AUDIO_ENCODING_FLAC,
        3 => AUDIO_ENCODING_MP3,
        _ => throw ArgumentError('Unknown value for AudioEncoding: $value'),
      };
}

enum SampleFormat {
  SAMPLE_FORMAT_U8(1),
  SAMPLE_FORMAT_S16(2),
  SAMPLE_FORMAT_S24(3),
  SAMPLE_FORMAT_S32(4),
  SAMPLE_FORMAT_F32(5);

  final int value;
  const SampleFormat(this.value);

  static SampleFormat fromValue(int value) => switch (value) {
        1 => SAMPLE_FORMAT_U8,
        2 => SAMPLE_FORMAT_S16,
        3 => SAMPLE_FORMAT_S24,
        4 => SAMPLE_FORMAT_S32,
        5 => SAMPLE_FORMAT_F32,
        _ => throw ArgumentError('Unknown value for SampleFormat: $value'),
      };
}

// engine

final class Engine extends ffi.Opaque {}

ffi.Pointer<Engine> engine_alloc() => ffi.Pointer(_engine_alloc());
Future<Result> engine_init(ffi.Pointer<Engine> self, int period_ms) async =>
    Result.fromValue(await _engine_init(self.addr, period_ms));
void engine_uninit(ffi.Pointer<Engine> self) => _engine_uninit(self.addr);

Result engine_start(ffi.Pointer<Engine> self) =>
    Result.fromValue(_engine_start(self.addr));

Result engine_load_sound(
  ffi.Pointer<Engine> self,
  ffi.Pointer<Sound> sound,
  ffi.Pointer<ffi.Uint8> data,
  int data_size,
) =>
    Result.fromValue(
        _engine_load_sound(self.addr, sound.addr, data.addr, data_size));

Result engine_generate_waveform(
        ffi.Pointer<Engine> self, ffi.Pointer<Sound> sound) =>
    Result.fromValue(_engine_generate_waveform(self.addr, sound.addr));
Result engine_generate_noise(
        ffi.Pointer<Engine> self, ffi.Pointer<Sound> sound, NoiseType type) =>
    Result.fromValue(_engine_generate_noise(self.addr, sound.addr, type.value));
Result engine_generate_pulse(
        ffi.Pointer<Engine> self, ffi.Pointer<Sound> sound) =>
    Result.fromValue(_engine_generate_pulse(self.addr, sound.addr));

// sound

final class Sound extends ffi.Opaque {}

final class EncodedSoundData extends ffi.Opaque {}

final class WaveformSoundData extends ffi.Opaque {}

enum WaveformType {
  WAVEFORM_TYPE_SINE(0),
  WAVEFORM_TYPE_SQUARE(1),
  WAVEFORM_TYPE_TRIANGLE(2),
  WAVEFORM_TYPE_SAWTOOTH(3);

  final int value;
  const WaveformType(this.value);

  static WaveformType fromValue(int value) => switch (value) {
        0 => WAVEFORM_TYPE_SINE,
        1 => WAVEFORM_TYPE_SQUARE,
        2 => WAVEFORM_TYPE_TRIANGLE,
        3 => WAVEFORM_TYPE_SAWTOOTH,
        _ => throw ArgumentError('Unknown value for WaveformType: $value'),
      };
}

final class NoiseSoundData extends ffi.Opaque {}

enum NoiseType {
  NOISE_TYPE_WHITE(0),
  NOISE_TYPE_PINK(1),
  NOISE_TYPE_BROWNIAN(2);

  final int value;
  const NoiseType(this.value);

  static NoiseType fromValue(int value) => switch (value) {
        0 => NOISE_TYPE_WHITE,
        1 => NOISE_TYPE_PINK,
        2 => NOISE_TYPE_BROWNIAN,
        _ => throw ArgumentError('Unknown value for NoiseType: $value'),
      };
}

final class PulseSoundData extends ffi.Opaque {}

ffi.Pointer<Sound> sound_alloc() => ffi.Pointer(_sound_alloc());
void sound_unload(ffi.Pointer<Sound> self) => _sound_unload(self.addr);

Result sound_play(ffi.Pointer<Sound> self) =>
    Result.fromValue(_sound_play(self.addr));

void sound_pause(ffi.Pointer<Sound> self) => _sound_pause(self.addr);
void sound_stop(ffi.Pointer<Sound> self) => _sound_stop(self.addr);

double sound_get_volume(ffi.Pointer<Sound> self) =>
    _sound_get_volume(self.addr);
void sound_set_volume(ffi.Pointer<Sound> self, double value) =>
    _sound_set_volume(self.addr, value);

double sound_get_duration(ffi.Pointer<Sound> self) =>
    _sound_get_duration(self.addr);
bool sound_get_is_playing(ffi.Pointer<Sound> self) =>
    _sound_get_is_playing(self.addr) != 0;

double sound_get_cursor(ffi.Pointer<Sound> self) =>
    _sound_get_cursor(self.addr);
void sound_set_cursor(ffi.Pointer<Sound> self, double value) =>
    _sound_set_cursor(self.addr, value);

double sound_get_pitch(ffi.Pointer<Sound> self) => _sound_get_pitch(self.addr);
void sound_set_pitch(ffi.Pointer<Sound> self, double value) =>
    _sound_set_pitch(self.addr, value);

ffi.Pointer<EncodedSoundData> sound_get_encoded_data(ffi.Pointer<Sound> self) =>
    ffi.Pointer(_sound_get_encoded_data(self.addr));
ffi.Pointer<WaveformSoundData> sound_get_waveform_data(
        ffi.Pointer<Sound> self) =>
    ffi.Pointer(_sound_get_waveform_data(self.addr));
ffi.Pointer<NoiseSoundData> sound_get_noise_data(ffi.Pointer<Sound> self) =>
    ffi.Pointer(_sound_get_noise_data(self.addr));
ffi.Pointer<PulseSoundData> sound_get_pulse_data(ffi.Pointer<Sound> self) =>
    ffi.Pointer(_sound_get_pulse_data(self.addr));

// sound data

bool encoded_sound_data_get_is_looped(ffi.Pointer<EncodedSoundData> self) =>
    _encoded_sound_data_get_is_looped(self.addr) != 0;
void encoded_sound_data_set_looped(
        ffi.Pointer<EncodedSoundData> self, bool value, int delay_ms) =>
    _encoded_sound_data_set_looped(self.addr, value ? 1 : 0, delay_ms);

double pulse_sound_data_get_freq(ffi.Pointer<PulseSoundData> self) =>
    _pulse_sound_data_get_freq(self.addr);
void pulse_sound_data_set_freq(
        ffi.Pointer<PulseSoundData> self, double value) =>
    _pulse_sound_data_set_freq(self.addr, value);

double pulse_sound_data_get_duty_cycle(ffi.Pointer<PulseSoundData> self) =>
    _pulse_sound_data_get_duty_cycle(self.addr);
void pulse_sound_data_set_duty_cycle(
        ffi.Pointer<PulseSoundData> self, double value) =>
    _pulse_sound_data_set_duty_cycle(self.addr, value);

WaveformType waveform_sound_data_get_type(
        ffi.Pointer<WaveformSoundData> self) =>
    WaveformType.fromValue(_waveform_sound_data_get_type(self.addr));
void waveform_sound_data_set_type(
        ffi.Pointer<WaveformSoundData> self, WaveformType value) =>
    _waveform_sound_data_set_type(self.addr, value.value);

double waveform_sound_data_get_freq(ffi.Pointer<WaveformSoundData> self) =>
    _waveform_sound_data_get_freq(self.addr);
void waveform_sound_data_set_freq(
        ffi.Pointer<WaveformSoundData> self, double value) =>
    _waveform_sound_data_set_freq(self.addr, value);

// recorder

final class Recorder extends ffi.Opaque {}

ffi.Pointer<Recorder> recorder_alloc(int min_rec_count) =>
    ffi.Pointer(_recorder_alloc(min_rec_count));
Future<Result> recorder_init(ffi.Pointer<Recorder> self, int period_ms) async =>
    Result.fromValue(await _recorder_init(self.addr, period_ms));
void recorder_uninit(ffi.Pointer<Recorder> self) => _recorder_uninit(self.addr);

bool recorder_get_is_recording(
        ffi.Pointer<Recorder> self, ffi.Pointer<Rec> rec) =>
    _recorder_get_is_recording(self.addr, rec.addr) != 0;

Result recorder_start(ffi.Pointer<Recorder> self) =>
    Result.fromValue(_recorder_start(self.addr));

Result recorder_save_rec(
  ffi.Pointer<Recorder> self,
  ffi.Pointer<Rec> rec,
  AudioEncoding encoding,
  SampleFormat sample_format,
  int channel_count,
  int sample_rate,
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> data_ptr,
  ffi.Pointer<ffi.Size> data_size_ptr,
) =>
    Result.fromValue(_recorder_save_rec(
      self.addr,
      rec.addr,
      encoding.value,
      sample_format.value,
      channel_count,
      sample_rate,
      data_ptr.addr,
      data_size_ptr.addr,
    ));

Result recorder_resume_rec(ffi.Pointer<Recorder> self, ffi.Pointer<Rec> rec) =>
    Result.fromValue(_recorder_resume_rec(self.addr, rec.addr));

Result recorder_pause_rec(ffi.Pointer<Recorder> self, ffi.Pointer<Rec> rec) =>
    Result.fromValue(_recorder_pause_rec(self.addr, rec.addr));

// rec

final class Rec extends ffi.Opaque {}

ffi.Pointer<Rec> rec_alloc() => ffi.Pointer(_rec_alloc());
void rec_uninit(ffi.Pointer<Rec> self) => _rec_uninit(self.addr);

Future<Result> rec_end(ffi.Pointer<Rec> self) async =>
    Result.fromValue(await _rec_end(self.addr));

// *************
// ** JS part **
// *************

@JS("ccall")
external JSAny? _ccall(
  String name,
  JSString? returnType,
  JSArray<JSString> argTypes,
  JSArray<JSAny?> args,
  JSObject opts,
);
final _ccallTypeNumber = "number".toJS;
final _ccallAsyncOpts = {"async": true.toJS}.jsify() as JSObject;
final _ccallDefaultOpts = JSObject(); // ignore: unused_element

// JS engine

@JS()
external int _engine_alloc();
Future<int> _engine_init(int self, int period_ms) async => (_ccall(
      "engine_init",
      _ccallTypeNumber,
      [_ccallTypeNumber, _ccallTypeNumber].toJS,
      [self.toJS, period_ms.toJS].toJS,
      _ccallAsyncOpts,
    ) as JSPromise)
        .toDart
        .then((res) => (res as JSNumber).toDartInt);

@JS()
external void _engine_uninit(int self);
@JS()
external int _engine_start(int self);

@JS()
external int _engine_load_sound(int self, int sound, int data, int data_size);

@JS()
external int _engine_generate_waveform(int self, int sound);
@JS()
external int _engine_generate_noise(int self, int sound, int type);
@JS()
external int _engine_generate_pulse(int self, int sound);

// JS sound

@JS()
external int _sound_alloc();
@JS()
external void _sound_unload(int self);

@JS()
external int _sound_play(int self);
@JS()
external void _sound_pause(int self);
@JS()
external void _sound_stop(int self);

@JS()
external double _sound_get_volume(int self);
@JS()
external void _sound_set_volume(int self, double value);

@JS()
external double _sound_get_duration(int self);
@JS()
external int _sound_get_is_playing(int self);

@JS()
external double _sound_get_cursor(int self);
@JS()
external void _sound_set_cursor(int self, double value);

@JS()
external double _sound_get_pitch(int self);
@JS()
external void _sound_set_pitch(int self, double value);

@JS()
external int _sound_get_encoded_data(int sound);
@JS()
external int _sound_get_waveform_data(int sound);
@JS()
external int _sound_get_noise_data(int sound);
@JS()
external int _sound_get_pulse_data(int sound);

// JS sound data

@JS()
external int _encoded_sound_data_get_is_looped(int self);
@JS()
external void _encoded_sound_data_set_looped(int self, int value, int delay_ms);

@JS()
external int _waveform_sound_data_get_type(int self);
@JS()
external void _waveform_sound_data_set_type(int self, int value);

@JS()
external double _waveform_sound_data_get_freq(int self);
@JS()
external void _waveform_sound_data_set_freq(int self, double value);

@JS()
external double _pulse_sound_data_get_freq(int self);
@JS()
external void _pulse_sound_data_set_freq(int self, double value);

@JS()
external double _pulse_sound_data_get_duty_cycle(int self);
@JS()
external void _pulse_sound_data_set_duty_cycle(int self, double value);

// JS recorder

@JS()
external int _recorder_alloc(int min_rec_count);
Future<int> _recorder_init(int self, int period_ms) async => (_ccall(
      "recorder_init",
      _ccallTypeNumber,
      [_ccallTypeNumber, _ccallTypeNumber].toJS,
      [self.toJS, period_ms.toJS].toJS,
      _ccallAsyncOpts,
    ) as JSPromise)
        .toDart
        .then((res) => (res as JSNumber).toDartInt);
@JS()
external void _recorder_uninit(int self);

@JS()
external int _recorder_get_is_recording(int self, int rec);

@JS()
external int _recorder_start(int self);

@JS()
external int _recorder_save_rec(
  int self,
  int rec,
  int encoding,
  int sample_format,
  int channel_count,
  int sample_rate,
  int data_ptr,
  int data_size_ptr,
);
@JS()
external int _recorder_resume_rec(int self, int rec);
@JS()
external int _recorder_pause_rec(int self, int rec);

// JS rec

@JS()
external int _rec_alloc();
@JS()
external void _rec_uninit(int self);
@JS()
Future<int> _rec_end(int self) => (_ccall(
      "rec_end",
      _ccallTypeNumber,
      [_ccallTypeNumber].toJS,
      [self.toJS].toJS,
      _ccallAsyncOpts,
    ) as JSPromise)
        .toDart
        .then((res) => (res as JSNumber).toDartInt);
