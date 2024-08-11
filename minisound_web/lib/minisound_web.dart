import "dart:typed_data";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/minisound_web_bindings.dart" as c;
import "package:minisound_web/bindings/wasm/wasm.dart";

class MinisoundWeb extends MinisoundPlatform {
  MinisoundWeb._();

  static void registerWith(dynamic _) =>
      MinisoundPlatform.instance = MinisoundWeb._();

  @override
  PlatformEngine createEngine() {
    final self = c.engine_alloc();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebEngine(self);
  }

  @override
  PlatformRecorder createRecorder() {
    final self = c.recorder_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebRecorder(self);
  }

  @override
  PlatformGenerator createGenerator() {
    final self = c.generator_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebGenerator(self);
  }
}

final class WebEngine implements PlatformEngine {
  WebEngine(this._self);

  final Pointer<c.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    if (await c.engine_init(_self, periodMs) != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine.");
    }
  }

  @override
  void dispose() {
    c.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    if (c.engine_start(_self) != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to start the engine.");
    }
  }

  @override
  Future<PlatformSound> loadSound(AudioData audioData) async {
    final dataPtr = malloc.allocate(audioData.buffer.lengthInBytes);
    heap.copyAudioData(dataPtr, audioData.buffer, audioData.format);

    final sound = c.sound_alloc(audioData.buffer.lengthInBytes);
    if (sound == nullptr) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    final result = c.engine_load_sound(
        _self,
        sound,
        dataPtr,
        audioData.buffer.lengthInBytes,
        audioData.format.toC(),
        audioData.sampleRate,
        audioData.channels);

    if (result != c.Result.Ok) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to load a sound.");
    }

    return WebSound._fromPtrs(sound, dataPtr);
  }
}

final class WebSound implements PlatformSound {
  WebSound._fromPtrs(this._self, this._data);

  final Pointer<c.Sound> _self;
  final Pointer _data;

  late var _volume = c.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    c.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  late final double duration = c.sound_get_duration(_self);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;

  @override
  set looping(PlatformSoundLooping value) {
    c.sound_set_looped(_self, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    c.sound_unload(_self);
    malloc.free(_data);
  }

  @override
  void play() {
    if (c.sound_play(_self) != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound.");
    }
  }

  @override
  void replay() {
    if (c.sound_replay(_self) != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to replay the sound.");
    }
  }

  @override
  void pause() => c.sound_pause(_self);
  @override
  void stop() => c.sound_stop(_self);
}

final class WebRecorder implements PlatformRecorder {
  WebRecorder(this._self);

  final Pointer<c.Recorder> _self;

  @override
  Future<void> initFile(
    String filename, {
    required int sampleRate,
    required int channels,
    required SoundFormat format,
  }) async {
    final result = await c.recorder_init_file(
      _self,
      filename,
      sampleRate,
      channels,
      format.toC(),
    );
    if (result != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file. Error code: $result");
    }
  }

  @override
  Future<void> initStream({
    required int sampleRate,
    required int channels,
    required SoundFormat format,
    required int bufferDurationSeconds,
  }) async {
    final result = await c.recorder_init_stream(
      _self,
      sampleRate,
      channels,
      format.toC(),
      bufferDurationSeconds,
    );
    if (result != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder stream. Error code: $result");
    }
  }

  @override
  void start() {
    if (c.recorder_start(_self) != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording.");
    }
  }

  @override
  void stop() {
    if (c.recorder_stop(_self) != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to stop recording.");
    }
  }

  @override
  int getAvailableFrames() => c.recorder_get_available_frames(_self);
  Pointer<Float> bufferPtr = malloc.allocate<Float>(0);

