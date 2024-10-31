// ignore_for_file: camel_case_types, avoid_positional_boolean_parameters
// ignore_for_file: prefer_double_quotes
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unused_element, unused_field

@JS("Module")
library minisound;

import "package:js/js.dart";
import "package:js/js_util.dart";
import "package:minisound_web/bindings/wasm/wasm.dart";

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

// engine

final class Engine extends Opaque {}

Future<void> engine_test(Pointer<Uint8> data, int data_size) =>
    _engine_test(data.addr, data_size);
Pointer<Engine> engine_alloc() => Pointer(_engine_alloc());
Future<int> engine_init(Pointer<Engine> self, int period_ms) =>
    _engine_init(self.addr, period_ms);
void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);

int engine_start(Pointer<Engine> self) => _engine_start(self.addr);

int engine_load_sound(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  Pointer<Uint8> data,
  int data_size,
) =>
    _engine_load_sound(self.addr, sound.addr, data.addr, data_size);

int engine_generate_waveform(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  int type,
  double frequency,
) =>
    _engine_generate_waveform(self.addr, sound.addr, type, frequency);
int engine_generate_noise(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  int type,
  int seed,
) =>
    _engine_generate_noise(self.addr, sound.addr, type, seed);
int engine_generate_pulse(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  double frequency,
  double duty_cycle,
) =>
    _engine_generate_pulse(self.addr, sound.addr, frequency, duty_cycle);

// sound

final class Sound extends Opaque {}

final class EncodedSoundData extends Opaque {}

final class WaveformSoundData extends Opaque {}

abstract class WaveformType {
  static const int WAVEFORM_TYPE_SINE = 0;
  static const int WAVEFORM_TYPE_SQUARE = 1;
  static const int WAVEFORM_TYPE_TRIANGLE = 2;
  static const int WAVEFORM_TYPE_SAWTOOTH = 3;
}

final class NoiseSoundData extends Opaque {}

abstract class NoiseType {
  static const int NOISE_TYPE_WHITE = 0;
  static const int NOISE_TYPE_PINK = 1;
  static const int NOISE_TYPE_BROWNIAN = 2;
}

final class PulseSoundData extends Opaque {}

Pointer<Sound> sound_alloc() => Pointer(_sound_alloc());
void sound_unload(Pointer<Sound> self) => _sound_unload(self.addr);

int sound_play(Pointer<Sound> self) => _sound_play(self.addr);
void sound_pause(Pointer<Sound> self) => _sound_pause(self.addr);
void sound_stop(Pointer<Sound> self) => _sound_stop(self.addr);

double sound_get_volume(Pointer<Sound> self) => _sound_get_volume(self.addr);
void sound_set_volume(Pointer<Sound> self, double value) =>
    _sound_set_volume(self.addr, value);

double sound_get_duration(Pointer<Sound> self) =>
    _sound_get_duration(self.addr);

Pointer<EncodedSoundData> sound_get_encoded_data(Pointer<Sound> self) =>
    Pointer(_sound_get_encoded_data(self.addr));
Pointer<WaveformSoundData> sound_get_waveform_data(Pointer<Sound> self) =>
    Pointer(_sound_get_waveform_data(self.addr));
Pointer<NoiseSoundData> sound_get_noise_data(Pointer<Sound> self) =>
    Pointer(_sound_get_noise_data(self.addr));
Pointer<PulseSoundData> sound_get_pulse_data(Pointer<Sound> self) =>
    Pointer(_sound_get_pulse_data(self.addr));

// sound data

bool encoded_sound_data_get_is_looped(Pointer<EncodedSoundData> self) =>
    _encoded_sound_data_get_is_looped(self.addr) != 0;
int encoded_sound_data_set_looped(
        Pointer<EncodedSoundData> self, bool value, int delay_ms) =>
    _encoded_sound_data_set_looped(self.addr, value ? 1 : 0, delay_ms);

void waveform_sound_data_set_type(Pointer<WaveformSoundData> self, int value) =>
    _waveform_sound_data_set_type(self.addr, value);
void waveform_sound_data_set_freq(
        Pointer<WaveformSoundData> self, double value) =>
    _waveform_sound_data_set_freq(self.addr, value);

void noise_sound_data_set_seed(Pointer<NoiseSoundData> self, int value) =>
    _noise_sound_data_set_seed(self.addr, value);

void pulse_sound_data_set_freq(Pointer<PulseSoundData> self, double value) =>
    _pulse_sound_data_set_freq(self.addr, value);
