import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/minisound.dart" as wasm;
import "package:minisound_web/bindings/wasm/wasm.dart";

// minisound web
class MinisoundWeb extends MinisoundPlatform {
  MinisoundWeb._();

  static void registerWith(Never _) =>
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

  late double _volume = wasm.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    wasm.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  late final double duration = wasm.sound_get_duration(_self);

  bool _isLooped = false;
  @override
  bool get isLooped => _isLooped;
  @override
  set isLooped(bool value) {
    if (wasm.sound_set_is_looped(_self, value) != wasm.Result.Ok) return;
    _isLooped = value;
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
  void pause() => wasm.sound_pause(_self);
  @override
  void stop() => wasm.sound_stop(_self);
}
