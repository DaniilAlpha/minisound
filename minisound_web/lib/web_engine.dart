part of "minisound_web.dart";

final class WebEngine implements PlatformEngine {
  WebEngine._() : _self = _binds.engine_alloc() {
    if (_self == nullptr) throw MinisoundPlatformOutOfMemoryException();
  }

  final Pointer<c.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = await _binds.engine_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine (code: $r).");
    }
  }

  @override
  void dispose() {
    _binds.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = _binds.engine_start(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to start the engine (code: $r).",
      );
    }
  }

  @override
  Future<WebEncodedSound> loadSound(TypedData data) async {
    final sound = _binds.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final dataLength = data.lengthInBytes;
    final dataPtr = malloc.allocate<Uint8>(dataLength);
    if (dataPtr == nullptr) {
      malloc.free(sound);
      throw MinisoundPlatformOutOfMemoryException();
    }

    dataPtr.copy(data);

    final r = _binds.engine_load_sound(_self, sound, dataPtr, dataLength);
    if (r != c.Result.Ok) {
      malloc.free(dataPtr);
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebEncodedSound._(sound, data: dataPtr);
  }

  @override
  WebWaveformSound generateWaveform() {
    final sound = _binds.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = _binds.engine_generate_waveform(_self, sound);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebWaveformSound._(sound);
  }

  @override
  WebNoiseSound generateNoise(NoiseType type) {
    final sound = _binds.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = _binds.engine_generate_noise(_self, sound, type.toC());
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebNoiseSound._(sound, type);
  }

  @override
  WebPulseSound generatePulse() {
    final sound = _binds.sound_alloc();
    if (sound == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final r = _binds.engine_generate_pulse(_self, sound);
    if (r != c.Result.Ok) {
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebPulseSound._(sound);
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

extension on c.WaveformType {
  WaveformType toDart() => switch (this) {
        c.WaveformType.WAVEFORM_TYPE_SINE => WaveformType.sine,
        c.WaveformType.WAVEFORM_TYPE_SQUARE => WaveformType.square,
        c.WaveformType.WAVEFORM_TYPE_TRIANGLE => WaveformType.triangle,
        c.WaveformType.WAVEFORM_TYPE_SAWTOOTH => WaveformType.sawtooth,
      };
}

extension on NoiseType {
  c.NoiseType toC() => switch (this) {
        NoiseType.white => c.NoiseType.NOISE_TYPE_WHITE,
        NoiseType.pink => c.NoiseType.NOISE_TYPE_PINK,
        NoiseType.brownian => c.NoiseType.NOISE_TYPE_BROWNIAN,
      };
}
