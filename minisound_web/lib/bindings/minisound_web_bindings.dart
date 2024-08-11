// ignore_for_file: camel_case_types, slash_for_doc_comments
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

@JS("Module")
library minisound;

import "package:js/js.dart";
import "package:js/js_util.dart";
import "package:minisound_web/bindings/wasm/wasm.dart";

// engine

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

final class Engine extends Opaque {}

Pointer<Engine> engine_alloc() => Pointer(_engine_alloc(), 1, safe: true);

Future<int> engine_init(Pointer<Engine> self, int period_ms) =>
    _engine_init(self.addr, period_ms);
void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);

int engine_start(Pointer<Engine> self) => _engine_start(self.addr);

int engine_load_sound(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  Pointer data,
  int data_size,
  int sound_format,
  int channels,
  int sample_rate,
) =>
    _engine_load_sound(
      self.addr,
      sound.addr,
      data.addr,
      data_size,
      sound_format,
      channels,
      sample_rate,
    );

// sound

abstract class SoundFormat {
  static const int SOUND_FORMAT_UNKNOWN = 0;
  static const int SOUND_FORMAT_U8 = 1;
  static const int SOUND_FORMAT_S16 = 2;
  static const int SOUND_FORMAT_S24 = 3;
  static const int SOUND_FORMAT_S32 = 4;
  static const int SOUND_FORMAT_F32 = 5;
  static const int SOUND_FORMAT_COUNT = 6;
}

final class Sound extends Opaque {}

// TODO! this should not be here
Pointer<Sound> sound_alloc(int size) =>
    Pointer(_sound_alloc(), size, safe: true);
void sound_unload(Pointer<Sound> self) => _sound_unload(self.addr);

double sound_get_volume(Pointer<Sound> self) => _sound_get_volume(self.addr);
void sound_set_volume(Pointer<Sound> self, double value) =>
    _sound_set_volume(self.addr, value);

double sound_get_duration(Pointer<Sound> self) =>
    _sound_get_duration(self.addr);

void sound_set_looped(Pointer<Sound> self, bool value, int delay_ms) =>
    _sound_set_looped(self.addr, value, delay_ms);

int sound_play(Pointer<Sound> self) => _sound_play(self.addr);
int sound_replay(Pointer<Sound> self) => _sound_replay(self.addr);
void sound_pause(Pointer<Sound> self) => _sound_pause(self.addr);
void sound_stop(Pointer<Sound> self) => _sound_stop(self.addr);

// recorder

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

final class Recorder extends Opaque {}

Pointer<Recorder> recorder_create() =>
    Pointer(_recorder_create(), 1, safe: true);
void recorder_destroy(Pointer<Recorder> self) => _recorder_destroy(self.addr);

Future<int> recorder_init_file(
  Pointer<Recorder> self,
  String filename,
  int sample_rate,
  int channels,
  int format,
) =>
    _recorder_init_file(
      self.addr,
      filename,
      sample_rate,
      channels,
      format,
    );
Future<int> recorder_init_stream(
  Pointer<Recorder> self,
  int sample_rate,
  int channels,
  int format,
  int buffer_duration_seconds,
) =>
    _recorder_init_stream(
      self.addr,
      sample_rate,
      channels,
      format,
      buffer_duration_seconds,
    );

bool recorder_is_recording(Pointer<Recorder> self) =>
    _recorder_is_recording(self.addr) != 0;

int recorder_start(Pointer<Recorder> self) => _recorder_start(self.addr);
int recorder_stop(Pointer<Recorder> self) => _recorder_stop(self.addr);

int recorder_get_available_frames(Pointer<Recorder> self) =>
    _recorder_get_available_frames(self.addr);
int recorder_get_buffer(
  Pointer<Recorder> self,
  Pointer<Float> output,
  int frames_to_read,
) =>
    _recorder_get_buffer(self.addr, output.addr, frames_to_read);

// generator

