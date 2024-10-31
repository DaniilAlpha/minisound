part of "minisound_ffi.dart";

final class FfiEngine implements PlatformEngine {
  FfiEngine._(Pointer<c.Engine> self) : _self = self;

  final Pointer<c.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = _bindings.engine_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine (code: $r).");
    }
  }

  @override
  void dispose() {
    _bindings.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = _bindings.engine_start(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to start the engine (code: $r).");
    }
  }

  @override
  Future<FfiEncodedSound> loadSound(TypedData data) async {
    final sound = _bindings.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final dataLength = data.lengthInBytes;
    final dataPtr = malloc.allocate<Uint8>(dataLength);
    if (dataPtr == nullptr) {
      malloc.free(sound);
      throw MinisoundPlatformOutOfMemoryException();
    }

    dataPtr.copy(data);

    final r = _bindings.engine_load_sound(_self, sound, dataPtr, dataLength);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return FfiEncodedSound._(sound, data: dataPtr);
  }

  @override
  FfiWaveformSound generateWaveform({
    required WaveformType type,
    required double freq,
  }) {
    final sound = _bindings.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r =
        _bindings.engine_generate_waveform(_self, sound, type.toC(), freq);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return FfiWaveformSound._(sound, type: type, freq: freq);
  }

  @override
  FfiNoiseSound generateNoise({required NoiseType type, required int seed}) {
    final sound = _bindings.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = _bindings.engine_generate_noise(_self, sound, type.toC(), seed);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return FfiNoiseSound._(sound, type: type, seed: seed);
  }

  @override
  FfiPulseSound generatePulse({
    required double freq,
    required double dutyCycle,
  }) {
    final sound = _bindings.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = _bindings.engine_generate_pulse(_self, sound, freq, dutyCycle);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return FfiPulseSound._(sound, freq: freq, dutyCycle: dutyCycle);
  }
}

extension on WaveformType {
  c.WaveformType toC() => switch (this) {
        WaveformType.sine => c.WaveformType.WAVEFORM_TYPE_SINE,
        WaveformType.square => c.WaveformType.WAVEFORM_TYPE_SQUARE,
        WaveformType.triangle => c.WaveformType.WAVEFORM_TYPE_TRIANGLE,
        WaveformType.sawtooth => c.WaveformType.WAVEFORM_TYPE_SAWTOOTH,
      };
}

extension on NoiseType {
  c.NoiseType toC() => switch (this) {
        NoiseType.white => c.NoiseType.NOISE_TYPE_WHITE,
        NoiseType.pink => c.NoiseType.NOISE_TYPE_PINK,
        NoiseType.brownian => c.NoiseType.NOISE_TYPE_BROWNIAN,
      };
}