void pulse_sound_data_set_duty_cycle(
  Pointer<PulseSoundData> self,
  double value,
) =>
    _pulse_sound_data_set_duty_cycle(self.addr, value);

// recorder

final class Recorder extends Opaque {}

final class Recording extends Opaque {
  Recording._(this.buf, this.size);

  final Pointer<Uint8> buf;
  final int size;
}

abstract class RecorderFormat {
  static const int RECORDER_FORMAT_U8 = 1;
  static const int RECORDER_FORMAT_S16 = 2;
  static const int RECORDER_FORMAT_S24 = 3;
  static const int RECORDER_FORMAT_S32 = 4;
  static const int RECORDER_FORMAT_F32 = 5;
}

abstract class RecordingEncoding {
  static const int RECORDING_ENCODING_WAV = 1;
}

Pointer<Recorder> recorder_alloc() => Pointer(_recorder_alloc());
Future<int> recorder_init(
  Pointer<Recorder> self,
  int format,
  int channel_count,
  int sample_rate,
) =>
    _recorder_init(self.addr, format, channel_count, sample_rate);
void recorder_uninit(Pointer<Recorder> self) => _recorder_uninit(self.addr);

bool recorder_get_is_recording(Pointer<Recorder> self) =>
    _recorder_get_is_recording(self.addr) != 0;

int recorder_start(Pointer<Recorder> self, int encoding) =>
    _recorder_start(self.addr, encoding);

Recording recorder_stop(Pointer<Recorder> self) {
  final tmpRec = malloc.allocate<Uint8>(_sizeof_recording());

  _recorder_stop(self.addr, tmpRec.addr);
  final buf = Pointer<Uint8>(_recording_get_buf(tmpRec.addr)),
      size = _recording_get_size(tmpRec.addr);
  final rec = Recording._(buf, size);

  malloc.free(tmpRec);

  return rec;
}

// *************
// ** JS part **
// *************

@JS("ccall")
external dynamic _ccall(
  String name,
  String? returnType,
  List<String> argTypes,
  List args,
  Map opts,
);

// JS engine

@deprecated
Future<void> _engine_test(int data, int data_size) async => _ccall(
      "engine_test",
      null,
      ["number", "number"],
      [data, data_size],
      {"async": true},
    );

@JS()
external int _engine_alloc();
Future<int> _engine_init(int self, int period_ms) async =>
    promiseToFuture(_ccall(
      "engine_init",
      "number",
      ["number", "number"],
      [self, period_ms],
      {"async": true},
    ));

@JS()
external void _engine_uninit(int self);
@JS()
external int _engine_start(int self);

@JS()
external int _engine_load_sound(
  int self,
  int sound,
  int data,
  int data_size,
  // int sound_format,
  // int channels,
  // int sample_rate,
);

@JS()
external int _engine_generate_waveform(
  int self,
  int sound,
  int type,
  double frequency,
);
@JS()
external int _engine_generate_noise(int self, int sound, int type, int seed);
@JS()
external int _engine_generate_pulse(
  int self,
  int sound,
  double frequency,
  double duty_cycle,
);

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
external int _encoded_sound_data_set_looped(int self, int value, int delay_ms);

@JS()
external void _waveform_sound_data_set_type(int self, int value);
@JS()
external void _waveform_sound_data_set_freq(int self, double value);

@JS()
external void _noise_sound_data_set_seed(int self, int value);

@JS()
external void _pulse_sound_data_set_freq(int self, double value);
@JS()
external void _pulse_sound_data_set_duty_cycle(int self, double value);

// JS recorder

@JS()
external int _recorder_alloc();
Future<int> _recorder_init(
  int self,
  int format,
  int channel_count,
  int sample_rate,
) async =>
    promiseToFuture(_ccall(
      "recorder_init",
      "number",
      ["number", "number", "number", "number"],
      [self, format, channel_count, sample_rate],
      {"async": true},
    ));
@JS()
external void _recorder_uninit(int self);

@JS()
external int _recorder_get_is_recording(int self);

@JS()
external int _recorder_start(int self, int encoding);
void _recorder_stop(int self, int out_recording) => _ccall(
      "recorder_stop",
      null,
      ["number", "number"],
      [out_recording, self],
      {},
    );

@JS()
external int _sizeof_recording();
@JS()
external int _recording_get_buf(int self);
@JS()
external int _recording_get_size(int self);
