// ignore_for_file: cam, slash_for_doc_comments
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names

@JS("Module")
library minisound;

import "package:js/js.dart";
import "package:js/js_util.dart";
import "package:minisound_web/bindings/wasm/wasm.dart";

final class Engine extends Opaque {}

final class Sound extends Opaque {}

abstract class Result {
  static const int Ok = 0;
  static const int UnknownErr = 1;
  static const int OutOfMemErr = 2;
  static const int RangeErr = 3;
  static const int ResultCount = 4;
}

// engine functions

Pointer<Engine> engine_alloc() => Pointer(_engine_alloc());

Future<int> engine_init(Pointer<Engine> self, int periodMs) =>
    _engine_init(self.addr, periodMs);

void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);
int engine_start(Pointer<Engine> self) => _engine_start(self.addr);

int engine_load_sound(
  Pointer<Engine> self,
  Pointer<Sound> sound,
  Pointer data,
  int dataSize,
) =>
    _engine_load_sound(self.addr, sound.addr, data.addr, dataSize);

// sound functions

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

// ignore: avoid_positional_boolean_parameters
void sound_set_looped(Pointer<Sound> self, bool value, int delay_ms) =>
    _sound_set_looped(self.addr, value, delay_ms);

/********
 ** js **
 ********/

@JS("ccall")
external dynamic _ccall(
  String name,
  String returnType,
  List<String> argTypes,
  List args,
  Map opts,
);

// engine functions

@JS()
external int _engine_alloc();

Future<int> _engine_init(int self, int periodMs) async =>
    promiseToFuture(_ccall(
      "engine_init",
      "number",
      ["number", "number"],
      [self, periodMs],
      {"async": true},
    ));

@JS()
external void _engine_uninit(int self);

@JS()
external int _engine_start(int self);

@JS()
external int _engine_load_sound(int self, int sound, int data, int data_size);

// sound functions

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
