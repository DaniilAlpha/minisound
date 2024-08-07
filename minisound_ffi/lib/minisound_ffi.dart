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

  @override
  PlatformRecorder createRecorder() {
    final self = _bindings.recorder_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiRecorder(self);
  }

  @override
  PlatformGenerator createGenerator() {
    final self = _bindings.generator_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiGenerator(self);
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
  Future<PlatformSound> loadSound(AudioData audioData) async {
    final dataPtr =
        _allocateForFormat(audioData.format, audioData.buffer.lengthInBytes);

    _copyAudioData(dataPtr, audioData.buffer, audioData.format);

    final sound = _bindings.sound_alloc();
    if (sound == nullptr) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    final maFormat = convertToMaFormat(audioData.format);

    if (_bindings.engine_load_sound(
          _self,
          sound,
          dataPtr.cast(),
          audioData.buffer.lengthInBytes,
          maFormat,
          audioData.sampleRate,
          audioData.channels,
        ) !=
        ffi.Result.Ok) {
      malloc.free(dataPtr);
      _bindings.sound_unload(sound);
      throw MinisoundPlatformException("Failed to load a sound.");
    }

    return FfiSound._fromPtrs(sound, dataPtr);
  }

  // ma_format_unknown = 0,     /* Mainly used for indicating an error, but also used as the default for the output format for decoders. */
  // ma_format_u8      = 1,
  // ma_format_s16     = 2,     /* Seems to be the most widely supported format. */
  // ma_format_s24     = 3,     /* Tightly packed. 3 bytes per sample. */
  // ma_format_s32     = 4,
  // ma_format_f32     = 5,

  void _copyAudioData(
      Pointer<NativeType> ptr, dynamic data, AudioFormat format) {
    var thisData;
    if (data is ByteBuffer) {
      thisData = _getTypedDataViewFromByteBuffer(data, format);
    }

    if (thisData is! TypedData) {
      throw ArgumentError('Data must be either ByteBuffer or TypedData');
    }

    switch (format) {
      case AudioFormat.uint8:
        final list =
            (ptr as Pointer<Uint8>).asTypedList(thisData.lengthInBytes);
        list.setAll(0, data as Uint8List);
        break;
      case AudioFormat.int16:
        final list =
            (ptr as Pointer<Int16>).asTypedList(thisData.lengthInBytes ~/ 2);
        list.setAll(0, data as Int16List);
        break;
      case AudioFormat.int32:
        final list =
            (ptr as Pointer<Int32>).asTypedList(thisData.lengthInBytes ~/ 4);
        list.setAll(0, data as Int32List);
        break;
      case AudioFormat.float32:
        final list =
            (ptr as Pointer<Float>).asTypedList(thisData.lengthInBytes ~/ 4);
        list.setAll(0, data as Float32List);
        break;
      case AudioFormat.float64:
        final list =
            (ptr as Pointer<Double>).asTypedList(thisData.lengthInBytes ~/ 8);
        list.setAll(0, data as Float64List);
        break;
      default:
        throw ArgumentError('Unsupported audio format: $format');
    }
  }

  Pointer<NativeType> _allocateForFormat(
      AudioFormat format, int lengthInBytes) {
    switch (format) {
      case AudioFormat.uint8:
        return malloc.allocate<Uint8>(lengthInBytes);
      case AudioFormat.int16:
        return malloc.allocate<Int16>(lengthInBytes ~/ 2);
      case AudioFormat.int32:
        return malloc.allocate<Int32>(lengthInBytes ~/ 4);
      case AudioFormat.float32:
        return malloc.allocate<Float>(lengthInBytes ~/ 4);
      case AudioFormat.float64:
        return malloc.allocate<Double>(lengthInBytes ~/ 8);
      default:
        throw ArgumentError('Unsupported audio format: $format');
    }
  }

  TypedData _getTypedDataViewFromByteBuffer(
      ByteBuffer buffer, AudioFormat format) {
    switch (format) {
      case AudioFormat.uint8:
        return buffer.asUint8List();
      case AudioFormat.int16:
        return buffer.asInt16List();
      case AudioFormat.int32:
        return buffer.asInt32List();
      case AudioFormat.float32:
        return buffer.asFloat32List();
      case AudioFormat.float64:
        return buffer.asFloat64List();
      default:
        throw ArgumentError('Unsupported audio format: $format');
    }
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
  Future<void> initFile(String filename,
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32}) async {
    final filenamePtr = filename.toNativeUtf8();
    try {
      if (_bindings.recorder_init_file(
              _self, filenamePtr.cast(), sampleRate, channels, format) !=
          ffi.RecorderResult.RECORDER_OK) {
        throw MinisoundPlatformException(
            "Failed to initialize recorder with file.");
      }
    } finally {
      malloc.free(filenamePtr);
    }
  }

  @override
  Future<void> initStream(
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32,
      int bufferDurationSeconds = 5}) async {
    if (_bindings.recorder_init_stream(
            _self, sampleRate, channels, format, bufferDurationSeconds) !=
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
  int getAvailableFrames() {
    return _bindings.recorder_get_available_frames(_self);
  }

  @override
  void dispose() {
    _bindings.recorder_destroy(_self);
  }
}

// generator ffi
class FfiGenerator implements PlatformGenerator {
  FfiGenerator(Pointer<ffi.Generator> self) : _self = self;

  final Pointer<ffi.Generator> _self;

  @override
  Future<void> init(int format, int channels, int sampleRate,
      int bufferDurationSeconds) async {
    final result = await _bindings.generator_init(
        _self, format, channels, sampleRate, bufferDurationSeconds);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize generator. Error code: $result");
    }
  }

  @override
  void setWaveform(WaveformType type, double frequency, double amplitude) {
    final result = _bindings.generator_set_waveform(
        _self, type.index, frequency, amplitude);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set waveform.");
    }
  }

  @override
  void setPulsewave(double frequency, double amplitude, double dutyCycle) {
    final result = _bindings.generator_set_pulsewave(
        _self, frequency, amplitude, dutyCycle);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set pulse wave.");
    }
  }

  @override
  void setNoise(NoiseType type, int seed, double amplitude) {
    final result =
        _bindings.generator_set_noise(_self, type.index, seed, amplitude);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set noise.");
    }
  }

  @override
  void start() {
    final result = _bindings.generator_start(_self);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to start generator.");
    }
  }

  @override
  void stop() {
    final result = _bindings.generator_stop(_self);
    if (result != ffi.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to stop generator.");
    }
  }

  @override
  Float32List getBuffer(int framesToRead) {
    final bufferPtr = malloc.allocate<Float>(framesToRead);
    try {
      final framesRead =
          _bindings.generator_get_buffer(_self, bufferPtr, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException(
            "Failed to read generator data. Error code: $framesRead");
      }
      return bufferPtr.asTypedList(framesRead);
    } finally {
      malloc.free(bufferPtr);
    }
  }

  @override
  int getAvailableFrames() => _bindings.generator_get_available_frames(_self);

  @override
  void dispose() {
    _bindings.generator_destroy(_self);
  }
}