  @override
  Float32List getBuffer(int framesToRead, {int channels = 2}) {
    try {
      final floatsToRead =
          framesToRead * 8; // Calculate the actual number of floats to read

      bufferPtr = malloc.allocate<Float>(floatsToRead);
      bufferPtr.retain(); // Allocate memory for the float buffer
      final floatsRead = c.recorder_get_buffer(_self, bufferPtr, floatsToRead);

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
  bool get isRecording => c.recorder_is_recording(_self);

  @override
  void dispose() {
    c.recorder_destroy(_self);
    malloc.free(_self);
  }
}

final class WebGenerator implements PlatformGenerator {
  WebGenerator(this._self);
  final Pointer<c.Generator> _self;

  late var _volume = c.generator_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    c.generator_set_volume(_self, value);
    _volume = value;
  }

  @override
  Future<void> init({
    required SoundFormat format,
    required int channels,
    required int sampleRate,
    required int bufferDurationSeconds,
  }) async {
    final result = await c.generator_init(
      _self,
      format.toC(),
      channels,
      sampleRate,
      bufferDurationSeconds,
    );
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize generator. Error code: $result");
    }
  }

  @override
  void setWaveform({
    required GeneratorWaveformType type,
    required double frequency,
    required double amplitude,
  }) {
    final result =
        c.generator_set_waveform(_self, type.index, frequency, amplitude);
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set waveform.");
    }
  }

  @override
  void setPulsewave({
    required double frequency,
    required double amplitude,
    required double dutyCycle,
  }) {
    final result =
        c.generator_set_pulsewave(_self, frequency, amplitude, dutyCycle);
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set pulse wave.");
    }
  }

  @override
  void setNoise({
    required GeneratorNoiseType type,
    required int seed,
    required double amplitude,
  }) {
    final result = c.generator_set_noise(_self, type.index, seed, amplitude);
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set noise.");
    }
  }

  @override
  void start() {
    final result = c.generator_start(_self);
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to start generator.");
    }
  }

  @override
  void stop() {
    final result = c.generator_stop(_self);
    if (result != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to stop generator.");
    }
  }

  @override
  Float32List getBuffer(int framesToRead) {
    final bufferPtr = malloc.allocate<Float>(framesToRead * 8);
    try {
      final framesRead = c.generator_get_buffer(_self, bufferPtr, framesToRead);
      if (framesRead < 0) {
        throw MinisoundPlatformException(
            "Failed to read generator data. Error code: $framesRead");
      }
      return Float32List.fromList(
          bufferPtr.asTypedList(framesRead) as List<double>);
    } finally {}
  }

  @override
  int getAvailableFrames() => c.generator_get_available_frames(_self);

  @override
  void dispose() {
    c.generator_destroy(_self);
    malloc.free(_self);
  }
}

extension GeneratorWaveformTypeToC on GeneratorWaveformType {
  int toC() => switch (this) {
        GeneratorWaveformType.sine =>
          c.GeneratorWaveformType.GENERATOR_WAVEFORM_TYPE_SINE,
        GeneratorWaveformType.square =>
          c.GeneratorWaveformType.GENERATOR_WAVEFORM_TYPE_SQUARE,
        GeneratorWaveformType.triangle =>
          c.GeneratorWaveformType.GENERATOR_WAVEFORM_TYPE_TRIANGLE,
        GeneratorWaveformType.sawtooth =>
          c.GeneratorWaveformType.GENERATOR_WAVEFORM_TYPE_SAWTOOTH,
      };
}

extension GeneratorNoiseTypeToC on GeneratorNoiseType {
  int toC() => switch (this) {
        GeneratorNoiseType.white =>
          c.GeneratorNoiseType.GENERATOR_NOISE_TYPE_WHITE,
        GeneratorNoiseType.pink =>
          c.GeneratorNoiseType.GENERATOR_NOISE_TYPE_PINK,
        GeneratorNoiseType.brownian =>
          c.GeneratorNoiseType.GENERATOR_NOISE_TYPE_BROWNIAN,
      };
}

extension SoundFormatToC on SoundFormat {
  int toC() => switch (this) {
        SoundFormat.u8 => c.SoundFormat.SOUND_FORMAT_U8,
        SoundFormat.s16 => c.SoundFormat.SOUND_FORMAT_S16,
        SoundFormat.s24 => c.SoundFormat.SOUND_FORMAT_S24,
        SoundFormat.s32 => c.SoundFormat.SOUND_FORMAT_S32,
        SoundFormat.f32 => c.SoundFormat.SOUND_FORMAT_F32,
      };
}
