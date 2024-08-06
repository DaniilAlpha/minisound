// ignore_for_file: camel_case_types, slash_for_doc_comments
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

@JS("Module")
library minisound;

import "package:js/js.dart";
import "package:js/js_util.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/wasm/wasm.dart";

final class Engine extends Opaque {}

final class Sound extends Opaque {}

final class Recorder extends Opaque {}

final class Wave extends Opaque {}

typedef OnFramesAvailableCallback = void Function(
    Pointer<dynamic> frames, int frameCount);

@JS()
@anonymous
class FrameData {
  external Pointer<Float> get frames;
  external int get frame_count;
}

abstract class Result {
  static const int Ok = 0;
  static const int UnknownErr = 1;
  static const int OutOfMemErr = 2;
  static const int RangeErr = 3;
  static const int ResultCount = 4;
}

abstract class RecorderResult {
  static const int RECORDER_OK = 0;
  static const int RECORDER_ERROR_UNKNOWN = 1;
  static const int RECORDER_ERROR_OUT_OF_MEMORY = 2;
  static const int RECORDER_ERROR_INVALID_ARGUMENT = 3;
  static const int RECORDER_ERROR_ALREADY_RECORDING = 4;
  static const int RECORDER_ERROR_NOT_RECORDING = 5;
}

abstract class WaveResult {
  static const int WAVE_OK = 0;
  static const int WAVE_ERROR = 1;
}

abstract class WaveType {
  static const int WAVE_TYPE_SINE = 0;
  static const int WAVE_TYPE_SQUARE = 1;
  static const int WAVE_TYPE_TRIANGLE = 2;
  static const int WAVE_TYPE_SAWTOOTH = 3;
}

// Engine functions
Pointer<Engine> engine_alloc() => Pointer(_engine_alloc(), safe: true);
Future<int> engine_init(Pointer<Engine> self, int periodMs) =>
    _engine_init(self.addr, periodMs);
void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);
int engine_start(Pointer<Engine> self) => _engine_start(self.addr);
int engine_load_sound_ex(Pointer<Engine> self, Pointer<Sound> sound,
        Pointer data, int dataSize, int format, int sampleRate, int channels) =>
    _engine_load_sound_ex(self.addr, sound.addr, data.addr, dataSize, format,
        sampleRate, channels);

// Sound functions
Pointer<Sound> sound_alloc() => Pointer(_sound_alloc());
void sound_unload(Pointer<Sound> self) => _sound_unload(self.addr);
int sound_play(Pointer<Sound> self) => _sound_play(self.addr);
int sound_replay(Pointer<Sound> self) => _sound_replay(self.addr);
void sound_pause(Pointer<Sound> self) => _sound_pause(self.addr);
void sound_stop(Pointer<Sound> self) => _sound_stop(self.addr);
double sound_get_volume(Pointer<Sound> self) => _sound_get_volume(self.addr);
void sound_set_volume(Pointer<Sound> self, double value) =>
    _sound_set_volume(self.addr, value);
double sound_get_duration(Pointer<Sound> self) =>
    _sound_get_duration(self.addr);
void sound_set_looped(Pointer<Sound> self, bool value, int delay_ms) =>
    _sound_set_looped(self.addr, value, delay_ms);

// Recorder functions
Pointer<Recorder> recorder_create() => Pointer(_recorder_create(), safe: true);
Future<int> recorder_init_file(Pointer<Recorder> self, String filename,
        {int sampleRate = 44800,
        int channels = 1,
        int format = MaFormat.ma_format_f32}) =>
    _recorder_init_file(self.addr, filename,
        sampleRate: sampleRate, channels: channels, format: format);
Future<int> recorder_init_stream(Pointer<Recorder> self,
        {int sampleRate = 44800,
        int channels = 1,
        int format = MaFormat.ma_format_f32,
        double bufferDurationSeconds = 5}) =>
    _recorder_init_stream(self.addr,
        sampleRate: sampleRate,
        channels: channels,
        format: format,
        bufferDurationSeconds: bufferDurationSeconds);
int recorder_start(Pointer<Recorder> self) => _recorder_start(self.addr);
int recorder_stop(Pointer<Recorder> self) => _recorder_stop(self.addr);
int recorder_start_streaming(Pointer<Recorder> self,
        OnFramesAvailableCallback callback, Pointer<dynamic> userData) =>
    _recorder_start_streaming(self.addr, allowInterop(callback), userData.addr);
