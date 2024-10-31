part of "minisound_web.dart";

final class WebEngine implements PlatformEngine {
  WebEngine._(Pointer<c.Engine> self) : _self = self;

  final Pointer<c.Engine> _self;

  @override
  @deprecated
  Future<void> test(TypedData data) async {
    final dataSize = data.lengthInBytes;
    final dataPtr = malloc.allocate<Uint8>(dataSize);
    if (dataPtr == nullptr) throw MinisoundPlatformOutOfMemoryException();

    dataPtr.copy(data);

    await c.engine_test(dataPtr, dataSize);
  }

  @override
  Future<void> init(int periodMs) async {
    final r = await c.engine_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine (code: $r).");
    }
  }

  @override
  void dispose() {
    c.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = c.engine_start(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to start the engine (code: $r).");
    }
  }

  @override
  Future<WebEncodedSound> loadSound(TypedData data) async {
    final sound = c.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final dataLength = data.lengthInBytes;
    final dataPtr = malloc.allocate<Uint8>(dataLength);
    if (dataPtr == nullptr) {
      malloc.free(sound);
      throw MinisoundPlatformOutOfMemoryException();
    }

    dataPtr.copy(data);

    final r = c.engine_load_sound(_self, sound, dataPtr, dataLength);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebEncodedSound._(sound, data: dataPtr);
  }

  @override
  WebWaveformSound generateWaveform({
    required WaveformType type,
    required double freq,
  }) {
    final sound = c.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = c.engine_generate_waveform(_self, sound, type.toC(), freq);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebWaveformSound._(sound, type: type, freq: freq);
  }

  @override
  WebNoiseSound generateNoise({required NoiseType type, required int seed}) {
    final sound = c.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = c.engine_generate_noise(_self, sound, type.toC(), seed);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebNoiseSound._(sound, type: type, seed: seed);
  }

  @override
  WebPulseSound generatePulse({
    required double freq,
    required double dutyCycle,
  }) {
    final sound = c.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = c.engine_generate_pulse(_self, sound, freq, dutyCycle);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebPulseSound._(sound, freq: freq, dutyCycle: dutyCycle);
  }
}

extension on WaveformType {
  int toC() => switch (this) {
        WaveformType.sine => c.WaveformType.WAVEFORM_TYPE_SINE,
        WaveformType.square => c.WaveformType.WAVEFORM_TYPE_SQUARE,
        WaveformType.triangle => c.WaveformType.WAVEFORM_TYPE_TRIANGLE,
        WaveformType.sawtooth => c.WaveformType.WAVEFORM_TYPE_SAWTOOTH,
      };
}

extension on NoiseType {
  int toC() => switch (this) {
        NoiseType.white => c.NoiseType.NOISE_TYPE_WHITE,
        NoiseType.pink => c.NoiseType.NOISE_TYPE_PINK,
        NoiseType.brownian => c.NoiseType.NOISE_TYPE_BROWNIAN,
      };
}