abstract class GeneratorResult {
  static const int GENERATOR_OK = 0;
  static const int GENERATOR_ERROR = 1;
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

final class Generator extends Opaque {}

Pointer<Generator> generator_create() =>
    Pointer(_generator_create(), 1, safe: true);
void generator_destroy(Pointer<Generator> self) =>
    _generator_destroy(self.addr);

Future<int> generator_init(
  Pointer<Generator> self,
  int sound_format,
  int channels,
  int sample_rate,
  int buffer_duration_seconds,
) async =>
    _generator_init(
      self.addr,
      sound_format,
      channels,
      sample_rate,
      buffer_duration_seconds,
    );

double generator_get_volume(Pointer<Generator> self) =>
    _generator_get_volume(self.addr);
void generator_set_volume(Pointer<Generator> self, double value) =>
    _generator_set_volume(self.addr, value);

int generator_set_waveform(
  Pointer<Generator> self,
  int type,
  double frequency,
  double amplitude,
) =>
    _generator_set_waveform(self.addr, type, frequency, amplitude);
int generator_set_pulsewave(
  Pointer<Generator> self,
  double frequency,
  double amplitude,
  double dutyCycle,
) =>
    _generator_set_pulsewave(self.addr, frequency, amplitude, dutyCycle);
int generator_set_noise(
  Pointer<Generator> self,
  int type,
  int seed,
  double amplitude,
) =>
    _generator_set_noise(self.addr, type, seed, amplitude);

int generator_start(Pointer<Generator> self) => _generator_start(self.addr);
int generator_stop(Pointer<Generator> self) => _generator_stop(self.addr);

int generator_get_available_frames(Pointer<Generator> self) =>
    _generator_get_available_frames(self.addr);
int generator_get_buffer(
  Pointer<Generator> self,
  Pointer<Float> output,
  int frames_to_read,
) =>
    _generator_get_buffer(self.addr, output.addr, frames_to_read);

// JS

@JS("ccall")
external dynamic _ccall(
  String name,
  String returnType,
  List<String> argTypes,
  List args,
  Map opts,
);

// engine JS bindings
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
  int sound_format,
  int channels,
  int sample_rate,
);

// sound JS bindings
@JS()
external int _sound_alloc();
@JS()
external void _sound_unload(int self);
@JS()
external int _sound_play(int self);
@JS()
external int _sound_replay(int self);
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
external int _sound_set_looped(int self, bool value, int delay_ms);

// recorder JS bindings
@JS()
external int _recorder_create();
@JS()
external void _recorder_destroy(int self);
Future<int> _recorder_init_file(
  int self,
  String filename,
  int sample_rate,
  int channels,
  int sound_format,
) async =>
    promiseToFuture(_ccall(
      "recorder_init_file",
      "number",
      ["number", "string", "number", "number", "number"],
      [self, filename, sample_rate, channels, sound_format],
      {"async": true},
    ));
Future<int> _recorder_init_stream(
  int self,
  int sample_rate,
  int channels,
  int format,
  int buffer_duration_seconds,
) async =>
    promiseToFuture(_ccall(
      "recorder_init_stream",
      "number",
      ["number", "number", "number", "number", "number"],
      [self, sample_rate, channels, format, buffer_duration_seconds],
      {"async": true},
    ));
@JS()
external int _recorder_start(int self);
@JS()
external int _recorder_stop(int self);
@JS()
external int _recorder_get_available_frames(int self);
@JS()
external int _recorder_get_buffer(int self, int output, int frames_to_read);
@JS()
// watch out: enscripten does not support `bool`
external int _recorder_is_recording(int self);

// generator JS bindings
@JS()
external int _generator_create();
@JS()
external void _generator_destroy(int self);
Future<int> _generator_init(
  int self,
  int sound_format,
  int channels,
  int sample_rate,
  int buffer_duration_seconds,
) async =>
    promiseToFuture(_ccall(
      "generator_init",
      "number",
      ["number", "number", "number", "number", "number"],
      [self, sound_format, channels, sample_rate, buffer_duration_seconds],
      {"async": true},
    ));
@JS()
external int _generator_set_waveform(
  int self,
  int type,
  double frequency,
  double amplitude,
);
@JS()
external int _generator_set_pulsewave(
  int self,
  double frequency,
  double amplitude,
  double dutyCycle,
);
@JS()
external int _generator_set_noise(
  int self,
  int type,
  int seed,
  double amplitude,
);
@JS()
external int _generator_start(int self);
@JS()
external int _generator_stop(int self);
@JS()
external double _generator_get_volume(int self);
@JS()
external void _generator_set_volume(int self, double value);
@JS()
external int _generator_get_buffer(int self, int output, int frames_to_read);
@JS()
external int _generator_get_available_frames(int self);
