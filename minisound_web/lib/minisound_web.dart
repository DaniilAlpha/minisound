import 'dart:typed_data';
import 'package:minisound_platform_interface/minisound_platform_interface.dart';
import 'package:minisound_web/bindings/minisound.dart' as wasm;
import 'package:minisound_web/bindings/wasm/wasm.dart';

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

final class WebEngine implements PlatformEngine {
  WebEngine(this._self);

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
  Future<PlatformSound> loadSound(AudioData audioData) async {
    final dataPtr = malloc.allocate(audioData.buffer.lengthInBytes);
    heap.copyAudioData(dataPtr, audioData.buffer, audioData.format);

    final sound = wasm.sound_alloc();
    if (sound == nullptr) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    final maFormat = convertToMaFormat(audioData.format);
    final result = wasm.engine_load_sound(
        _self,
        sound,
        dataPtr,
        audioData.buffer.lengthInBytes,
        maFormat,
        audioData.sampleRate,
        audioData.channels);

    if (result != wasm.Result.Ok) {
      malloc.free(dataPtr);
      wasm.sound_unload(sound);
      throw MinisoundPlatformException("Failed to load a sound.");
    }

    return WebSound._fromPtrs(sound, dataPtr);
  }
}

final class WebSound implements PlatformSound {
  WebSound._fromPtrs(this._self, this._data);

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

final class WebRecorder implements PlatformRecorder {
  WebRecorder(this._self);

  final Pointer<wasm.Recorder> _self;

  @override
  Future<void> initFile(String filename,
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32}) async {
    final result = await wasm.recorder_init_file(_self, filename,
        sampleRate: sampleRate, channels: channels, format: format);
    if (result != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file. Error code: $result");
    }
  }

  @override
  Future<void> initStream(
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32,
      double bufferDurationSeconds = 5}) async {
    final result = await wasm.recorder_init_stream(_self,
        sampleRate: sampleRate,
        channels: channels,
        format: format,
        bufferDurationSeconds: bufferDurationSeconds);
    if (result != wasm.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder stream. Error code: $result");
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
  int getAvailableFrames() => wasm.recorder_get_available_frames(_self);
  Pointer<Float> bufferPtr = malloc.allocate<Float>(0);

  @override
  Float32List getBuffer(int framesToRead, {int channels = 2}) {
    try {
      int floatsToRead =
          framesToRead * 20; // Calculate the actual number of floats to read
      if (bufferPtr.value <= 0) malloc.free(bufferPtr);

      bufferPtr = malloc.allocate<Float>(
          floatsToRead); // Allocate memory for the float buffer
      final floatsRead =
          wasm.recorder_get_buffer(_self, bufferPtr, floatsToRead);

      // Error handling for negative return values
      if (floatsRead < 0) {
        throw MinisoundPlatformException(
            "Failed to get recorder buffer. Error code: $floatsRead");
      }

      // Convert the data in the allocated memory to a Dart Float32List
      return Float32List.fromList(
          bufferPtr.asTypedList(floatsRead) as List<double>);
    } finally {}
  }

  @override
  bool get isRecording => wasm.recorder_is_recording(_self);

  @override
  void dispose() {
    wasm.recorder_destroy(_self);
    malloc.free(_self);
  }
}

final class WebWave implements PlatformWave {
  WebWave(this._self);

  final Pointer<wasm.Wave> _self;

  @override
  Future<void> init(
      int type, double frequency, double amplitude, int sampleRate) async {
    final result =
        await wasm.wave_init(_self, type, frequency, amplitude, sampleRate);
    if (result != wasm.WaveResult.WAVE_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize wave. Error code: $result");
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

  @override
  Float32List read(int framesToRead) {
    final bufferPtr = malloc.allocate<Float>(framesToRead);
    try {
      final framesRead = wasm.wave_read(_self, bufferPtr, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException(
            "Failed to read wave data. Error code: $framesRead");
      }
      return Float32List.fromList(
          bufferPtr.asTypedList(framesRead) as List<double>);
    } finally {
      malloc.free(bufferPtr);
    }
  }

  @override
  void dispose() {
    wasm.wave_destroy(_self);
    malloc.free(_self);
  }
}
