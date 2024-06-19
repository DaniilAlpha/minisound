import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/minisound.dart" as wasm;
import "package:minisound_web/bindings/wasm/wasm.dart";

// minisound web
class MinisoundWeb extends MinisoundPlatform {
  MinisoundWeb._();

  static void registerWith(dynamic _) =>
      MinisoundPlatform.instance = MinisoundWeb._();

  @override
  PlatformEngine createEngine() {
    final self = wasm.engine_alloc();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebEngine(self);
  }
}

// engine web
final class WebEngine implements PlatformEngine {
  WebEngine(Pointer<wasm.Engine> self) : _self = self;

  final Pointer<wasm.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    if (await wasm.engine_init(_self, periodMs) != wasm.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine.");
    }
  }

  @override
  void dispose() {
    wasm.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    if (wasm.engine_start(_self) != wasm.Result.Ok) {
      throw MinisoundPlatformException("Failed to start the engine.");
    }
  }

  @override
  Future<PlatformSound> loadSound(Uint8List data) async {
    // copy data into the memory
    final dataPtr = malloc.allocate(data.lengthInBytes);
    heap.copy(dataPtr, data);

    // create sound
    final sound = wasm.sound_alloc();
    if (sound == nullptr) {
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    if (wasm.engine_load_sound(_self, sound, dataPtr, data.lengthInBytes) !=
        wasm.Result.Ok) {
      throw MinisoundPlatformException("Failed to load a sound.");
    }
    return WebSound._fromPtrs(sound, dataPtr);
  }
}

// sound web
final class WebSound implements PlatformSound {
  WebSound._fromPtrs(Pointer<wasm.Sound> self, Pointer data)
      : _self = self,
        _data = data;

  final Pointer<wasm.Sound> _self;
  final Pointer _data;

  late var _volume = wasm.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    wasm.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  late double duration = wasm.sound_get_duration(_self);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    wasm.sound_set_looped(_self, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    wasm.sound_unload(_self);
    malloc.free(_data);
  }

  @override
  void play() {
    if (wasm.sound_play(_self) != wasm.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void replay() {
    if (wasm.sound_replay(_self) != wasm.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void pause() => wasm.sound_pause(_self);
  @override
  void stop() => wasm.sound_stop(_self);
}
