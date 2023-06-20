// ignore_for_file: camel_case_types, slash_for_doc_comments
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
  static const int Error = 1;
}

// engine functions

Pointer<Engine> engine_alloc() => Pointer(_engine_alloc());

Future<int> engine_init(Pointer<Engine> self, int periodMs) =>
    _engine_init(self.addr, periodMs);

void engine_uninit(Pointer<Engine> self) => _engine_uninit(self.addr);
int engine_start(Pointer<Engine> self) => _engine_start(self.addr);

Pointer<Sound> engine_load_sound(
  Pointer<Engine> self,
  Pointer data,
  int dataSize,
) =>
    Pointer(_engine_load_sound(self.addr, data.addr, dataSize));
void engine_unload_sound(Pointer<Engine> self, Pointer<Sound> sound) =>
    _engine_unload_sound(self.addr, sound.addr);

// sound functions

int sound_play(Pointer<Sound> self) => _sound_play(self.addr);
void sound_pause(Pointer<Sound> self) => _sound_pause(self.addr);
void sound_stop(Pointer<Sound> self) => _sound_stop(self.addr);

double sound_get_volume(Pointer<Sound> self) => _sound_get_volume(self.addr);
void sound_set_volume(Pointer<Sound> self, double value) =>
    _sound_set_volume(self.addr, value);

double sound_get_duration(Pointer<Sound> self) =>
    _sound_get_duration(self.addr);

/********
 ** js **
 ********/

// engine functions

@JS()
external int _engine_alloc();

@JS("ccall")
external dynamic _ccall(
  String name,
  String returnType,
  List<String> argTypes,
  List args,
  Map opts,
);

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
external int _engine_load_sound(int self, int data, int dataSize);
@JS()
external void _engine_unload_sound(int self, int sound);

// sound functions

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
