import "dart:typed_data";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/minisound.dart" as wasm;
import "package:minisound_web/bindings/wasm/wasm.dart";

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
  PlatformGenerator createGenerator() {
    final self = wasm.generator_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebGenerator(self);
  }
}

final class WebEngine implements PlatformEngine {
  WebEngine(this._self);

  final Pointer<wasm.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    if (await wasm.engine_init(_self, periodMs) != Result.Ok) {
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
    if (wasm.engine_start(_self) != Result.Ok) {
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

    if (result != Result.Ok) {
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
    if (wasm.sound_play(_self) != Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void replay() {
    if (wasm.sound_replay(_self) != Result.Ok) {
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
    if (result != RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file. Error code: $result");
    }
  }

  @override
  Future<void> initStream(
      {int sampleRate = 44800,
      int channels = 1,
      int format = MaFormat.ma_format_f32,
      int bufferDurationSeconds = 5}) async {
    final result = await wasm.recorder_init_stream(_self,
        sampleRate: sampleRate,
        channels: channels,
        format: format,
        bufferDurationSeconds: bufferDurationSeconds);
    if (result != RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder stream. Error code: $result");
    }
  }

  @override
  void start() {
    if (wasm.recorder_start(_self) != RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording.");
    }
  }

  @override
  void stop() {
    if (wasm.recorder_stop(_self) != RecorderResult.RECORDER_OK) {
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

final class WebGenerator implements PlatformGenerator {
  WebGenerator(this._self);
  final Pointer<wasm.Generator> _self;

  @override
  Future<void> init(int format, int channels, int sampleRate,
      int bufferDurationSeconds) async {
    final result = await wasm.generator_init(
        _self, format, channels, sampleRate, bufferDurationSeconds);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize generator. Error code: $result");
    }
  }

  @override
  void setWaveform(WaveformType type, double frequency, double amplitude) {
    final result =
        wasm.generator_set_waveform(_self, type.index, frequency, amplitude);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set waveform.");
    }
  }

  @override
  void setPulsewave(double frequency, double amplitude, double dutyCycle) {
    final result =
        wasm.generator_set_pulsewave(_self, frequency, amplitude, dutyCycle);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set pulse wave.");
    }
  }

  @override
  void setNoise(NoiseType type, int seed, double amplitude) {
    final result = wasm.generator_set_noise(_self, type.index, seed, amplitude);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set noise.");
    }
  }

  @override
  void start() {
    final result = wasm.generator_start(_self);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to start generator.");
    }
  }

  @override
  void stop() {
    final result = wasm.generator_stop(_self);
    if (result != GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to stop generator.");
    }
  }

  @override
  Float32List getBuffer(int framesToRead) {
    final bufferPtr = malloc.allocate<Float>(framesToRead);
    try {
      final framesRead =
          wasm.generator_get_buffer(_self, bufferPtr, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException(
            "Failed to read generator data. Error code: $framesRead");
      }
      return Float32List.fromList(
          bufferPtr.asTypedList(framesRead) as List<double>);
    } finally {
      malloc.free(bufferPtr);
    }
  }

  @override
  int getAvailableFrames() => wasm.generator_get_available_frames(_self);

  @override
  void dispose() {
    wasm.generator_destroy(_self);
    malloc.free(_self);
  }
}
