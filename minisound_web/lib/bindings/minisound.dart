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

final class Generator extends Opaque {}

// JS interop
@JS("ccall")
external dynamic _ccall(
    String name, String returnType, List<String> argTypes, List args, Map opts);

// Engine functions
Pointer<Engine> engine_alloc() => Pointer(_engine_alloc(), 1, safe: true);
Future<int> engine_init(Pointer<Engine> self, int periodMs) =>
    _engine_init(self.addr, periodMs);
void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);
int engine_start(Pointer<Engine> self) => _engine_start(self.addr);
int engine_load_sound(Pointer<Engine> self, Pointer<Sound> sound, Pointer data,
        int dataSize, int format, int sampleRate, int channels) =>
    _engine_load_sound(self.addr, sound.addr, data.addr, dataSize, format,
        sampleRate, channels);

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
@JS()
external int _engine_load_sound(int self, int sound, int data, int dataSize,
    int format, int sampleRate, int channels);

// Sound functions
Pointer<Sound> sound_alloc() => Pointer(_sound_alloc(), 1, safe: true);
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

// Recorder functions
Pointer<Recorder> recorder_create() =>
    Pointer(_recorder_create(), 1, safe: true);
Future<int> recorder_init_file(Pointer<Recorder> self, String filename,
        {int sampleRate = 44800,
        int channels = 1,
        int format = AudioFormat.float32}) =>
    _recorder_init_file(self.addr, filename,
        sampleRate: sampleRate, channels: channels, format: format);
Future<int> recorder_init_stream(Pointer<Recorder> self,
        {int sampleRate = 44800,
        int channels = 1,
        int format = AudioFormat.float32,
        int bufferDurationSeconds = 5}) =>
    _recorder_init_stream(self.addr,
        sampleRate: sampleRate,
        channels: channels,
        format: format,
        bufferDurationSeconds: bufferDurationSeconds);
int recorder_start(Pointer<Recorder> self) => _recorder_start(self.addr);
int recorder_stop(Pointer<Recorder> self) => _recorder_stop(self.addr);
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
        int format = AudioFormat.float32}) async =>
    promiseToFuture(_ccall(
        "recorder_init_file",
        "number",
        ["number", "string", "number", "number", "number"],
        [self, filename, sampleRate, channels, format],
        {"async": true}));
Future<int> _recorder_init_stream(int self,
        {int sampleRate = 44800,
        int channels = 1,
        int format = AudioFormat.float32,
        int bufferDurationSeconds = 5}) async =>
    promiseToFuture(_ccall(
        "recorder_init_stream",
        "number",
        ["number", "number", "number", "number", "number"],
        [self, sampleRate, channels, format, bufferDurationSeconds],
        {"async": true}));

// Recorder JS bindings
@JS()
external int _recorder_start(int self);
@JS()
external int _recorder_stop(int self);
@JS()
external int _recorder_get_available_frames(int self);
@JS()
external bool _recorder_is_recording(int self);
@JS()
external int _recorder_get_buffer(int self, int output, int frames_to_read);
@JS()
external void _recorder_destroy(int self);

// Generator functions
Pointer<Generator> generator_create() =>
    Pointer(_generator_create(), 1, safe: true);
Future<int> generator_init(Pointer<Generator> self, int format, int channels,
        int sample_rate, int buffer_duration_seconds) async =>
    _generator_init(self.addr,
        format: format,
        channels: channels,
        sampleRate: sample_rate,
        bufferDuration: buffer_duration_seconds);
int generator_set_waveform(Pointer<Generator> self, int type, double frequency,
        double amplitude) =>
    _generator_set_waveform(self.addr, type, frequency, amplitude);
int generator_set_pulsewave(Pointer<Generator> self, double frequency,
        double amplitude, double dutyCycle) =>
    _generator_set_pulsewave(self.addr, frequency, amplitude, dutyCycle);
int generator_set_noise(
        Pointer<Generator> self, int type, int seed, double amplitude) =>
    _generator_set_noise(self.addr, type, seed, amplitude);
int generator_get_buffer(
        Pointer<Generator> self, Pointer<Float> output, int frames_to_read) =>
    _generator_get_buffer(self.addr, output.addr, frames_to_read);
int generator_start(Pointer<Generator> self) => _generator_start(self.addr);
int generator_stop(Pointer<Generator> self) => _generator_stop(self.addr);
double generator_get_volume(Pointer<Generator> self) =>
    _generator_get_volume(self.addr);
void generator_set_volume(Pointer<Generator> self, double value) =>
    _generator_set_volume(self.addr, value);
int generator_get_available_frames(Pointer<Generator> self) =>
    _generator_get_available_frames(self.addr);
void generator_destroy(Pointer<Generator> self) =>
    _generator_destroy(self.addr);

// Generator JS bindings
@JS()
external int _generator_create();

Future<int> _generator_init(int self,
        {int sampleRate = 44800,
        int channels = 1,
        int format = 4,
        int bufferDuration = 5}) async =>
    promiseToFuture(_ccall(
        "generator_init",
        "number",
        ["number", "number", "number", "number", "number"],
        [self, format, channels, sampleRate, bufferDuration],
        {"async": true}));
@JS()
external int _generator_set_waveform(
    int self, int type, double frequency, double amplitude);
@JS()
external int _generator_set_pulsewave(
    int self, double frequency, double amplitude, double dutyCycle);
@JS()
external int _generator_set_noise(
    int self, int type, int seed, double amplitude);
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
@JS()
external void _generator_destroy(int self);
