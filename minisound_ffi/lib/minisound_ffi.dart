import "dart:ffi";
import "dart:io";

import "package:ffi/ffi.dart";
import "package:flutter/services.dart";
import "package:minisound_ffi/minisound_ffi_bindings.dart" as ffi;
import "package:minisound_platform_interface/minisound_platform_interface.dart";

// dynamic lib
const String _libName = "minisound_ffi";
final _bindings = ffi.MinisoundFfiBindings(() {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open("$_libName.framework/$_libName");
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open("lib$_libName.so");
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("$_libName.dll");
  }
  throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
}());

// minisound ffi
class MinisoundFfi extends MinisoundPlatform {
  MinisoundFfi._();

  static void registerWith() => MinisoundPlatform.instance = MinisoundFfi._();

  @override
  PlatformEngine createEngine() {
    final self = _bindings.engine_alloc();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiEngine(self);
  }
}

// engine ffi
final class FfiEngine implements PlatformEngine {
  FfiEngine(Pointer<ffi.Engine> self) : _self = self;

  final Pointer<ffi.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    if (_bindings.engine_init(_self, periodMs) != ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine.");
    }
  }

  @override
  void dispose() {
    _bindings.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    if (_bindings.engine_start(_self) != ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to start the engine.");
    }
  }

  @override
  Future<PlatformSound> loadSound(Uint8List data) async {
    // copy data into the memory
    final dataPtr = malloc.allocate<Uint8>(data.lengthInBytes);
    for (var i = 0; i < data.length; i++) {
      dataPtr.elementAt(i).value = data[i];
    }

    // create sound
    final sound =
        _bindings.engine_load_sound(_self, dataPtr.cast(), data.lengthInBytes);
    if (sound == nullptr) {
      throw MinisoundPlatformException("Failed to load a sound.");
    }
    return FfiSound._fromPtrs(sound, dataPtr);
  }

  @override
  void unloadSound(PlatformSound sound) {
    sound as FfiSound;

    _bindings.engine_unload_sound(_self, sound._self);
    malloc.free(sound._data);
  }
}

// sound ffi
final class FfiSound implements PlatformSound {
  FfiSound._fromPtrs(Pointer<ffi.Sound> self, Pointer data)
      : _self = self,
        _data = data,
        _volume = _bindings.sound_get_volume(self),
        _duration = _bindings.sound_get_duration(self);

  final Pointer<ffi.Sound> _self;
  final Pointer _data;

  double _volume;
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    _bindings.sound_set_volume(_self, value);
    _volume = value;
  }

  final double _duration;
  @override
  double get duration => _duration;

  @override
  void play() {
    if (_bindings.sound_play(_self) != ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void pause() => _bindings.sound_pause(_self);
  @override
  void stop() => _bindings.sound_stop(_self);
}
