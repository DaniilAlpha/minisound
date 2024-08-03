import 'dart:typed_data';
import 'package:minisound_platform_interface/minisound_platform_interface.dart';
import 'package:minisound_web/bindings/minisound.dart' as wasm;
import 'package:minisound_web/bindings/wasm/wasm.dart';

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

  @override
  PlatformRecorder createRecorder() {
    final self = wasm.recorder_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebRecorder(self);
  }

  @override
  PlatformWave createWave() {
    final self = wasm.wave_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebWave(self);
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
    final result =
        wasm.engine_load_sound(_self, sound, dataPtr, data.lengthInBytes);
    if (result != wasm.Result.Ok) {
      print(result);
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
  late final double duration = wasm.sound_get_duration(_self);

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
      throw MinisoundPlatformException("Failed to replay the sound.");
    }
  }

  @override
  void pause() => wasm.sound_pause(_self);
  @override
  void stop() => wasm.sound_stop(_self);
}

// recorder web
final class WebRecorder implements PlatformRecorder {
  WebRecorder(this._self);

  final Pointer<wasm.Recorder> _self;

  @override
  Future<void> initFile(String filename) async {
    final result = await wasm.recorder_init_file(_self, filename);
    if (result != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file.");
    }
  }

  @override
  Future<void> initStream() async {
    final result = await wasm.recorder_init_stream(_self);
    if (result != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to initialize recorder stream.");
    }
  }

  @override
  void start() {
    if (wasm.recorder_start(_self) != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording.");
    }
  }

  @override
  void stop() {
    if (wasm.recorder_stop(_self) != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to stop recording.");
    }
  }

  @override
  bool get isRecording => wasm.recorder_is_recording(_self);

  @override
  Float32List getBuffer(int framesToRead) {
    final bufferPtr = malloc.allocate<double>(framesToRead);
    final framesRead = wasm.recorder_get_buffer(_self, bufferPtr, framesToRead);
    if (framesRead < 0) {
      malloc.free(bufferPtr);
      throw MinisoundPlatformException("Failed to get recorder buffer.");
    }
    final result = Float32List.fromList(List.generate(
        framesRead, (i) => bufferPtr.elementAt(i).value.toDouble()));
    malloc.free(bufferPtr);
    return result;
  }

  @override
  void dispose() {
    wasm.recorder_destroy(_self);
    malloc.free(_self);
  }
}

// wave web
final class WebWave implements PlatformWave {
  WebWave(this._self);

  final Pointer<wasm.Wave> _self;

  @override
  Future<void> init(
      int type, double frequency, double amplitude, int sampleRate) async {
    final result =
        await wasm.wave_init(_self, type, frequency, amplitude, sampleRate);
    if (result != wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to initialize wave.");
    }
  }

  @override
  void setType(int type) {
    if (wasm.wave_set_type(_self, type) != wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave type.");
    }
  }

  @override
  void setFrequency(double frequency) {
    if (wasm.wave_set_frequency(_self, frequency) != wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave frequency.");
    }
  }

  @override
  void setAmplitude(double amplitude) {
    if (wasm.wave_set_amplitude(_self, amplitude) != wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave amplitude.");
    }
  }

  @override
  void setSampleRate(int sampleRate) {
    if (wasm.wave_set_sample_rate(_self, sampleRate) !=
        wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException("Failed to set wave sample rate.");
    }
  }

// In WebWave class
  @override
  Float32List read(int framesToRead) {
    final bufferPtr = malloc.allocate<double>(framesToRead);
    final framesRead = wasm.wave_read(_self, bufferPtr, framesToRead);
    if (framesRead < 0) {
      malloc.free(bufferPtr);
      throw MinisoundPlatformException("Failed to read wave data.");
    }
    final result = Float32List.fromList(List.generate(
        framesRead, (i) => bufferPtr.elementAt(i).value.toDouble()));
    malloc.free(bufferPtr);
    return result;
  }

  @override
  void dispose() {
    wasm.wave_destroy(_self);
    malloc.free(_self);
  }
}
