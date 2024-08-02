import "dart:ffi";
import "dart:io";
import "dart:typed_data";

import "package:ffi/ffi.dart";
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
      (dataPtr + i).value = data[i];
    }

    // create sound
    final sound = _bindings.sound_alloc();
    if (sound == nullptr) {
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    if (_bindings.engine_load_sound(
          _self,
          sound,
          dataPtr.cast(),
          data.lengthInBytes,
        ) !=
        ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to load a sound.");
    }

    return FfiSound._fromPtrs(sound, dataPtr);
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

  PlatformSoundLooping _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    _bindings.sound_set_looped(_self, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    _bindings.sound_unload(_self);
    malloc.free(_data);
  }

  @override
  void play() {
    if (_bindings.sound_play(_self) != ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void replay() {
    if (_bindings.sound_replay(_self) != ffi.Result.Ok) {
      throw MinisoundPlatformException("Failed to replay the sound.");
    }
  }

  @override
  void pause() => _bindings.sound_pause(_self);
  @override
  void stop() => _bindings.sound_stop(_self);
}

// recorder ffi
class FfiRecorder implements PlatformRecorder {
  FfiRecorder(Pointer<ffi.Recorder> self) : _self = self;

  final Pointer<ffi.Recorder> _self;

  @override
  Future<void> initFile(String filename) async {
    final filenamePtr = filename.toNativeUtf8();
    try {
      if (_bindings.recorder_init_file(_self, filenamePtr.cast()) !=
          ffi.RecorderResult.RECORDER_OK) {
        throw MinisoundPlatformException(
            "Failed to initialize recorder with file.");
      }
    } finally {
      malloc.free(filenamePtr);
    }
  }

  @override
  Future<void> initStream() async {
    if (_bindings.recorder_init_stream(_self) !=
        ffi.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to initialize recorder stream.");
    }
  }

  @override
  void start() {
    if (_bindings.recorder_start(_self) != ffi.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording.");
    }
  }

  @override
  void stop() {
    if (_bindings.recorder_stop(_self) != ffi.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to stop recording.");
    }
  }

  @override
  bool get isRecording => _bindings.recorder_is_recording(_self);

  @override
  Float32List getBuffer(int framesToRead) {
    final output = malloc<Float>(framesToRead);
    try {
      final framesRead =
          _bindings.recorder_get_buffer(_self, output, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException("Failed to get recorder buffer.");
      }
      return output.asTypedList(framesRead);
    } finally {
      malloc.free(output);
    }
  }

  @override
  void dispose() {
    _bindings.recorder_destroy(_self);
  }
}

// wave ffi
class FfiWave implements PlatformWave {
  FfiWave(Pointer<ffi.Wave> self) : _self = self;

  final Pointer<ffi.Wave> _self;

  @override
  Future<void> init(
      int type, double frequency, double amplitude, int sampleRate) async {
    if (_bindings.wave_init(_self, type, frequency, amplitude, sampleRate) !=
        ffi.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to initialize wave.");
    }
  }

  @override
  void setType(int type) {
    if (_bindings.wave_set_type(_self, type) != ffi.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave type.");
    }
  }

  @override
  void setFrequency(double frequency) {
    if (_bindings.wave_set_frequency(_self, frequency) !=
        ffi.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave frequency.");
    }
  }

  @override
  void setAmplitude(double amplitude) {
    if (_bindings.wave_set_amplitude(_self, amplitude) !=
        ffi.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave amplitude.");
    }
  }

  @override
  void setSampleRate(int sampleRate) {
    if (_bindings.wave_set_sample_rate(_self, sampleRate) !=
        ffi.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave sample rate.");
    }
  }

  @override
  Float32List read(int framesToRead) {
    final output = malloc<Float>(framesToRead);
    try {
      final framesRead = _bindings.wave_read(_self, output, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException("Failed to read wave data.");
      }
      return output.asTypedList(framesRead);
    } finally {
      malloc.free(output);
    }
  }

  @override
  void dispose() {
    _bindings.wave_destroy(_self);
  }
}