int recorder_stop_streaming(Pointer<Recorder> self) =>
    _recorder_stop_streaming(self.addr);
int recorder_get_available_frames(Pointer<Recorder> self) =>
    _recorder_get_available_frames(self.addr);
bool recorder_is_recording(Pointer<Recorder> self) =>
    _recorder_is_recording(self.addr);
int recorder_get_buffer(
        Pointer<Recorder> self, Pointer<Float> output, int frames_to_read) =>
    _recorder_get_buffer(self.addr, output.addr, frames_to_read);
void recorder_destroy(Pointer<Recorder> self) => _recorder_destroy(self.addr);

// Recorder JS bindings
@JS()
external int _recorder_create();
Future<int> _recorder_init_file(int self, String filename,
        {int sampleRate = 44800,
        int channels = 1,
        int format = MaFormat.ma_format_f32}) async =>
    promiseToFuture(_ccall(
        "recorder_init_file",
        "number",
        ["number", "string", "number", "number", "number"],
        [self, filename, sampleRate, channels, format],
        {"async": true}));
Future<int> _recorder_init_stream(int self,
        {int sampleRate = 44800,
        int channels = 1,
        int format = MaFormat.ma_format_f32,
        double bufferDurationSeconds = 5}) async =>
    promiseToFuture(_ccall(
        "recorder_init_stream",
        "number",
        ["number", "number", "number", "number", "number"],
        [self, sampleRate, channels, format, bufferDurationSeconds],
        {"async": true}));
@JS()
external int _recorder_start(int self);
@JS()
external int _recorder_stop(int self);
@JS()
external int _recorder_start_streaming(
    int self, Function callback, int userData);
@JS()
external int _recorder_stop_streaming(int self);
@JS()
external int _recorder_get_available_frames(int self);
@JS()
external bool _recorder_is_recording(int self);
@JS()
external int _recorder_get_buffer(int self, int output, int frames_to_read);
@JS()
external void _recorder_destroy(int self);

// Wave functions
Pointer<Wave> wave_create() => Pointer(_wave_create(), safe: true);
Future<int> wave_init(Pointer<Wave> self, int type, double frequency,
        double amplitude, int sample_rate) =>
    _wave_init(self.addr, type, frequency, amplitude, sample_rate);
int wave_set_type(Pointer<Wave> self, int type) =>
    _wave_set_type(self.addr, type);
int wave_set_frequency(Pointer<Wave> self, double frequency) =>
    _wave_set_frequency(self.addr, frequency);
int wave_set_amplitude(Pointer<Wave> self, double amplitude) =>
    _wave_set_amplitude(self.addr, amplitude);
int wave_set_sample_rate(Pointer<Wave> self, int sample_rate) =>
    _wave_set_sample_rate(self.addr, sample_rate);
int wave_read(Pointer<Wave> self, Pointer<Float> output, int frames_to_read) =>
    _wave_read(self.addr, output.addr, frames_to_read);
void wave_destroy(Pointer<Wave> self) => _wave_destroy(self.addr);

// JS interop
@JS("ccall")
external dynamic _ccall(
    String name, String returnType, List<String> argTypes, List args, Map opts);

// Engine JS bindings
@JS()
external int _engine_alloc();
Future<int> _engine_init(int self, int periodMs) async =>
    promiseToFuture(_ccall("engine_init", "number", ["number", "number"],
        [self, periodMs], {"async": true}));
@JS()
external void _engine_uninit(int self);
@JS()
external int _engine_start(int self);
@JS("_engine_load_sound_ex")
external int _engine_load_sound_ex(int self, int sound, int data, int dataSize,
    int format, int sampleRate, int channels);

// Sound JS bindings
@JS()
external int _sound_alloc();
@JS()
external void _sound_unload(int sound);
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

// Wave JS bindings
@JS()
external int _wave_create();
Future<int> _wave_init(int self, int type, double frequency, double amplitude,
        int sample_rate) async =>
    promiseToFuture(_ccall(
        "wave_init",
        "number",
        ["number", "number", "number", "number", "number"],
        [self, type, frequency, amplitude, sample_rate],
        {"async": true}));
@JS()
external int _wave_set_type(int self, int type);
@JS()
external int _wave_set_frequency(int self, double frequency);
@JS()
external int _wave_set_amplitude(int self, double amplitude);
@JS()
external int _wave_set_sample_rate(int self, int sample_rate);
@JS()
external int _wave_read(int self, int output, int frames_to_read);
@JS()
external void _wave_destroy(int self);
